//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Foundation
import Nuke
import StreamChat
import UIKit

class NameGroupViewController: UIViewController {

    var client: ChatClient?
    private(set) lazy var headerSafeAreaView = UIView(frame: .zero)
    private(set) lazy var headerView = UIView(frame: .zero)
    private let mainStackView = UIStackView()
    private let searchStackView = UIStackView()
    private let promptLabel = UILabel()
    private let nameField = UITextField()
    private let tableView = UITableView()
    private var doneButton = UIButton()
    private var backButton = UIButton()
    private var lblTitle = UILabel()
    var selectedUsers: [ChatUser]!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraint()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.hideTabbar()
    }

    func setupUI() {
        headerSafeAreaView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.tintColor = .white
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.tintColor = .white
        lblTitle.translatesAutoresizingMaskIntoConstraints = false
        lblTitle.textAlignment = .center
        headerSafeAreaView.backgroundColor = .tabBackgroundColor
        headerView.backgroundColor = .tabBackgroundColor
        navigationController?.navigationBar.isHidden = true
        lblTitle.textColor = .white
        backButton.setImage(.backSheet, for: .normal)
        backButton.addTarget(self, action: #selector(backBtnTapped), for: .touchUpInside)
        doneButton.setImage(.init(systemName: "arrow.right"), for: .normal)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        view.backgroundColor = .systemBackground
        lblTitle.text = "Name of Group Chat"
        promptLabel.text = "NAME"
        promptLabel.font = .systemFont(ofSize: 12, weight: .light)
        nameField.placeholder = "Name the group"

        tableView.register(ChatGroupListUserCell.self, forCellReuseIdentifier: ChatGroupListUserCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.bounces = false
        // An old trick to force the table view to hide empty lines
        tableView.tableFooterView = UIView()
        tableView.reloadData()
        self.nameField.becomeFirstResponder()
    }

    func setupConstraint() {
        view.addSubview(headerSafeAreaView)
        NSLayoutConstraint.activate([
            headerSafeAreaView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            headerSafeAreaView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            headerSafeAreaView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            headerSafeAreaView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0)
        ])

        view.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            headerView.topAnchor.constraint(equalTo: headerSafeAreaView.bottomAnchor, constant: 0),
            headerView.heightAnchor.constraint(equalToConstant: 44)
        ])

        headerView.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 8),
            backButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0),
            backButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0),
            backButton.widthAnchor.constraint(equalToConstant: 36)
        ])

        headerView.addSubview(doneButton)
        NSLayoutConstraint.activate([
            doneButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -8),
            doneButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0),
            doneButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0),
            doneButton.widthAnchor.constraint(equalToConstant: 36)
        ])

        headerView.addSubview(lblTitle)
        NSLayoutConstraint.activate([
            lblTitle.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            lblTitle.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            lblTitle.trailingAnchor.constraint(equalTo: doneButton.leadingAnchor, constant: -8),
        ])
        view.addSubview(mainStackView)
        mainStackView.axis = .vertical
        mainStackView.addArrangedSubview(searchStackView)
        mainStackView.addArrangedSubview(tableView)
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchStackView.heightAnchor.constraint(equalToConstant: 56),
            mainStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            mainStackView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            mainStackView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor)
        ])
        searchStackView.axis = .horizontal
        searchStackView.distribution = .fillProportionally
        searchStackView.alignment = .fill
        searchStackView.spacing = 16
        searchStackView.addArrangedSubview(promptLabel)
        searchStackView.addArrangedSubview(nameField)

    }

    @objc private func backBtnTapped() {
        Utils.hideTabbar()
        self.nameField.resignFirstResponder()
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func doneTapped() {
        guard let name = nameField.text, !name.isEmpty else {
            presentAlert(title: "Name cannot be empty")
            return
        }
        do {
            let channelController = try client?.channelController(
                createChannelWithId: .init(type: .messaging, id: String(UUID().uuidString.prefix(10))),
                name: name,
                members: Set(selectedUsers.map(\.id)))
            channelController?.synchronize { [weak self] error in
                guard let weakSelf = self else {
                    return
                }
                if let error = error {
                    weakSelf.presentAlert(title: "Error when creating the channel", message: error.localizedDescription)
                } else {
                    weakSelf.navigationController?.popToRootViewController(animated: true)
                }
            }
        } catch {
            presentAlert(title: "Error when creating the channel", message: error.localizedDescription)
        }
    }
}

extension NameGroupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        selectedUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ChatGroupListUserCell.reuseIdentifier)
                as? ChatGroupListUserCell else {
            return UITableViewCell()
        }
        let user = selectedUsers[indexPath.row]
        cell.configCell(user: user)
        cell.removeBtnTouchAction = { [weak self] in
            guard let self = self else { return }
            if let index = self.selectedUsers.firstIndex(of: user) {
                self.selectedUsers.remove(at: index)
                if self.selectedUsers.isEmpty {
                    self.doneButton.isEnabled = false
                }
                tableView.performBatchUpdates {
                    tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
            }
        }
        return cell
    }
}
