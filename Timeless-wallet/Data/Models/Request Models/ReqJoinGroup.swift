//
//  ReqJoinGroup.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 19/04/22.
//

import Foundation

class ReqJoinGroup {

    var groupId: String?
    var inviteId: String?

    init(groupId: String, inviteId: String) {
        self.groupId = groupId
        self.inviteId = inviteId
    }

    func toDictionary() -> [String: Any] {
        var dictOut = [String: Any]()
        dictOut["group_id"] = groupId
        dictOut["invite_id"] = inviteId
        return dictOut
    }
}
