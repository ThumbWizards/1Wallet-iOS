//
//  WalkthroughScreenView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 10/26/21.
//

import SwiftUI
import Combine

extension WalkthroughScreenView {
    class ViewModel: ObservableObject {
        var createWalletCancelable: AnyCancellable?

        private var createWalletStartTime: Date?
    }
}

extension WalkthroughScreenView.ViewModel {
    func requestPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in

        }
    }

    func createWallet(isRetrying: Bool = false) {
        switch CryptoHelper.shared.viewModel.onboardWalletState {
        case .chainPinged:
            return
        default: break
        }
        guard createWalletStartTime == nil || isRetrying else {
            // Creating wallet in-progress
            return
        }
        createWalletCancelable?.cancel()
        if !isRetrying {
            createWalletStartTime = Date()
        }
        createWalletCancelable = OneWalletService.shared.newWallet
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success:
                    self?.createWalletStartTime = nil
                case .failure(let error):
                    if error == OneWalletService.NewWalletError.missingWalletPayload,
                       let createWalletStartTime = self?.createWalletStartTime,
                       createWalletStartTime + 180 > Date() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self?.createWallet(isRetrying: true)
                        }
                    } else {
                        self?.createWalletStartTime = nil
                        hideConfirmationSheet()
                        showSnackBar(.error(error))
                    }
                }
            })
    }
}
