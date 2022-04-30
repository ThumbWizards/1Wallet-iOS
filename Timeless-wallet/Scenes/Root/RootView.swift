//
//  RootView.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 27/10/2021.
//

import Foundation
import SwiftUI
import GetStream

struct RootView {
    @ObservedObject private var cryptoViewModel = CryptoHelper.shared.viewModel
    @AppStorage(ASSettings.General.freshInstall.key)
    private var freshInstall = ASSettings.General.freshInstall.defaultValue

    private var isAuthenticated: Bool {
        if freshInstall {
            // Todo: instead of clear the keychain data, should handle synchornize & backup later
            _ = KeyChain.shared.clear(key: .allWallets)
            freshInstall = false
            return false
        }
        if case .stored = cryptoViewModel.createWalletState {
            return true
        }
        return !Wallet.allWallets.isEmpty
    }

    init() {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().tintColor = UIColor(Color.timelessBlue)
        // TODO: - Setup in Environment file
        Client.config = .init(apiKey: "s4jazma4mq3v",
                              appId: "1149215",
                              logsEnabled: true)
    }
}

extension RootView: View {
    var body: some View {
        TabBarView()
        /*if isAuthenticated {
            TabBarView()
        } else {
            NavigationView {
                OnboardingSplashScreenView()
                    .hideNavigationBar()
            }
        }*/
    }
}
