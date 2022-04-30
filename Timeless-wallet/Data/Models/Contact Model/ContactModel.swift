//
//  ContactModel.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 1/24/22.
//

import Foundation
import SwiftUI

struct ContactModel: Codable, Equatable, Hashable {
    var name: String
    var username: String?
    var walletAddress: String
    var avatar: String?
    var created: Date
    var updated: Date

    var displayAvatar: String {
        avatar ?? "\(Constants.URLImageContact.url)/\(walletAddress)/"
    }

    func avatarView(_ size: CGSize) -> AnyView {
        let image = MediaResourceModel(path: displayAvatar,
                                       altText: nil,
                                       pathPrefix: nil,
                                       mediaType: nil,
                                       thumbnail: nil)
        return MediaResourceView(for: MediaResource(for: image,
                                                       targetSize: TargetSize(width: Int(size.width),
                                                                              height: Int(size.height))),
                                    placeholder: WalletPlaceHolder(cornerRadius: .zero)
                                        .eraseToAnyView(),
                                    isPlaying: .constant(true))
            .scaledToFill()
            .frame(size)
            .cornerRadius(.infinity)
            .eraseToAnyView()
    }
}
