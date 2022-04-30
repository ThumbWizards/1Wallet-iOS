//
//  JoinGroup.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 19/04/22.
//

import StreamChat

// MARK: - JoinGroupElement
struct JoinGroupElement: Codable {
    let banned, shadowBanned: Bool?
    let createdAt, role, channelRole, userID: String?
    let updatedAt: String?
    let user: InviteUser?

    enum CodingKeys: String, CodingKey {
        case banned
        case shadowBanned = "shadow_banned"
        case createdAt = "created_at"
        case role
        case channelRole = "channel_role"
        case userID = "user_id"
        case updatedAt = "updated_at"
        case user
    }
}


typealias JoinGroup = [JoinGroupElement]
