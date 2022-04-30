//
//  SelectRecipientView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 01/12/21.
//

import UIKit
import Combine
import StreamChat
import StreamChatUI

extension SelectRecipientView {
    class ViewModel: ObservableObject {
        var currentNetworkCalls = Set<AnyCancellable>()
        var sendOneWalletData = SendOneWallet()
    }
}

extension SelectRecipientView.ViewModel {
    private func fetchMyWalletAddress() -> String? {
        return Wallet.currentWallet?.address
    }

    func bindWalletData(_ user: ChatChannelMember) {
        sendOneWalletData.myName = ChatClient.shared.currentUserController().currentUser?.name
        sendOneWalletData.myWalletAddress = ChatClient.shared.currentUserId
        sendOneWalletData.recipientName = user.name
        sendOneWalletData.recipientAddress = user.id
        sendOneWalletData.recipientImageUrl = user.imageURL
        sendOneWalletData.myImageUrl = ChatClient.shared.currentUserController().currentUser?.imageURL
    }
}
