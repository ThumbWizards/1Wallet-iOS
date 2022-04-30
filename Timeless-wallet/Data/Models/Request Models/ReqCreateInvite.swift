//
//  ReqCreateInvite.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 15/04/22.
//

import Foundation

class ReqCreateInvite {

    // MARK: - Variables
    var groupId: String?
    var endTime: String?

    // MARK: - Init
    init(groupId: String, endTime: String? = nil) {
        self.groupId = groupId
        self.endTime = endTime
    }

    // MARK: - Functions
    func toDictionary() -> [String: Any] {
        var dictOut = [String: Any]()
        dictOut["group_id"] = groupId
        dictOut["endTime"] = endTime
        return dictOut
    }
}
