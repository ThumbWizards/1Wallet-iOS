//
//  ChatRouter.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 04/01/22.
//

import StreamChatUI

class ChatRouter: ChatChannelListRouter {

    // MARK: - Override
    override func showCurrentUserProfile() {
        Utils.playHapticEvent()
        showConfirmation(.avatar())
    }
}
