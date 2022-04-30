//
//  SendOneSuccessfulView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 09/12/21.
//

import Foundation
import StreamChatUI

extension SendOneSuccessfulView {
    class ViewModel: ObservableObject {

        // MARK: - Variables
        var sendOneWalletData: SendOneWallet

        // MARK: - Initializer
        init(walletData: SendOneWallet) {
            self.sendOneWalletData = walletData
        }
    }
}
