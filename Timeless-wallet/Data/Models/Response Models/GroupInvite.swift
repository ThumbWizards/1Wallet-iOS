//
//  GroupInvite.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 18/04/22.
//

import Foundation

struct GroupInvite: Codable {
    let inviteId: String?
    let groupId: String?
    let endTime: String?
    let dynamicLink: String?

    enum CodingKeys: String, CodingKey {
        case inviteId = "invite_id"
        case groupId = "group_id"
        case endTime = "end_time"
        case dynamicLink = "dynamic_link"
    }
}
