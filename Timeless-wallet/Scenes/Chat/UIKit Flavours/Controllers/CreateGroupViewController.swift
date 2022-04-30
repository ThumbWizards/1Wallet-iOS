//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Foundation
import Nuke
import StreamChat
import StreamChatUI
import UIKit

class CreateGroupViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private weak var btnBack: UIButton!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var selectedUsersStackView: UIStackView! {
        didSet {
            selectedUsersStackView.isLayoutMarginsRelativeArrangement = true
        }
    }
    @IBOutlet private var searchFieldStack: UIStackView!
    @IBOutlet private var searchBarContainerView: UIView!
    @IBOutlet private var tableviewContainerView: UIView!
    @IBOutlet private var searchField: UITextField!
    @IBOutlet private var mainStackView: UIStackView!
    @IBOutlet private var infoLabel: UILabel!
    @IBOutlet private var infoLabelContainerView: UIView!
    @IBOutlet private var selectedUsersCollectionView: UICollectionView!
    @IBOutlet private weak var btnNext: UIButton!
    @IBOutlet private var lblAddedUser: UILabel!
    @IBOutlet private var viewAddedUserLabelContainer: UIView!
    @IBOutlet private weak var btnCreateDao: UIButton!
    @IBOutlet private weak var btnCreateDaoLeading: NSLayoutConstraint!
    @IBOutlet private weak var heightSafeAreaView: NSLayoutConstraint!
    @IBOutlet private weak var nextButtonBottomConstraint: NSLayoutConstraint!

    // MARK: - Variables
    var searchController: ChatUserSearchController!
    private var selectedUsers = [ChatUser]()
    public lazy var chatUserList: ChatUserListVC = {
        let obj = ChatUserListVC.instantiateController(storyboard: .GroupChat) as? ChatUserListVC
        return obj!
    }()
    private var curentSortType: Em_ChatUserListFilterTypes = .sortByLastSeen
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
        Utils.hideTabbar()
    }
    // MARK: - IB Action
    @IBAction private func btnBackAction(_ sender: Any) {
        Utils.hideTabbar()
        popWithAnimation()
    }

    @IBAction private func btnNextAction(_ sender: UIButton) {
        nextTapped()
    }

    @IBAction private func daoTapped(_ sender: Any) {
        Utils.playHapticEvent()
        showConfirmation(.daoTemplates)
    }

    // MARK: - Functions
    private func setupUI() {
        heightSafeAreaView.constant = UIView.safeAreaTop
        nextButtonBottomConstraint.constant = (-20) + (-UIView.safeAreaBottom)
        titleLabel.setChatNavTitleColor()
        self.view.backgroundColor = Appearance.default.colorPalette.chatViewBackground
        searchBarContainerView.backgroundColor = Appearance.default.colorPalette.searchBarBackground
        searchBarContainerView.layer.cornerRadius = 20.0
        btnBack.setTitle("", for: .normal)
        btnNext.isHidden = true
        lblAddedUser.text = ""
        viewAddedUserLabelContainer.isHidden = true
        searchField.delegate = self
        searchField.setAttributedPlaceHolder(placeHolder: "Search")
        searchField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        // setting chat user list
        setupChatUserListController()
        // setting collection layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 88)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        selectedUsersCollectionView.isHidden = true
        selectedUsersCollectionView.dataSource = self
        selectedUsersCollectionView.delegate = self
        selectedUsersCollectionView.collectionViewLayout = layout
        infoLabel.text = self.curentSortType.getTitle
        infoLabelContainerView.isHidden = true
        // Todo: hide Dao feature for now
        btnCreateDao.isHidden = true
        btnCreateDaoLeading.constant = -28
    }

    private func setupChatUserListController() {
        chatUserList.delegate = self
        chatUserList.userSelectionType = .group
        addChild(chatUserList)
        tableviewContainerView.addSubview(chatUserList.view)
        chatUserList.didMove(toParent: self)
        tableviewContainerView.updateChildViewContraint(childView: chatUserList.view)
        // setting callback
        chatUserList.bCallbackDataLoadingStateUpdated = { [weak self] loadingState in
            guard let weakSelf = self else { return }
            DispatchQueue.main.async {
                weakSelf.configureUI(loadingState: loadingState)
            }
        }
        // fetching user list
        chatUserList.viewModel.fetchUserList()
    }

    private func configureUI(loadingState: UserListViewModel.ChatUserLoadingState) {
        switch loadingState {
        case .completed:
            infoLabelContainerView.isHidden = chatUserList.viewModel.filteredUsers.isEmpty
            if searchField.text?.isEmpty ?? true {
                showSelectedUsers(!selectedUsers.isEmpty)
            }
        default:
            viewAddedUserLabelContainer.isHidden = true
            selectedUsersCollectionView.isHidden = true
            infoLabelContainerView.isHidden = true
        }
    }

    @objc private func textDidChange(_ sender: UITextField) {
        if let searchText = sender.text, searchText.isEmpty == false {
            if searchText.containsEmoji || searchText.isBlank {
                return
            }
            chatUserList.viewModel.searchDataUsing(searchString: sender.text)
        } else {
            chatUserList.viewModel.refreshUserList()
            showSelectedUsers(!selectedUsers.isEmpty)
        }
    }

    private func nextTapped() {
        guard let nameGroupController: NameGroupViewController = NameGroupViewController
                .instantiateController(storyboard: .GroupChat) else {
            return
        }
        nameGroupController.bCallbackSelectedUsers = { [weak self] arrUsers in
            guard let weakSelf = self else { return }
            weakSelf.selectedUsers = arrUsers
            weakSelf.showSelectedUsers(!weakSelf.selectedUsers.isEmpty)
            weakSelf.selectedUsersCollectionView.reloadData()
            weakSelf.chatUserList.viewModel.selectedUsers = weakSelf.selectedUsers
            weakSelf.chatUserList.reloadData()
        }
        nameGroupController.selectedUsers = selectedUsers
        nameGroupController.client = searchController.client
        Utils.hideTabbar()
        self.pushWithAnimation(controller: nameGroupController)
    }

    private func showSelectedUsers(_ show: Bool) {
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.lblAddedUser.text = show ? "ADDED" : ""
            weakSelf.viewAddedUserLabelContainer.isHidden = !show
            weakSelf.selectedUsersCollectionView.isHidden = !show
            weakSelf.btnNext.isHidden = !show
            weakSelf.view.layoutIfNeeded()
        }
    }
}

// MARK: - CollectionView delegate
extension CreateGroupViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        selectedUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "GroupUserCell",
            for: indexPath) as? GroupUserCell else {
            return UICollectionViewCell()
        }
        cell.configCell(user: selectedUsers[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedUsers.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
        showSelectedUsers(!selectedUsers.isEmpty)
        self.chatUserList.viewModel.selectedUsers = self.selectedUsers
        self.chatUserList.reloadData()
    }
}

// MARK: - ChatUserListDelegate
extension CreateGroupViewController: ChatUserListDelegate {
    func chatUserDidSelect() {
        self.selectedUsers = self.chatUserList.viewModel.selectedUsers
        showSelectedUsers(!selectedUsers.isEmpty)
        selectedUsersCollectionView.reloadData()
        guard self.selectedUsers.count > 1 else {
            return
        }
        let lastIndexPath = IndexPath(item: self.selectedUsers.count - 1, section: 0)
        selectedUsersCollectionView.scrollToItem(at: lastIndexPath, at: .right, animated: true)
    }
}
// MARK: - UITextFieldDelegate
extension CreateGroupViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
