//
//  DisbursementReviewView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 03/02/22.
//

import SwiftUI
import Combine
import StreamChat

extension DisbursementReviewView {
    class ViewModel: ObservableObject {
        // MARK: - Variables
        private var cancellable = Set<AnyCancellable>()
        var disbursementModel: DisbursementModel
        @Published var didGetTxData = false
        @Published var isLoading = false
        var oneAmount: String
        var usdAmount: String
        var addressPreview: String
        var address: String

        // MARK: - Init
        init(model: DisbursementModel) {
            self.disbursementModel = model
            self.oneAmount = Utils.formatONE(Double(model.oneBalance ?? 0))
            self.usdAmount = Utils.formatBalance(Double(model.usdBalance ?? 0))
            self.address = model.recipientWallet?.address ?? "-"
            self.addressPreview = model.recipientWallet?.address.convertToWalletAddress().trimStringByCount(count: 10) ?? "-"
        }

    }
}

extension DisbursementReviewView.ViewModel {
    func submitTransaction() {
        if let walletData = OneWalletService.shared.getUserWalletData(for: WalletInfo.shared.currentWallet),
           let safeAddress = disbursementModel.multisigWallet,
           let amount = disbursementModel.oneBalance,
           let recipient = disbursementModel.recipientWallet {
            isLoading = true
            let transferBalance = Web3Service.shared.amountToWeiUnit(amount: amount, weiUnit: OneWalletService.weiUnit)
            MultisigService.shared.initiateTransfer(
                wallet: walletData,
                safeAddress: safeAddress,
                amount: transferBalance,
                recipient: recipient
            )
                .subscribe(on: DispatchQueue.global())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { [weak self] response in
                    guard let `self` = self else { return }
                    self.isLoading = false
                    switch response {
                    case .finished:
                        self.didGetTxData = true
                    case .failure(let error):
                        showSnackBar(.error(error))
                    }
                }, receiveValue: { _ in })
                .store(in: &cancellable)
        }
    }
}
