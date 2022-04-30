//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Nuke
import StreamChat
import StreamChatUI
import UIKit
import web3swift

class CreateChatViewController: UIViewController {
    // MARK: - OUTLETS
    @IBOutlet private weak var safeAreaHeight: NSLayoutConstraint!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var searchFieldStack: UIStackView!
    @IBOutlet private var searchBarContainerView: UIView!
    @IBOutlet private var tableviewContainerView: UIView!
    @IBOutlet private var searchField: UITextField!
    @IBOutlet private weak var btnBack: UIButton!
    @IBOutlet private weak var btnCreateDao: UIButton!
    @IBOutlet private weak var btnCreateDaoLeading: NSLayoutConstraint!

    // MARK: - VARIABLES
    var searchController: ChatUserSearchController!
    var chatClient: ChatClient?
    lazy var chatUserList: ChatUserListVC = {
        let obj = ChatUserListVC.instantiateController(storyboard: .GroupChat) as? ChatUserListVC
        return obj!
    }()
    private var currentSortType: Em_ChatUserListFilterTypes = .sortByLastSeen

    // MARK: - VIEW CYCEL
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
        Utils.hideTabbar()
    }

    // MARK: - METHODS
    private func setup() {
        safeAreaHeight.constant = UIView.safeAreaTop
        titleLabel.setChatNavTitleColor()
        self.view.backgroundColor = Appearance.default.colorPalette.chatViewBackground
        tableviewContainerView.backgroundColor = Appearance.default.colorPalette.chatViewBackground
        searchBarContainerView.backgroundColor = Appearance.default.colorPalette.searchBarBackground
        searchBarContainerView.layer.cornerRadius = 20.0
        btnBack.setTitle("", for: .normal)
        searchField.delegate = self
        searchField.setAttributedPlaceHolder(placeHolder: "Search")
        searchField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        Utils.hideTabbar()
        setupChatUserList()

        // Todo: hide Dao feature for now
        btnCreateDao.isHidden = true
        btnCreateDaoLeading.constant = -28
    }

    private func setupChatUserList() {
        chatUserList.sortType = self.currentSortType
        chatUserList.currentSectionType = .createChatHeader
        addChild(chatUserList)
        tableviewContainerView.addSubview(chatUserList.view)
        chatUserList.view.frame = tableviewContainerView.bounds
        chatUserList.didMove(toParent: self)
        tableviewContainerView.updateChildViewContraint(childView: chatUserList.view)
        chatUserList.viewModel.fetchUserList()
        // callback
        chatUserList.bCallbackGroupCreate = { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.openCreateGroupChat()
        }
        chatUserList.bCallbackGroupSelect = { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.btnSelectGroupAction()
        }
        chatUserList.bCallbackGroupWeHere = { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.btnPrivateGroupAction()
        }
        chatUserList.bCallbackGroupJoinViaQR = { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.btnJoinGroupViaQRAction()
        }
    }

    @objc private func textDidChange(_ sender: UITextField) {
        if let searchText = sender.text, searchText.isEmpty == false {
            if searchText.containsEmoji || searchText.isBlank {
                return
            }
            self.chatUserList.viewModel.searchDataUsing(searchString: sender.text)
        } else {
            self.chatUserList.viewModel.refreshUserList()
        }
    }

    // MARK: - Actions
    @IBAction private func btnBackAction(_ sender: UIButton) {
        Utils.showTabbar()
        popWithAnimation()
    }

    @IBAction private func btnSortUserListAction(_ sender: UIButton) {
        guard chatUserList.viewModel.dataLoadingState == .completed else {
            return
        }
        if currentSortType == .sortByLastSeen {
            currentSortType = .sortByName
        } else {
            currentSortType = .sortByLastSeen
        }
        chatUserList.sortUserListAction(sortType: currentSortType)
    }

    @IBAction private func daoTapped(_ sender: Any) {
        Utils.playHapticEvent()
        showConfirmation(.daoTemplates)
    }

    private func openCreateGroupChat() {
        guard let createGroupController: CreateGroupViewController = CreateGroupViewController.instantiate(
            appStoryboard: .chat) else {
            return
        }
        createGroupController.searchController = chatClient?.userSearchController()
        self.pushWithAnimation(controller: createGroupController)
    }
    // Todo
    private func btnSelectGroupAction() { }
    
    private func btnPrivateGroupAction() {
        guard let privateGroupOTPVC = PrivateGroupOTPVC.instantiateController(storyboard: .PrivateGroup) else {
            return
        }
        self.pushWithAnimation(controller: privateGroupOTPVC)
    }

    private func btnJoinGroupViaQRAction() {
        let view = QRCodeReaderView()
        view.screenType = .joinGroup
        view.onScanSuccess = { [weak self] strUrl in
            guard let url = URL(string: strUrl),
                  let self = self else {
                return
            }
            DeeplinkHelper.shared.extractActualLink(url) { linkUrl in
                guard let linkUrl = linkUrl else {
                    return
                }
                if DeeplinkHelper.shared.isDaoGroupLink(linkUrl) {
                    DeeplinkHelper.shared.handleDaoGroupLink(linkUrl)
                } else if DeeplinkHelper.shared.isGeneralGroupLink(linkUrl) {
                    DeeplinkHelper.shared.handleGeneralGroupDeepLink(linkUrl)
                }
            }
        }
        if let topVc = UIApplication.shared.getTopViewController() {
            view.modalPresentationStyle = .fullScreen
            topVc.present(view, animated: true)
        }
    }
}
// MARK: - UITextFieldDelegate
extension CreateChatViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
