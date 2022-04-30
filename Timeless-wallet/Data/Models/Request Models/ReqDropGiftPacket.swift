//
//  ReqDropGiftPacket.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 07/12/21.
//

class ReqDropGiftPacket {

    // MARK: - Variables
    var title: String?
    var minAmount: String?
    var maxAmount: String?
    var recipientsCap: Int?
    var endTime: String?
    var chatRoomId: String?
    var creatorAddress: String?

    // MARK: - Functions
    func toDictionary() -> [String: Any] {
        var dictOut = [String: Any]()
        if let title = title {
            dictOut["title"] = title
        }
        if let minAmount = minAmount {
            dictOut["min_amount"] = minAmount
        }
        if let maxAmount = maxAmount {
            dictOut["max_amount"] = maxAmount
        }
        if let recipientsCap = recipientsCap {
            dictOut["recipients_cap"] = recipientsCap
        }
        if let endTime = endTime {
            dictOut["end_time"] = endTime
        }
        if let chatRoomId = chatRoomId {
            dictOut["chat_room_id"] = chatRoomId
        }
        if let creatorAddress = creatorAddress {
            dictOut["creator_address"] = creatorAddress
        }
        return dictOut
    }
}
