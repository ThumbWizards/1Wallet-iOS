//
//  CreateWalletViewModel.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 24/11/2021.
//

import Foundation
import Combine
import SwiftMessages
import UIKit

class CreateWalletViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var verifyingEmail = ""

    var createWalletCancellable: AnyCancellable?
}

extension CreateWalletViewModel {
    func createWallet() {
        isLoading = true
        createWalletCancellable = IdentityService.shared.createWallet.sink { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let tlWallet):
                self.walletDidCreate(tlWallet)
            case .failure(let error):
                hideConfirmationSheet()
                showSnackBar(.error(error))
            }
        }
    }

    private func walletDidCreate(_ tlWallet: TLWallet) {
        // Refresh wallet view
        if let newWallet = Wallet.currentWallet {
            // Set new wallet as current wallet
            WalletInfo.shared.currentWallet = newWallet
        }
        self.isLoading = false
        CryptoHelper.shared.viewModel.onboardWalletState = .created(wallet: tlWallet)
        WalletInfo.shared.refreshWalletData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            hideConfirmationSheet()
            showSnackBar(.walletCreatedSuccessfully)
        }
    }
}

extension CreateWalletViewModel {
    static var shared = CreateWalletViewModel()
}
