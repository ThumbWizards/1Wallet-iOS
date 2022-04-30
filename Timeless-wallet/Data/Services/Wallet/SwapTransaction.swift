//
//  SwapTransaction.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 06/01/22.
//

import Foundation
import BigInt
import Combine

protocol SwapTransactionDelegate: AnyObject {
    /// This is called when transaction status changed
    func transactionState(instance: SwapTransaction, state: SwapTransactionState)
    /// This is called when transaction finished
    func didFinishTransaction(instance: SwapTransaction)
    /// This is called when transaction failed
    func didFailTransaction(instance: SwapTransaction, with error: Error?)
}

enum SwapTransactionState {
    case none
    case pending
    case successful
    case fail
}

enum SwapType {
    case oneToToken
    case tokenToOne
    case none
}

class SwapTransaction {
    // MARK: - Variable
    /// The delegate for the transaction status update
    /// The delegate receives callbacks when SwapTransaction status change
    private(set) weak var delegate: SwapTransactionDelegate?
    // current transaction status
    private(set) var transactionStatus: SwapTransactionState = .none
    // ercToken
    private(set) var token: Web3Service.Erc20Token
    // swap amount
    private(set) var amount: Double
    // to differentiate current transaction type
    private(set) var type: SwapType = .none
    private(set) var cancellables = Set<AnyCancellable>()
    static let slippage = 0.005
    // unique id for compare instances
    var id = UUID().uuidString

    // MARK: - Init
    init(token: Web3Service.Erc20Token,
         amount: Double,
         delegate: SwapTransactionDelegate) {
        self.token = token
        self.amount = amount
        self.delegate = delegate
    }

    // MARK: - Functions
    func startSwapOneToToken() {
        type = .oneToToken
        guard let walletData = OneWalletService.shared.getCurrentUserWalletData(), transactionStatus == .none else { return }
        let tokenAmount = Web3Service.shared.amountToWeiUnit(amount: amount,
                                                             weiUnit: OneWalletService.weiUnit)
        transactionStatus = .pending
        delegate?.transactionState(instance: self, state: self.transactionStatus)
        ExchangeRateService.shared.swapRateFromONE(to: token, amount: tokenAmount)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: RunLoop.main)
            .sink { [weak self] res in
                guard let weakSelf = self else {
                    return
                }
                switch res {
                case .success(let oneAmount):
                    OneWalletService.shared.swapONEToToken(wallet: walletData,
                                                           token: weakSelf.token,
                                                           amountIn: tokenAmount,
                                                           expectedAmountOut: oneAmount,
                                                           slippage: Self.slippage, // 0.5%
                                                           deadline: TimeInterval(120))
                        .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                        .receive(on: RunLoop.main)
                        .sink(receiveCompletion: { complete in
                            switch complete {
                            case .failure(let error):
                                weakSelf.transactionStatus = .fail
                                weakSelf.delegate?.didFailTransaction(instance: weakSelf, with: error)
                            case .finished:
                                weakSelf.transactionStatus = .successful
                                weakSelf.delegate?.didFinishTransaction(instance: weakSelf)
                            }
                        }, receiveValue: { [weak self] res in
                            guard let weakSelf = self else { return }
                            if res.success == true {
                                weakSelf.transactionStatus = .successful
                                weakSelf.delegate?.transactionState(instance: weakSelf, state: weakSelf.transactionStatus)
                            } else {
                                weakSelf.transactionStatus = .fail
                                weakSelf.delegate?.transactionState(instance: weakSelf, state: weakSelf.transactionStatus)
                            }
                        })
                        .store(in: &weakSelf.cancellables)
                case .failure(let error):
                    weakSelf.transactionStatus = .fail
                    weakSelf.delegate?.didFailTransaction(instance: weakSelf, with: error)
                }
            }
            .store(in: &cancellables)
    }

    func startSwapTokenToOne() {
        guard let walletData = OneWalletService.shared.getCurrentUserWalletData(), transactionStatus == .none else { return }
        let tokenAmount = Web3Service.shared.amountToWeiUnit(amount: amount,
                                                             weiUnit: token.weiUnit)
        transactionStatus = .pending
        delegate?.transactionState(instance: self, state: self.transactionStatus)
        ExchangeRateService.shared.swapRateToONE(from: token, amount: tokenAmount)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: RunLoop.main)
            .sink { [weak self] res in
                guard let weakSelf = self else {
                    return
                }
                switch res {
                case .success(let oneAmount):
                    OneWalletService.shared.swapTokenToONE(wallet: walletData,
                                                           token: weakSelf.token,
                                                           amountIn: tokenAmount,
                                                           expectedAmountOut: oneAmount,
                                                           slippage: Self.slippage, // 0.5%
                                                           deadline: TimeInterval(120))
                        .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                        .receive(on: RunLoop.main)
                        .sink(receiveCompletion: { complete in
                            switch complete {
                            case .failure(let error):
                                weakSelf.transactionStatus = .fail
                                weakSelf.delegate?.didFailTransaction(instance: weakSelf, with: error)
                            case .finished:
                                weakSelf.transactionStatus = .successful
                                weakSelf.delegate?.didFinishTransaction(instance: weakSelf)
                            }
                        }, receiveValue: { [weak self] res in
                            guard let weakSelf = self else { return }
                            if res.success == true {
                                weakSelf.transactionStatus = .successful
                                weakSelf.delegate?.transactionState(instance: weakSelf, state: weakSelf.transactionStatus)
                            } else {
                                weakSelf.transactionStatus = .fail
                                weakSelf.delegate?.transactionState(instance: weakSelf, state: weakSelf.transactionStatus)
                            }
                        })
                        .store(in: &weakSelf.cancellables)
                case .failure(let error):
                    weakSelf.transactionStatus = .fail
                    weakSelf.delegate?.didFailTransaction(instance: weakSelf, with: error)
                }
            }
            .store(in: &cancellables)
    }
}
