//
//  GroupUserCell.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 02/12/21.
//

import UIKit
import Nuke
import StreamChat
import StreamChatUI

class GroupUserCell: UICollectionViewCell {
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var avatarView: AvatarView!

    func configCell(user: ChatUser) {
        if let imageURL = user.imageURL {
            Nuke.loadImage(with: imageURL, into: avatarView)
        }
        //avatarView.backgroundColor = .blue
        nameLabel.text = (user.name ?? user.id).capitalizingFirstLetter()
        nameLabel.setChatSubtitleBigColor()
    }
}
