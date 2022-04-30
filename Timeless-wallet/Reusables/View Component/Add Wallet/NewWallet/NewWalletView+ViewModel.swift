//
//  NewWalletView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 21/01/22.
//

import Foundation
import Combine
import UIKit
import SwiftUI

extension NewWalletView {
    class ViewModel: ObservableObject {
        // MARK: - Variables 
        @Published var walletName = ""
        @Published var checkWalletCancellable: AnyCancellable?
        @Published var isLoading = false
        @Published var errorType: ErrorType = .none
        private var subscriptions = Set<AnyCancellable>()
        private var createWalletCancelable: AnyCancellable?
        private var createWalletStartTime: Date?

        init() {
            self.errorType = .none
            $walletName
                .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
                .sink(receiveValue: { [weak self] name in
                    guard let `self` = self, name.count > 5 else {
                        return
                    }
                    self.checkWalletCancellable = IdentityService.shared.checkWalletTitle(walletName: name)
                        .sink(receiveValue: { [weak self] result in
                            guard let self = self else {
                                return
                            }
                            self.isLoading = false
                            hideConfirmationSheet()
                            switch result {
                            case .success(let result):
                                if let available = result.available, self.walletName.count > 5 {
                                    self.errorType = available ? .available : .taken
                                } else {
                                    self.errorType = .none
                                }
                            case.failure(let error):
                                showSnackBar(.error(error))
                            }
                        })
                })
                .store(in: &subscriptions)
            
            $walletName
                .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
                .sink(receiveValue: { [weak self] name in
                    guard !name.isEmpty, name.count < 6 else { return }
                    self?.errorType = .nameLength
                })
                .store(in: &subscriptions)
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
                    guard let `self` = self else { return }
                    switch result {
                    case .success:
                        self.createWalletStartTime = nil
                    case .failure(let error):
                        if error == OneWalletService.NewWalletError.missingWalletPayload,
                           let createWalletStartTime = self.createWalletStartTime,
                           createWalletStartTime + 180 > Date() {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                                guard let `self` = self else { return }
                                self.createWallet(isRetrying: true)
                            }
                        } else {
                            self.createWalletStartTime = nil
                            // Todo: find a better way to handle error
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {[weak self] in
                                guard let `self` = self else { return }
                                self.createWallet(isRetrying: true)
                            }
                        }
                    }
                })
        }
    }
}

extension NewWalletView.ViewModel {
    enum ErrorType {
        case none
        case taken
        case available
        case nameLength

        var icon: Image? {
            switch self {
            case .taken, .nameLength:
                return Image.exclamationMarkCircleFill
            case .available:
                return Image.checkmarkCircleFill
            default:
                return nil
            }
        }

        var title: String {
            switch self {
            case .taken:
                return "Wallet name is taken"
            case .available:
                return "Available"
            case .nameLength:
                return "Wallet name must be at least 6 characters"
            default:
                return ""
            }
        }

        var color: Color {
            switch self {
            case .taken, .nameLength:
                return Color.searchFieldBorder
            case .available:
                return Color.introduceItem
            default:
                return Color.white40
            }
        }
    }
}

extension NewWalletView.ViewModel {
    static var shared = NewWalletView.ViewModel()
}
