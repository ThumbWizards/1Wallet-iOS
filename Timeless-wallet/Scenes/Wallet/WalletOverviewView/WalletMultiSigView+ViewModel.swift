//
//  WalletMultiSigView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 28/01/2022.
//

import Combine
import web3swift
import BigInt

extension WalletMultiSigView {
    class ViewModel: ObservableObject {
        @Published var queuedData = [MultiSigQueue]()
        @Published var isLoading = false
        @Published var awaitingAmount = 0
        @Published var refreshId = UUID().uuidString
        var wallet: Wallet
        var oneToUSDValue = 0.0
        private var anyCancellables = Set<AnyCancellable>()

        init(wallet: Wallet) {
            self.wallet = wallet
        }

    }
}

extension WalletMultiSigView.ViewModel {
    func getTransaction() {
        self.isLoading = true
        let amount = Web3Service.shared.amountToWeiUnit(amount: 1,
                                                        weiUnit: OneWalletService.weiUnit)
        ExchangeRateService.shared.ONEToUSD(amount: amount)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let weakSelf = self else {
                    return
                }
                switch result {
                case .success(let weiAmount):
                    weakSelf.oneToUSDValue = weiAmount
                    weakSelf.getPendingTransaction()
                case .failure( _):
                    weakSelf.getPendingTransaction()
                }
            }
            .store(in: &anyCancellables)
    }

    private func getPendingTransaction() {
        MultisigService.shared.pendingTransfer(address: wallet.address)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] _ in
                guard let `self` = self else { return }
                self.isLoading = false
            }, receiveValue: { [weak self] result in
                guard let `self` = self else { return }
                self.isLoading = false
                self.queuedData = result.sorted(by: { $0.createDate > $1.createDate })
                self.awaitingAmount = self.queuedData.count
            })
            .store(in: &anyCancellables)
    }

    func approvedTransaction(_ queue: MultiSigQueue, completion: @escaping ((Error?) -> Void)) {
        self.isLoading = true
        guard let walletData = OneWalletService.shared.getUserWalletData(for: self.wallet),
            let safeAddress = EthereumAddress.init(queue.safe.address ?? "") else { return }
        MultisigService.shared.approveTransfer(wallet: walletData,
                                               safeAddress: safeAddress,
                                               txData: getTxData(queue: queue))
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] response in
                guard let `self` = self else { return }
                switch response {
                case .finished:
                    self.isLoading = false
                    completion(nil)
                case .failure(let error):
                    self.isLoading = false
                    showSnackBar(.error(error))
                    completion(error)
                }
            }, receiveValue: { _ in })
            .store(in: &anyCancellables)
    }

    func rejectTransaction(_ queue: MultiSigQueue, completion: @escaping ((Error?) -> Void)) {
        self.isLoading = true
        guard let walletData = OneWalletService.shared.getUserWalletData(for: self.wallet),
            let safeAddress = EthereumAddress.init(queue.safe.address ?? "") else { return }
        MultisigService.shared.rejectTransfer(wallet: walletData,
                                               safeAddress: safeAddress,
                                               txData: getTxData(queue: queue))
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] response in
                guard let `self` = self else { return }
                switch response {
                case .finished:
                    self.isLoading = false
                    completion(nil)
                case .failure(let error):
                    self.isLoading = false
                    showSnackBar(.error(error))
                    completion(error)
                }
            }, receiveValue: { _ in })
            .store(in: &anyCancellables)
    }

    func executeTransfer(_ queue: MultiSigQueue, completion: @escaping ((Error?) -> Void)) {
        self.isLoading = true
        guard let walletData = OneWalletService.shared.getUserWalletData(for: self.wallet),
            let safeAddress = EthereumAddress.init(queue.safe.address ?? "") else { return }
        MultisigService.shared.executeTransfer(wallet: walletData,
                                               safeAddress: safeAddress,
                                               txData: getTxData(queue: queue))
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] response in
                guard let `self` = self else { return }
                switch response {
                case .finished:
                    self.isLoading = false
                    completion(nil)
                case .failure(let error):
                    showSnackBar(.error(error))
                    self.isLoading = false
                    completion(error)
                }
            }, receiveValue: { _ in })
            .store(in: &anyCancellables)
    }

    private func getTxData(queue: MultiSigQueue) -> MultisigService.TxData {
        return MultisigService.TxData.init(
            id: queue.id ?? "",
            amount: queue.amount ?? "",
            recipient: queue.recipient ?? "",
            nonce: queue.nonce ?? "",
            safeTxGas: queue.safeTxGas ?? "",
            approvals: queue.approvals,
            rejections: queue.rejections,
            txId: queue.txId
        )
    }
}
