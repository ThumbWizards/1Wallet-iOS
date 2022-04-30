//
//  TabbarView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/2/21.
//

import SwiftUI
import UIKit
import Combine
import StreamChat
import GetStream
import StreamChatUI
import AVKit

extension TabBarView {
    class ViewModel: ObservableObject {
        // MARK: - Variables
        @Published var bottomViewOffset: CGFloat = 0
        @Published var pageScrollView: UIScrollView?
        @Published var selectedTab = 1
        @Published var isForceRefresh = false
        @Published var isUserLogin = false
        @Published var changeAvatarTransition = false
        var isChatConnecting = false
        var currentNetworkCalls = Set<AnyCancellable>()
        private var getStreamTokenCancellable: AnyCancellable?
        var timelineFlatFeed: FlatFeed!
        private var eventController = ChatClient.shared.eventsController()
        // redPacket
        var redPacket = RedPacket()

        // MARK: - Init
        init() {
            // set AVSession
            handleAVSession()
            handleChatConnectionStatus()
            // redPacket
            observeGiftPacket()
            // Join group
            observeJoinGroup()
            // event controller
            eventController.delegate = self
            // request new token
            ChatClientConfiguration.shared.requestNewChatToken = { [weak self] in
                guard let self = self else {
                    return
                }
                let currentWallet = WalletInfo.shared.currentWallet
                self.fetchStreamChatToken(wallet: currentWallet) {
                    if let token = try? Token(rawValue: currentWallet.streamChatAccessToken ?? "") {
                        ChatClientConfiguration.shared.streamChatToken?(token)
                    }
                }
            }
        }
    }
}

// MARK: - Functions
extension TabBarView.ViewModel {
    func handleRequestPay(_ userInfo: [AnyHashable: Any]) {
        let strRequestAmount = userInfo["transferAmount"] as? String ?? "0"
        let requestAmount = Float(strRequestAmount)
        let requestedName = userInfo["recipientName"] as? String
        let requestedUserId = userInfo["recipientUserId"] as? String
        let requestedImageUrl = userInfo["recipientImageUrl"] as? String ?? ""

        var sendOneWallet = SendOneWallet()
        sendOneWallet.myName = ChatClient.shared.currentUserController().currentUser?.name
        sendOneWallet.myWalletAddress = ChatClient.shared.currentUserId
        sendOneWallet.recipientName = requestedName
        sendOneWallet.recipientAddress = requestedUserId
        sendOneWallet.recipientImageUrl = URL(string: requestedImageUrl)
        sendOneWallet.myImageUrl = ChatClient.shared.currentUserController().currentUser?.imageURL
        sendOneWallet.transferAmount = requestAmount
        sendOneWallet.strFormattedAmount = strRequestAmount
        sendOneWallet.fractionDigits = Decimal(string: strRequestAmount)?.significantFractionalDecimalDigits ?? 0

        showConfirmation(.sendOneConfirmation(walletData: sendOneWallet, screenType: .send, channel: nil),
                         interactiveHide: false)
    }
}

// MARK: - API calls
extension TabBarView.ViewModel {
    private func handleAVSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            debugPrint(error)
        }
    }

    func syncWithWalletInfo() {
        isChatConnecting = false
        GetStreamChat.shared.logout()
        // Wait for .5 to make sure getStream disconnected
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let `self` = self else { return }
            self.chatLogin {}
        }
    }

    private func handleChatConnectionStatus() {
        ChatClient.shared.connectionController().connectionStatusPublisher
            .sink { [weak self] status in
                guard let self = self else {
                    return
                }
                if status == .connected {
                    guard self.isUserLogin == false else {
                        return
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.isUserLogin = true
                    }
                }
            }
            .store(in: &currentNetworkCalls)
    }

    func chatLogin(completion: @escaping (() -> Void)) {
        guard !isChatConnecting else { return }
        isChatConnecting = true
        if WalletInfo.shared.currentWallet.streamChatAccessToken != nil {
            streamChatLogin(wallet: WalletInfo.shared.currentWallet) { [weak self] in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    ChatClient.shared.connectionController().connect { _ in
                        self.isUserLogin = true
                    }
                }
            }
            return
        }
        fetchStreamChatToken(wallet: WalletInfo.shared.currentWallet) { [weak self] in
            guard let `self` = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.isUserLogin = true
            }
        }
    }

    func fetchStreamChatToken(wallet: Wallet,
                              completion: @escaping (() -> Void)) {
        wallet.createWalletSignature { [weak self] signature in
            guard let `self` = self, signature != nil else { return }
            self.getStreamTokenCancellable?.cancel()
            self.getStreamTokenCancellable = IdentityService.shared.fetchStreamChatToken()
                .sink { [weak self] result in
                    guard let self = self else {
                        return
                    }
                    if case .success(let token) = result {
                        guard let accessToken = token.accessToken else {
                            return
                        }
                        Wallet.allStreamChatAccessTokens[wallet.address] = accessToken
                        self.streamChatLogin(wallet: wallet,
                                             completion: completion)
                    }
                }
        }
    }

    private func streamChatLogin(wallet: Wallet,
                                 completion: @escaping (() -> Void)) {
        guard let accessToken = wallet.streamChatAccessToken else {
            return
        }
        self.isUserLogin = false
        GetStreamChat.shared.login(wallet: wallet, accessToken: accessToken) {
            // TODO: Disable upcoming event. Will enable in future.
            // self.userFeedLogin(accessToken, userId ?? "")
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.isUserLogin = true
            }
            completion()
        }
    }

    private func userFeedLogin(_ token: String, _ id: String) {
        Client.shared.setupUser(GetStream.User(id: id), token: token) { [weak self] _ in
            guard let `self` = self else { return }
            if let feedId = FeedId(feedSlug: "UpComingEvents") {
                self.timelineFlatFeed = Client.shared.flatFeed(feedId)
                // TODO: Make userId dynamic
                self.timelineFlatFeed.follow(toTarget: .init(feedSlug: "UpComingEvents", userId: "superAdmin")) { _ in
                    UpComingViewModel.shared.getUserFeeds()
                }
            }
        }
    }
}

extension TabBarView.ViewModel {
    static let shared = TabBarView.ViewModel()
}
