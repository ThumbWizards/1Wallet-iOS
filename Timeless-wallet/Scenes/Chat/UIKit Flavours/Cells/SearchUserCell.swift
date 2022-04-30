//
//  SearchUserCell.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 02/12/21.
//

import UIKit
import StreamChat
import Nuke
import StreamChatUI

class SearchUserCell: UITableViewCell {
    @IBOutlet private var mainStackView: UIStackView! {
        didSet {
            mainStackView.isLayoutMarginsRelativeArrangement = true
        }
    }
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var avatarView: AvatarView!
    @IBOutlet private var accessoryImageView: UIImageView!

    var user: ChatUser?
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    func configCell(user: ChatUser, selectedUsers: [ChatUser], tintColor: UIColor) {
        if let imageURL = user.imageURL {
            Nuke.loadImage(with: imageURL, into: avatarView)
        }
        avatarView.backgroundColor = tintColor
        nameLabel.text = user.name ?? user.id
        if let lastActive = user.lastActiveAt {
            descriptionLabel.text = "Last seen: " + formatter.string(from: lastActive)
        } else {
            descriptionLabel.text = "Never seen"
        }
        if selectedUsers.contains(where: { $0.id == user.id }) {
            accessoryImageView.image = .systemCheckmarkCircle
        } else {
            accessoryImageView.image = nil
        }
        self.user = user
    }

    func select() {
        guard accessoryImageView.image == nil else {
            // The cell isn't selected
            // De-select user by tapping functionality was removed due to designer feedback
            return
        }
        // Select user
        accessoryImageView.image = .systemCheckmarkCircle
    }

    func deselect() {
        accessoryImageView.image = nil
    }
}
