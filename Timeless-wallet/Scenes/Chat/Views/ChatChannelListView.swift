//
//  ChatChannelListView.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 26/10/21.
//

import SwiftUI
import StreamChat
import StreamChatUI

struct ChatChannelListView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = ChatClient.shared.channelListController(
            query: .init(
                filter: .or([
                    .containMembers(userIds: [ChatClient.shared.currentUserId!]),
                    .and([
                        .equal(.type, to: .custom("announcement")),
//                        .equal("muted", to: true)
                    ])
                ])
            ))
        /*let controller = ChatClient.shared.channelListController(
            query: .init(
                filter: .and([
                    //.equal(.type, to: .privateMessaging),
                    .equal("password", to: "1l234")
                ])))*/

        let channelListVC = ChannelListVC()
        channelListVC.controller = controller
        let navigationController = UINavigationController(rootViewController: channelListVC)
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        navigationController.navigationBar.isHidden = true
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
    
}
