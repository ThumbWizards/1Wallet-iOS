//
//  AppSetupView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/10/21.
//

import SwiftUI
import Combine
import SwiftMessages

extension AppSetupView {
    class ViewModel: ObservableObject {
        @Published var walletName = ""
        @Published var background = Color(UIColor.systemBackground)
        @Published var updateWalletTitleCancellable: AnyCancellable?
        @Published var checkWalletNameCancellable: AnyCancellable?
        @Published var getUserDataCancellable: AnyCancellable?
        @Published var isLoading = false
        @Published var errorType: ErrorType = .none
        @AppStorage(ASSettings.General.appSetupState.key)
        private var appSetupState = ASSettings.General.appSetupState.defaultValue
        private var subscriptions = Set<AnyCancellable>()

        init() {
            $walletName
                .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
                .sink(receiveValue: { [weak self] name in
                    guard let `self` = self, name.count > 5 else {
                        return
                    }
                    self.checkWalletNameCancellable = IdentityService.shared.checkWalletTitle(walletName: name)
                        .sink(receiveValue: { [weak self] result in
                            guard let self = self else {
                                return
                            }
                            self.isLoading = false
                            hideConfirmationSheet()
                            switch result {
                            case .success(let result):
                                if let available = result.available {
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
    }
}

extension AppSetupView.ViewModel {
    func updateWalletTitle() {
        isLoading = true
        guard let walletAddress = Wallet.currentWallet?.address else {
            return showSnackBar(.somethingWentWrongRandomText)
        }
        updateWalletTitleCancellable = IdentityService.shared.updateWalletTitle(address: walletAddress, title: self.walletName)
            .sink(receiveValue: { [weak self] result in
                guard let self = self else {
                    return
                }
                self.isLoading = false
                hideConfirmationSheet()
                switch result {
                case .success:
                    Wallet.updateWallet(title: self.walletName)
                    // Refresh wallet view
                    if let currentWallet = Wallet.currentWallet {
                        WalletInfo.shared.currentWallet = currentWallet
                    }
                    withAnimation {
                        self.appSetupState = ASSettings.AppSetupState.security.rawValue
                    }
                case.failure(let error):
                    showSnackBar(.error(error))
                }
            })
    }
}

extension AppSetupView.ViewModel {
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
                return "Wallet name will be made public."
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


extension AppSetupView.ViewModel {
    static let shared = AppSetupView.ViewModel()
}
