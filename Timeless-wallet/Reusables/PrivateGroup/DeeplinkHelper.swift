//
//  DeeplinkHelper.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 12/01/22.
//

import StreamChatUI
import StreamChat
import BigInt
import web3swift
import FirebaseDynamicLinks
import UIKit
import Combine

class DeeplinkHelper {

    // MARK: - Variable
    static let shared = DeeplinkHelper()
    var deeplinkUrl: URL?
    var currentNetworkCalls = Set<AnyCancellable>()

    @UserDefault(
        key: ASSettings.Setting.requireForTransaction.key,
        defaultValue: ASSettings.Setting.requireForTransaction.defaultValue
    )
    var requireForTransaction: Bool

    @UserDefault(
        key: ASSettings.Settings.lockMethod.key,
        defaultValue: ASSettings.Settings.lockMethod.defaultValue
    )
    var lockMethod: String

    private var appLockEnable: Bool {
        Lock.shared.passcode != nil && lockMethod != ASSettings.LockMethod.none.rawValue && requireForTransaction
    }

    // MARK: - Init
    init() {
        ChatClientConfiguration.shared.requestPrivateGroupDynamicLink = { (groupId, signature, expiry) in
            DynamicLinkBuilder.generatePrivateGroupLink(
                groupId: groupId,
                signature: signature,
                expiry: expiry) { url in
                    ChatClientConfiguration.shared.requestedPrivateGroupDynamicLink?(url)
                }
        }
    }

    // MARK: - Functions
    func handleDeepLink(url: URL) {
        DynamicLinks.dynamicLinks()
            .handleUniversalLink(url) { [weak self] dynamicLink, error in
                guard let self = self, error == nil else {
                    fatalError("Error handling the incoming dynamic link.")
                }
                if let dynamicLink = dynamicLink {
                    self.deeplinkUrl = dynamicLink.url
                }
            }
    }

    func extractActualLink(_ url: URL, completion: @escaping ((URL?) -> Void)) {
        DynamicLinks.dynamicLinks()
            .handleUniversalLink(url) { dynamicLink, error in
                guard error == nil else {
                    completion(nil)
                    return
                }
                if let dynamicLink = dynamicLink {
                    completion(dynamicLink.url)
                } else {
                    completion(nil)
                }
            }
    }

    func executeDeeplink(_ url: URL) {
        if isDaoGroupLink(url) {
            handleDaoGroupLink(url)
        } else if isGeneralGroupLink(url) {
            self.handleGeneralGroupDeepLink(url)
        } else if isProfileLink(url) {
            handleProfileLink(url)
        }
        deeplinkUrl = nil
    }

    func handleSavedDeepLink() {
        if let url = DeeplinkHelper.shared.deeplinkUrl {
            executeDeeplink(url)
        }
    }

    func isDaoGroupLink(_ url: URL) -> Bool {
        guard let urlString = url.absoluteString.removingPercentEncoding else {
            return false
        }
        return urlString.hasPrefix("https://\(Constants.DynamicLink.daoBaseUrl)")
    }

    func isGeneralGroupLink(_ url: URL) -> Bool {
        guard let urlString = url.absoluteString.removingPercentEncoding else {
            return false
        }
        return urlString.hasPrefix("https://\(Constants.DynamicLink.generalGroupInviteBaseUrl)")
    }

    func isProfileLink(_ url: URL) -> Bool {
        guard let urlString = url.absoluteString.removingPercentEncoding else {
            return false
        }
        return urlString.hasPrefix("https://\(Constants.DynamicLink.profileBaseUrl)")
    }

    func handleGeneralGroupDeepLink(_ url: URL) {
        guard let queryItems = DeeplinkHelper.shared.separateGeneralGroupComponenets(url)
            else { return }
        getChatInviteInfo(groupId: queryItems.groupId ?? "", inviteId: queryItems.inviteCode ?? "") { inviteInfo in
            if inviteInfo?.isMember ?? false {
                showSnackBar(.errorMsg(text: "You are already member of this channel"))
                return
            }
            if TabBarView.ViewModel.shared.selectedTab != 2 {
                TabBarView.ViewModel.shared.selectedTab = 2
            }
            guard let joinGroupVC = JoinGroupRequestVC.instantiateController(
                storyboard: .GroupChat) as? JoinGroupRequestVC else {
                    return
                }
            joinGroupVC.inviteCode = queryItems.inviteCode
            joinGroupVC.cidDescription = queryItems.groupId
            joinGroupVC.channelName = inviteInfo?.channel.name
            joinGroupVC.channelDescription = inviteInfo?.channel.channelDescription
            joinGroupVC.channelAvatar = inviteInfo?.members.compactMap { URL(string: $0.user?.image ?? "")} ?? []
            guard let channelID = try? ChannelId.init(cid: queryItems.groupId ?? "") else { return }
            let channelController = ChatClient.shared.channelController(for: .init(cid: channelID))
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
                    UIApplication.shared.getTopViewController()?.presentPanModal(joinGroupVC)
                }
            }
        }
    }

    func handleProfileLink(_ url: URL) {
        guard let walletAddress = separateProfileComponents(url) else {
            showSnackBar(.errorMsg(text: "Wrong invitation link"))
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismissAll()
            showConfirmation(.qrOptions(result: walletAddress))
        }
    }

    func handleDaoGroupLink(_ url: URL) {
        guard let components = separateDaoComponenets(url) else {
            showSnackBar(.errorMsg(text: "Wrong invitation link"))
            return
        }
        let groupId = components.groupID
        let expireDate = components.expireDate
        // check expire time
        if expireDate.isPastDate {
            showSnackBar(.message(text: "This channel invitation link is expired!"))
            return
        }
        // check channel
        do {
            let channelController = try ChatClient.shared.channelController(for: .init(cid: groupId))
            channelController.synchronize { error in
                guard error == nil else {
                    showSnackBar(.errorMsg(text: "This channel doesn't exist!"))
                    return
                }
                // check for member existence
                let channelMember = ChatClient.shared.memberListController(query: .init(
                    cid: .init(
                        type: .dao,
                        id: channelController.cid?.id ?? "")))
                channelMember.synchronize { [weak self] error in
                    guard let self = self, error == nil else {
                        showSnackBar(.errorMsg(text: "This channel doesn't exist!"))
                        return
                    }
                    let isUserExistInChat = !channelMember.members
                        .filter({ $0.id == ChatClient.shared.currentUserId }).isEmpty
                    if isUserExistInChat {
                        showSnackBar(.errorMsg(text: "You are already member of this channel"))
                    } else {
                        guard self.walletBalance() ?? 0 >=
                                Double(channelController.channel?.extraData.minimumContribution ?? "0") ?? 0 else {
                            showSnackBar(.message(text: "Insufficient balance — pls double check and retry"))
                            return
                        }
                        self.configMinimumAmountTransfer(controller: channelController)
                    }
                }
            }
        } catch {
            showSnackBar(.errorMsg(text: error.localizedDescription))
        }
    }

    private func configMinimumAmountTransfer(controller: ChatChannelController) {
        guard let extraData = controller.channel?.extraData else {
            return
        }
        var sendOneWallet = SendOneWallet()
        sendOneWallet.myName = ChatClient.shared.currentUserController().currentUser?.name
        sendOneWallet.myWalletAddress = ChatClient.shared.currentUserId
        sendOneWallet.recipientName = extraData.daoName ?? ""
        sendOneWallet.recipientAddress = extraData.safeAddress ?? ""
        sendOneWallet.recipientImageUrl = URL(string: extraData.charityThumb ?? "")
        sendOneWallet.myImageUrl = ChatClient.shared.currentUserController().currentUser?.imageURL
        sendOneWallet.transferAmount = Float(extraData.minimumContribution ?? "0")
        sendOneWallet.strFormattedAmount = extraData.minimumContribution
        sendOneWallet.fractionDigits = Decimal(string: extraData.minimumContribution ?? "")?
            .significantFractionalDecimalDigits ?? 0
        showConfirmation(.sendOneConfirmation(walletData: sendOneWallet,
                                              screenType: .daoTransfer,
                                              channel: controller), interactiveHide: false)
    }

    private func separateDaoComponenets(_ url: URL) -> (groupID: String, expireDate: Date)? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        guard let items = components?.queryItems,
              let groupID = items.first(where: { $0.name == "id"})?.value?.base64Decoded?.string,
              let strExpiry = items.first(where: { $0.name == "expiry"})?.value?.base64Decoded?.string else {
                  return nil
              }
        let expiredTime = Date(timeIntervalSince1970: (strExpiry as NSString).doubleValue)
        return (groupID, expiredTime)
    }

    private func separateProfileComponents(_ url: URL) -> String? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        guard let items = components?.queryItems,
              let walletAddress = items.first(where: { $0.name == "walletAddress"})?.value else {
                  return nil
              }
        return walletAddress
    }

    func separateGeneralGroupComponenets(_ url: URL) -> (inviteCode: String?, groupId: String?)? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        guard let items = components?.queryItems,
              let inviteCode = items.first(where: { $0.name == "invite_code"})?.value,
              let groupId = items.first(where: { $0.name == "group_id"})?.value else {
                  return nil
              }
        return (inviteCode, groupId)
    }

    private func walletBalance() -> Double? {
        guard let currentWallet = Wallet.currentWallet,
                let walletAddress = EthereumAddress(currentWallet.address.convertBech32ToEthereum()) else { return nil }
        do {
            let balance: BigUInt = try Web3Service.shared.getBalance(at: walletAddress)
            let dblBalance = Web3Service.shared.amountFromWeiUnit(amount: balance, weiUnit: OneWalletService.weiUnit)
            return dblBalance
        } catch {
            return nil
        }
    }

    private func getChatInviteInfo(groupId: String, inviteId: String, completion: ((ChatInviteInfo?) -> Void)?) {
        IdentityService.shared.getChatInvite(req: .init(groupId: groupId, inviteId: inviteId))
            .sink { result in
                switch result {
                case .success(let response):
                    completion?(response)
                case .failure:
                    showSnackBar(.somethingWentWrongRandomText)
                }
            }
            .store(in: &currentNetworkCalls)
    }
}
