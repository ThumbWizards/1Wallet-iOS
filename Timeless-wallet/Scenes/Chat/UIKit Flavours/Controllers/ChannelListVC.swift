//
//  ChannelListVC.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 26/10/21.
//

import UIKit
import StreamChat
import StreamChatUI
import SwiftUI
import Combine
import Lottie
import web3swift
import BigInt
import SkeletonView

class ChannelListVC: ChatChannelListVC {

    // MARK: - Variables
    var viewModel = ChannelListViewModel()
    private var viewEmptyState: UIView?
    private var animationView: AnimationView!
    private var currentNetworkCalls = Set<AnyCancellable>()
    private var avatarSelectorView: UIView!

    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Initialise skeleton appearance
        SkeletonAppearance.Settings.setShimmerEffect()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animationView.play()
        Utils.showTabbar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animationView.pause()
    }

    override func setUpLayout() {
        super.setUpLayout()
        setupCollectionView()
    }

    // MARK: - Channel Delegates
    override func controller(_ controller: ChatChannelListController, shouldListUpdatedChannel channel: ChatChannel) -> Bool {
        if channel.type == .announcement {
            return true
        }
        viewEmptyState?.isHidden = !controller.channels.isEmpty
        return channel.lastActiveMembers.contains(where: { $0.id == controller.client.currentUserId })
    }

    override func controller(_ controller: ChatChannelListController, shouldAddNewChannelToList channel: ChatChannel) -> Bool {
        if channel.type == .announcement {
            return true
        }
        return channel.lastActiveMembers.contains(where: { $0.id == controller.client.currentUserId })
    }

    override func controller(_ controller: DataController, didChangeState state: DataController.State) {
        super.controller(controller, didChangeState: state)
        if state != .initialized && viewEmptyState != nil {
            viewEmptyState?.isHidden = !self.controller.channels.isEmpty
        }
    }

    override func controllerWillChangeChannels(_ controller: ChatChannelListController) {
        super.controllerWillChangeChannels(controller)
        viewEmptyState?.isHidden = !self.controller.channels.isEmpty
    }

    override func controller(_ controller: ChatChannelListController, didChangeChannels changes: [ListChange<ChatChannel>]) {
        super.controller(controller, didChangeChannels: changes)
        viewEmptyState?.isHidden = !self.controller.channels.isEmpty
    }

    // MARK: - Functions
    func setupUI() {
        initClosures()
        observeEvents()
        setupEmptyState()
        viewEmptyState?.isHidden = true
        self.router = ChatRouter(rootViewController: self)
        lblTitle.text = Wallet.currentWallet?.nameFullAlias
        lblTitle.textAlignment = .center
        view.backgroundColor = Appearance.default.colorPalette.chatViewBackground
    }

    private func initClosures() {
        createChannelAction = { [weak self] in
            guard let weakSelf = self else {
                return
            }
            guard let createChatViewController = CreateChatViewController
                    .instantiate(appStoryboard: .chat) as? CreateChatViewController else {
                return
            }
            createChatViewController.chatClient = weakSelf.controller.client
            weakSelf.pushWithAnimation(controller: createChatViewController)
        }
    }

    private func observeEvents() {
        NotificationCenter.default.removeObserver(self, name: .sendOneWalletTapAction, object: nil)
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .sendOneAction, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sendOneWalletTapAction(_:)),
            name: .sendOneWalletTapAction,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reachabilityChanged),
            name: .reachabilityChanged,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sendOneAction(_:)),
            name: .sendOneAction,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showActivityAction(_:)),
            name: .showActivityAction,
            object: nil)
    }

    @objc private func reachabilityChanged() {
        self.setUp()
    }

    @objc private func sendOneWalletTapAction(_ notification: NSNotification) {
        guard NetworkHelper.shared.reachability?.connection != Reachability.Connection.none else {
            showSnackBar(.internetConnectionError)
            return
        }
        guard let channelId = notification.userInfo?["channelId"] as? ChannelId else {
            return
        }
        let controller = controller.client.memberListController(query: .init(cid: channelId))
        controller.synchronize { [weak self] error in
            guard error == nil, let weakSelf = self else { return }
            let chatMembers = controller.members.filter({ (member: ChatChannelMember) -> Bool in
                return member.id != controller.client.currentUserId
            })
            if chatMembers.count > 1 {
                // more than 2 people including me
                weakSelf.handleGroupChat(controller, notification: notification)
            } else {
                // 1-1 chat
                weakSelf.handleOneToOneChat(members: chatMembers)
            }
        }
    }

    @objc private func showActivityAction(_ notification: NSNotification) {
        guard let activityImages = notification.userInfo?["image"] as? UIImage,
              let groupName = notification.userInfo?["groupName"] as? String
        else {
            return
        }

        let activityViewController = UIActivityViewController(
            activityItems: [activityImages, MyActivityItemSource(title: groupName, text: "")],
            applicationActivities: nil
        )
        UIApplication.shared.getTopViewController()?.present(activityViewController, animated: true, completion: nil)

    }

    @objc private func sendOneAction(_ notification: NSNotification) {
        guard NetworkHelper.shared.reachability?.connection != Reachability.Connection.none else {
            showSnackBar(.internetConnectionError)
            return
        }
        guard let channelId = notification.userInfo?["channelId"] as? ChannelId,
              let currencyValue = notification.userInfo?["currencyValue"] as? String,
              let walletBalance = Wallet.currentWallet?.detailViewModel.overviewModel.totalONEAmount
        else {
            return
        }
        if walletBalance < (Double(currencyValue) ?? 0) {
            showSnackBar(.insufficientBalance(name: WalletInfo.shared.currentWallet.name ?? ""))
        } else {
            let controller = controller.client.memberListController(query: .init(cid: channelId))
            controller.synchronize { [weak self] error in
                guard error == nil, let weakSelf = self else { return }
                let chatMembers = controller.members.filter({ (member: ChatChannelMember) -> Bool in
                    return member.id != controller.client.currentUserId
                })
                if chatMembers.count > 1 {
                    // TODO: - Need to handle flow for group chat
                    weakSelf.handleGroupChat(controller, notification: notification)
                } else {
                    // 1-1 chat
                    guard let recipient = chatMembers.first else {
                        showSnackBar(.message(text: "Channel must contain more than one user to enable Send feature"))
                        return
                    }
                    weakSelf.sendChatMemberONEAction(recipient: recipient, notification: notification)
                }
            }
        }
    }

    func sendChatMemberONEAction(recipient: ChatChannelMember, notification: NSNotification) {
        guard let currencyValue = notification.userInfo?["currencyValue"] as? String,
              let currencyDisplay = notification.userInfo?["currencyDisplay"] as? String,
              let channelId = notification.userInfo?["channelId"] as? ChannelId
        else {
            return
        }
        self.viewModel.bindWalletData(recipient)
        self.viewModel.oneWallet.transferAmount = Float(currencyValue)
        self.viewModel.oneWallet.strFormattedAmount = currencyDisplay
        self.viewModel.oneWallet.channelId = channelId
        self.viewModel.oneWallet.fractionDigits = Decimal(
            string: "\(currencyValue)"
        )?.significantFractionalDecimalDigits ?? 0
        let paymentTheme = notification.userInfo?["paymentTheme"] as? String ??
            WalletAttachmentPayload.PaymentTheme.none.getPaymentThemeUrl()
        self.viewModel.oneWallet.paymentTheme = paymentTheme
        showConfirmation(.sendOneConfirmation(
            walletData: self.viewModel.oneWallet,
            screenType: .send,
            channel: nil
        ), interactiveHide: false)
    }

    private func handleOneToOneChat(members: [ChatChannelMember]) {
        guard let recipient = members.first else {
            showSnackBar(.message(text: "Channel must contain more than one user to enable Send feature"))
            return
        }
        viewModel.bindWalletData(recipient)
        let paymentVC = SendPaymentVC(oneWallet: viewModel.oneWallet)
        present(paymentVC, animated: true)
    }

    private func handleGroupChat(_ controller: ChatChannelMemberListController, notification: NSNotification) {
        let recipientVC = RecipientListVC(memberList: controller) { [weak self] recipient in
            guard let `self` = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let `self` = self else { return }
                self.sendChatMemberONEAction(recipient: recipient, notification: notification)
            }
        }
        self.presentPanModal(recipientVC)
    }
}

// MARK: - setup layout
extension ChannelListVC {
    private func setupCollectionView() {
        let walletSelectorController = UIHostingController(rootView: WalletSelectorView())
        addChild(walletSelectorController)
        userAvatarView.isHidden = true
        walletSelectorController.view.translatesAutoresizingMaskIntoConstraints = false
        walletSelectorController.didMove(toParent: self)
        view.insertSubview(walletSelectorController.view, aboveSubview: userAvatarView)
        NSLayoutConstraint.activate([
            walletSelectorController.view.leadingAnchor.constraint(equalTo: userAvatarView.leadingAnchor),
            walletSelectorController.view.trailingAnchor.constraint(equalTo: userAvatarView.trailingAnchor),
            walletSelectorController.view.topAnchor.constraint(equalTo: userAvatarView.topAnchor),
            walletSelectorController.view.bottomAnchor.constraint(equalTo: userAvatarView.bottomAnchor)
        ])
        walletSelectorController.view.backgroundColor = .clear
    }

    private func setupEmptyState() {
        viewEmptyState = UIView()
        guard let viewEmptyState = viewEmptyState else { return }
        view.addSubview(viewEmptyState)
        viewEmptyState.translatesAutoresizingMaskIntoConstraints = false
        viewEmptyState.backgroundColor = .clear
        viewEmptyState.translatesAutoresizingMaskIntoConstraints = false
        viewEmptyState.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        viewEmptyState.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        viewEmptyState.heightAnchor.constraint(equalToConstant: 400).isActive = true
        viewEmptyState.widthAnchor.constraint(equalToConstant: 400).isActive = true

        animationView = .init(name: "chatEmptyState")
        animationView.frame = viewEmptyState.bounds
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        viewEmptyState.addSubview(animationView!)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        animationView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        animationView.centerXAnchor.constraint(equalTo: viewEmptyState.centerXAnchor).isActive = true
        animationView.centerYAnchor.constraint(equalTo: viewEmptyState.centerYAnchor).isActive = true
        animationView.play()

        let lblChat = UILabel()
        lblChat.text = "Start Chatting!"
        lblChat.font = .systemFont(ofSize: 18)
        lblChat.textColor = UIColor.timelessBlue
        viewEmptyState.addSubview(lblChat)
        lblChat.translatesAutoresizingMaskIntoConstraints = false
        lblChat.centerXAnchor.constraint(equalTo: viewEmptyState.centerXAnchor, constant: 0).isActive = true
        lblChat.bottomAnchor.constraint(equalTo: animationView!.topAnchor, constant: -30).isActive = true
    }
}
