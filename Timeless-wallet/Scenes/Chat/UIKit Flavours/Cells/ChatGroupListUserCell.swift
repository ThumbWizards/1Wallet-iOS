//
//  ChatGroupListUserCell.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 02/12/21.
//

import UIKit
import StreamChat
import StreamChatUI
import Nuke

class ChatGroupListUserCell: UITableViewCell {

    // MARK: - Variables
    static let reuseIdentifier = String(describing: self)
    private let avatarView = AvatarView()
    private let nameLabel = UILabel()
    private let removeButton = UIButton()
    var removeBtnTouchAction: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Functions
    private func setupUI() {
        self.selectionStyle = .none
        [avatarView, nameLabel, removeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        removeButton.tintColor = .white
        nameLabel.clipsToBounds = true
        removeButton.setImage(.xmas, for: .normal)
        removeButton.imageView?.contentMode = .scaleAspectFit
        removeBtnTapAction()
        NSLayoutConstraint.activate([
            // AvatarView
            avatarView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
            avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentView.layoutMargins.top),
            avatarView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -contentView.layoutMargins.bottom),
            avatarView.heightAnchor.constraint(equalToConstant: 40),
            avatarView.widthAnchor.constraint(equalTo: avatarView.heightAnchor),
            // NameLabel
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: contentView.layoutMargins.left),
            nameLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            // removeButton
            removeButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -contentView.layoutMargins.right),
            removeButton.widthAnchor.constraint(equalToConstant: 30),
            removeButton.heightAnchor.constraint(equalToConstant: 30),
            removeButton.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor)
        ])
    }

    func configCell(user: ChatUser) {
        if let imageURL = user.imageURL {
            Nuke.loadImage(with: imageURL, into: avatarView)
        }
        nameLabel.text = user.name
    }

    private func removeBtnTapAction() {
        removeButton.addTarget(self, action: #selector(removeBtnTouchUpInside), for: .touchUpInside)
    }

    @objc private func removeBtnTouchUpInside() {
        removeBtnTouchAction?()
    }
}
