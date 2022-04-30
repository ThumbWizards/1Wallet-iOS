//
//  QROptionView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 01/02/22.
//

import Foundation
import SwiftUI
import StreamChat
import StreamChatUI
import Combine

extension QROptionView {
    class ViewModel: ObservableObject {
        @Published var isChatEnable = false
        @Published var address: String
        @Published var checkAddressCancelable: AnyCancellable?
        @Published var recipientName = ""
        @Published var loadingRecipientName = false
        private var chatChannelController: ChatChannelController?
        private var subscriptions = Set<AnyCancellable>()

        enum QROptionItem: CaseIterable {
            case contact
            case chat
            case send

            var title: String {
                switch self {
                case .contact: return "Contact"
                case .chat: return "Chat"
                case .send: return "Send"
                }
            }

            var subtitle: String {
                switch self {
                case .contact: return "Add as besties"
                case .chat: return "That first converso …"
                case .send: return "Be generous"
                }
            }

            var image: Image {
                switch self {
                case .contact: return Image.contactMenu
                case .chat: return Image.chatMenu
                case .send: return Image.paperPlane
                }
            }

            var imageSize: CGSize {
                switch self {
                case .contact: return CGSize(width: 25, height: 20.5)
                case .chat: return CGSize(width: 31, height: 25.5)
                case .send: return CGSize(width: 22, height: 22)
                }

            }
        }

        init(address: String) {
            self.address = address
            self.validateChatUser()

            $address
                .sink { [weak self] scannedResult in
                    guard let weakSelf = self else { return }
                    withAnimation(.easeInOut(duration: 0.2)) {
                        weakSelf.loadingRecipientName = true
                    }
                    weakSelf.checkAddressCancelable?.cancel()
                    weakSelf.checkAddressCancelable = IdentityService.shared
                        .checkWalletAddress(address: scannedResult.convertBech32ToEthereum())
                        .sink(receiveValue: { [weak self] result in
                            guard let self = self else { return }
                            withAnimation(.easeInOut(duration: 0.2)) {
                                self.loadingRecipientName = false
                            }
                            switch result {
                            case .success(let result):
                                self.recipientName = result.title ?? ""
                            case .failure: break
                            }
                        })
                }
                .store(in: &subscriptions)
        }

        func validateChatUser() {
            do {
                chatChannelController = try ChatClient.shared.channelController(
                    createDirectMessageChannelWith: [Wallet.currentWallet?.address ?? "", address.convertBech32ToEthereum()],
                    name: nil,
                    imageURL: nil,
                    extraData: [:])
                chatChannelController?.synchronize { [weak self] error in
                    guard let `self` = self else { return }
                    self.isChatEnable = (error == nil)
                }
            } catch {
                print(error)
            }
        }

        func showChatController() {
            guard let chatController = chatChannelController, isChatEnable else { return }
            let chatChannelVC = ChatChannelVC()
            chatChannelVC.enableKeyboardObserver = true
            chatChannelVC.channelController = chatController
            chatChannelVC.modalPresentationStyle = .fullScreen
            present(chatChannelVC, animated: true)
        }
    }
}
