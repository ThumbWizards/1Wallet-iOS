//
//  ChannelListVC+ViewModel.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 02/12/21.
//

import Foundation
import Combine
import StreamChatUI
import StreamChat
import web3swift

class ChannelListViewModel: NSObject {

    // MARK: - Variable
    private var currentNetworkCalls = Set<AnyCancellable>()
    var oneWallet = SendOneWallet()

    // MARK: - Functions
    func bindWalletData(_ user: ChatChannelMember) {
        oneWallet.myName = ChatClient.shared.currentUserController().currentUser?.name
        oneWallet.myWalletAddress = ChatClient.shared.currentUserId
        oneWallet.recipientName = user.name
        oneWallet.recipientAddress = user.id
        oneWallet.myImageUrl = ChatClient.shared.currentUserController().currentUser?.imageURL
        oneWallet.recipientImageUrl = user.imageURL
    }

    private func fetchMyWalletAddress() -> String? {
        return Wallet.currentWallet?.address
    }
}
