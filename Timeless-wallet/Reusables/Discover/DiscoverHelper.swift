//
//  DiscoverHelper.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 3/17/22.
//

import Foundation
import SwiftUI
import StreamChat
import StreamChatUI

class DiscoverHelper {
    static let shared = DiscoverHelper()
    func makeAction(ctaType: String?, ctaData: [String: Any]) {
        guard let type = ctaType else { return }
        switch type {
        case "direct":
            onTapToDirect(dict: ctaData)
        case "dialog":
            onTapShowDialog(dict: ctaData)
        case "bottom_sheet":
            onTapShowActionSheet(dict: ctaData)
        default:
            break
        }
    }
}

extension DiscoverHelper {
    private func onTapToDirect(dict: [String: Any]) {
        guard let url = dict["url"] as? String,
              let url = URL(string: url) else { return }
        if url.scheme == "timeless-1wallet" {
            let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems
            let type = queryItems?.first(where: { $0.name == "type" })?.value
            switch type {
            case "chatlist":
                goToChatList()
            case "chatgroup":
                guard let groupid = queryItems?.first(where: { $0.name == "group_id" })?.value else { return }
                goToChatGroup(groupid)
            case "dm":
                guard let address = queryItems?.first(where: { $0.name == "address" })?.value else { return }
                goToDM(address)
            case "ar_nft":
                present(ARView(), presentationStyle: .overFullScreen)
            default: break
            }
            return
        }
        
        let deepLinkHelper = DeeplinkHelper.shared
        let uiApplication = UIApplication.shared
        deepLinkHelper.extractActualLink(url) { deepLink in
            guard let deepLink = deepLink else {
                if uiApplication.canOpenURL(url) {
                    uiApplication.open(url)
                }
                return
            }
            deepLinkHelper.executeDeeplink(deepLink)
        }
    }

    private func onTapShowDialog(dict: [String: Any]) {
        let title = dict["title"] as? String ?? ""
        let message = dict["message"] as? String ?? ""
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let buttonText = dict["button_text"] as? String {
            alert.addAction(UIAlertAction(title: buttonText, style: .default, handler: { [weak self] _ in
                self?.onTapToDirect(dict: dict)
            }))
        }
        if let cancelButton = dict["cancel_text"] as? String {
            alert.addAction(UIAlertAction(title: cancelButton, style: .cancel, handler: nil))
        }
        present(alert, animated: true)
    }

    private func onTapShowActionSheet(dict: [String: Any]) {
        let title = dict["title"] as? String ?? ""
        let urls = dict["urls"] as? [[String: String]] ?? []
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        urls.forEach { obj in
            alert.addAction(.init(title: obj["title"] ?? "", style: .default, handler: { [weak self] _ in
                self?.onTapToDirect(dict: obj)
            }))
        }
        if let cancelText = dict["cancel_text"] as? String {
            alert.addAction(.init(title: cancelText, style: .cancel, handler: nil))
        }
        present(alert, animated: true)
    }

    private func goToChatList() {
        if TabBarView.ViewModel.shared.selectedTab != 2 {
            TabBarView.ViewModel.shared.selectedTab = 2
        }
    }

    private func goToDM(_ address: String) {
        do {
            if TabBarView.ViewModel.shared.selectedTab != 2 {
                TabBarView.ViewModel.shared.selectedTab = 2
            }

            let chatChannelController = try ChatClient.shared.channelController(
                createDirectMessageChannelWith: [Wallet.currentWallet?.address ?? "", address.convertBech32ToEthereum()],
                name: nil,
                imageURL: nil,
                extraData: [:])

            chatChannelController.synchronize { error in
                if error == nil {
                    let chatChannelVC = ChatChannelVC()
                    chatChannelVC.enableKeyboardObserver = true
                    chatChannelVC.channelController = chatChannelController
                    chatChannelVC.modalPresentationStyle = .fullScreen
                    present(chatChannelVC, animated: true)
                } else {
                    showSnackBar(.error(error))
                }
            }
        } catch {
            showSnackBar(.error(error))
        }
    }

    private func goToChatGroup(_ groupId: String) {
        let split = groupId.split(separator: ":")
        guard let currentUserId = ChatClient.shared.currentUserId,
              let groupType = split.first,
              let gId = split.last else {
            return
        }

        if TabBarView.ViewModel.shared.selectedTab != 2 {
            TabBarView.ViewModel.shared.selectedTab = 2
        }

        // Todo: This handle need to be refactor
        let channelID = ChannelId.init(type: String(groupType) == "announcement" ? .announcement : .messaging,
                                       id: String(gId))
        let channelController = ChatClient.shared.channelController(for: .init(cid: channelID))

        channelController.synchronize { error in
            guard error == nil else {
                showSnackBar(.errorMsg(text: "Something went wrong!"))
                return
            }
            guard String(groupType) != "announcement" else {
                let chatChannelVC = ChatChannelVC.init()
                chatChannelVC.channelController = channelController
                chatChannelVC.enableKeyboardObserver = true
                let chatNav = UINavigationController.init(rootViewController: chatChannelVC)
                chatNav.navigationBar.isHidden = true
                chatNav.modalPresentationStyle = .fullScreen
                UIApplication.shared.getTopViewController()?.present(chatNav, animated: true, completion: nil)
                return
            }
            guard channelController.channel?.membership?.memberRole != .owner else {
                return
            }
            guard channelController.channel?.lastActiveMembers.firstIndex(where: {
                $0.id.lowercased() == currentUserId.lowercased()
            }) == nil else {
                showSnackBar(.errorMsg(text: "You have already joined this group"))
                return
            }
            guard let joinGroupVC = JoinGroupRequestVC.instantiateController(storyboard: .GroupChat) as? JoinGroupRequestVC else {
                return
            }
            let chatChannelVC = ChatChannelVC.init()
            chatChannelVC.channelController = channelController
            chatChannelVC.enableKeyboardObserver = true
            joinGroupVC.callbackUserJoined = {
                joinGroupVC.dismiss(animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        let chatNav = UINavigationController.init(rootViewController: chatChannelVC)
                        chatNav.navigationBar.isHidden = true
                        chatNav.modalPresentationStyle = .fullScreen
                        UIApplication.shared.getTopViewController()?.present(chatNav, animated: true, completion: nil)
                    }
                }
            }
            dismissAll {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    joinGroupVC.modalPresentationStyle = .overCurrentContext
                    joinGroupVC.modalTransitionStyle = .crossDissolve
                    UIApplication.shared.getTopViewController()?.present(joinGroupVC, animated: true, completion: nil)
                }
            }
        }
    }
}
