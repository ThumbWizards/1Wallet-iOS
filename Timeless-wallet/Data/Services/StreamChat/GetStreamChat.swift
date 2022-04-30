//
//  GetStreamChat.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 26/10/21.
//
import StreamChat
import StreamChatUI
import Foundation

class GetStreamChat {
    // MARK: - Variables
    @UserDefault(
        key: ASSettings.NotificationService.deviceToken.key,
        defaultValue: ASSettings.NotificationService.deviceToken.defaultValue
    )
    private var deviceToken: Data?
    static let shared = GetStreamChat()
    private var selectedChatClient: ChatClient?

    // MARK: - Functions
    func login(wallet: Wallet,
               accessToken: String,
               completion: @escaping (() -> Void)) {
        let userInfo = UserInfo(
            id: wallet.address,
            name: wallet.name ?? "",
            imageURL: wallet.fixedAvatarURL,
            extraData: ["userId": .string(wallet.address),
                        "walletAddress": .string(wallet.address)]
        )
        do {
            let accessToken = try Token(rawValue: accessToken)
            ChatClient.shared.connectUser(userInfo: userInfo, token: accessToken) { [weak self] error in
                guard error == nil, let self = self else {
                    return
                }
                if let deviceToken = self.deviceToken {
                    self.addDeviceTokenTOCurrentUser(token: deviceToken)
                }

                // Update getStream user title
                if ChatClient.shared.currentUserController().currentUser?
                    .name?.lowercased() != (wallet.name ?? wallet.address).lowercased() {
                    self.updateLoginUser(wallet: wallet)
                    completion()
                } else {
                    completion()
                }
            }
        } catch {}
    }

    func logout() {
        removeDeviceTokenFromCurrentUser {
            ChatClient.shared.connectionController().disconnect()
            TabBarView.ViewModel.shared.isUserLogin = false
        }
    }

    func addDeviceTokenTOCurrentUser(token: Data) {
        ChatClient.shared.currentUserController().addDevice(token: token, completion: nil)
    }

    func removeDeviceTokenFromCurrentUser(completion: @escaping (() -> Void)) {
        guard let deviceId = ChatClient.shared.currentUserController().currentUser?.devices.last?.id else {
            completion()
            return
        }
        ChatClient.shared.currentUserController().removeDevice(id: deviceId) { _ in
            completion()
        }
    }

    func updateLoginUser(wallet: Wallet) {
        if wallet.address == ChatClient.shared.currentUserId {
            let controller = ChatClient.shared.currentUserController()
            controller.updateUserData(
                name: wallet.name,
                imageURL: wallet.fixedAvatarURL,
                userExtraData: ["userId": .string(wallet.address),
                                "walletAddress": .string(wallet.address)],
                completion: nil)
        } else {
            let config = ChatClientConfig(apiKey: APIKey(ChatClientConfiguration.shared.apiKey))
            selectedChatClient = ChatClient.init(config: config) { completion in
                ChatClientConfiguration.shared.requestNewChatToken?()
                TabBarView.ViewModel.shared.fetchStreamChatToken(wallet: wallet) {
                    if let token = try? Token(rawValue: wallet.streamChatAccessToken ?? "") {
                        completion(.success(token))
                    }
                }
            }
            if let token = wallet.streamChatAccessToken,
               let chatToken = try? Token(rawValue: token),
               let selectedChatClient = selectedChatClient {
                try? selectedChatClient.setToken(token: .init(rawValue: token))
                let userInfo = UserInfo(
                    id: wallet.address,
                    name: wallet.name ?? "",
                    imageURL: wallet.fixedAvatarURL,
                    extraData: ["userId": .string(wallet.address),
                                "walletAddress": .string(wallet.address)]
                )
                selectedChatClient.connectUser(userInfo: userInfo, token: chatToken) { [weak self] _ in
                    guard let `self` = self else { return }
                    self.selectedChatClient?.disconnect()
                    self.selectedChatClient = nil
                }
            }
        }
    }
}
