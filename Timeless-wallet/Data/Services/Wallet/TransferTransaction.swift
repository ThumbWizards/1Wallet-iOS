//
//  WalletService.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 27/12/21.
//

import Foundation
import web3swift
import BigInt
import Combine

protocol TransferTransactionDelegate: AnyObject {
    /// This is called when transaction initiated
    func didStartTransaction(instance: TransferTransaction)
    /// This is called when transaction finished with transactionId
    func didCompleteTransaction(instance: TransferTransaction, transactionId: String?)
    /// This is called when transaction failed due to some errors
    func didFailTransaction(instance: TransferTransaction, error: OneWalletService.CommitRevealError)
    /// This is called when wallet transaction status changed
    func transactionStatusHasChanged(instance: TransferTransaction, status: OneWalletService.CommitRevealProgress)
    /// This is called when transaction successfully aborted by user
    func transactionAborted(instance: TransferTransaction)
}

class TransferTransaction {

    // MARK: - Variables
    /// The delegate for the transaction status update
    /// The delegate receives callbacks when wallet transaction status change
    private(set) weak var delegate: TransferTransactionDelegate?
    /// sourceWallet data with markleTree and seends to transfer amount
    private(set) var sourceWalletData: OneWalletService.WalletData?
    /// destination wallet address in Bech32 format
    private(set) var destinationWalletAddress: EthereumAddress
    /// transfer amount in BigUInt unit
    private(set) var amount: BigUInt
    private(set) var transferCancellable: AnyCancellable?
    /// receive transaction ID when transaction finished
    private(set) var txId: String?
    // current transaction status
    private(set) var transactionStatus: OneWalletService.CommitRevealProgress = .none
    // transfer with token
    private(set) var token: Web3Service.Erc20Token?
    private(set) var parameters: [AnyObject]?
    // unique id for compare instances
    var id = UUID().uuidString
    var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    /// Use this initialiser if sourceWalletData is not current user's wallet data
    init(sourceWalletData: OneWalletService.WalletData?,
         destinationWalletAddress: EthereumAddress,
         amount: Double,
         token: Web3Service.Erc20Token? = nil,
         parameters: [AnyObject]? = nil,
         delegate: TransferTransactionDelegate) {
        self.sourceWalletData = sourceWalletData
        self.destinationWalletAddress = destinationWalletAddress
        self.amount = Web3Service.shared.amountToWeiUnit(amount: amount,
                                                         weiUnit: OneWalletService.weiUnit)
        self.token = token
        self.parameters = parameters
        self.delegate = delegate
    }

    /// Use this initialiser If source wallet data is current user's wallet data
    init(destinationWalletAddress: EthereumAddress,
         amount: Double,
         token: Web3Service.Erc20Token? = nil,
         parameters: [AnyObject]? = nil,
         delegate: TransferTransactionDelegate) {
        self.sourceWalletData = OneWalletService.shared.getCurrentUserWalletData()
        self.destinationWalletAddress = destinationWalletAddress
        self.amount = Web3Service.shared.amountToWeiUnit(amount: amount,
                                                         weiUnit: OneWalletService.weiUnit)
        self.token = token
        self.parameters = parameters
        self.delegate = delegate
    }


    // MARK: - Functions
    /// Initiate wallet amount transfer with initialised inputs
    func start() {
        guard case .none = transactionStatus else {
            print("transaction is already in progress", self)
            return
        }
        guard let sourceWalletData = sourceWalletData else {
            delegate?.didFailTransaction(instance: self, error: .unknownError)
            return
        }
        delegate?.didStartTransaction(instance: self)
        func handleCompletion(_ self: TransferTransaction,
                              _ completion: Subscribers.Completion<OneWalletService.CommitRevealError>,
                              isOneTransfer: Bool) {
            switch completion {
            case .failure(let error):
                self.delegate?.didFailTransaction(instance: self, error: error)
            case .finished:
                guard let txId = self.txId, let walletAddress = self.sourceWalletData?.address.address else {
                    self.delegate?.didFailTransaction(instance: self, error: .transactionFail)
                    return
                }
                self.getTxStatus(txId, walletAddress: walletAddress, isOneTransfer: isOneTransfer) { [weak self] txStatus in
                    guard let self = self else {
                        return
                    }
                    if txStatus == .ok {
                        self.delegate?.didCompleteTransaction(instance: self, transactionId: txId)
                    } else {
                        self.delegate?.didFailTransaction(instance: self, error: .transactionFail)
                    }
                }
            }
        }
        func handleReceiveValue(_ self: TransferTransaction,
                                _ txProgress: OneWalletService.CommitRevealProgress) {
            self.transactionStatus = txProgress
            if case .done(let txId) = txProgress {
                self.txId = txId
            }
            print("------------------->>>>>", txProgress)
            self.delegate?.transactionStatusHasChanged(instance: self, status: txProgress)
        }
        if let token = token {
            guard let tokenContract = Web3Service.shared.erc20Contract(at: token.contractAddress) else {
                      return
                  }
            transferCancellable = OneWalletService.shared.callExternalMethodWithProgress(wallet: sourceWalletData,
                                                                                         amount: 0,
                                                                                         contract: tokenContract,
                                                                                         method: "transfer",
                                                                                         parameters: self.parameters ?? [])
                .subscribe(on: DispatchQueue.global(qos: .background))
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        guard let self = self else {
                            return
                        }
                        handleCompletion(self, completion, isOneTransfer: false)
                    },
                    receiveValue: { [weak self] txProgress in
                        guard let self = self else { return }
                        handleReceiveValue(self, txProgress)
                    })
        } else {
            transferCancellable = OneWalletService.shared.transferWithProgress(
                from: sourceWalletData,
                to: destinationWalletAddress,
                amount: amount)
                .subscribe(on: DispatchQueue.global(qos: .background))
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        guard let self = self else {
                            return
                        }
                        handleCompletion(self, completion, isOneTransfer: true)
                    },
                    receiveValue: { [weak self] txProgress in
                        guard let self = self else { return }
                        handleReceiveValue(self, txProgress)
                    })
        }
    }

    /// abort current transaction
    func abort() {
        switch transactionStatus {
        case .committing, .verifyingCommit, .pendingReveal, .none:
            transferCancellable?.cancel()
            transactionStatus = .none
            delegate?.transactionAborted(instance: self)
        default:
            break
        }
    }

    /// get transaction status from receipt logs
    private func getTxStatus(_ txID: String, walletAddress: String, isOneTransfer: Bool, status: @escaping ((TransactionReceipt.TXStatus) -> Void)) {
        OneWalletService.shared.getTxStatus(txID, walletAddress: walletAddress, isOneTransfer: isOneTransfer)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(_):
                        status(.failed)
                    }
                },
                receiveValue: { txStatus in
                    status(txStatus)
                })
            .store(in: &cancellables)
    }
}
