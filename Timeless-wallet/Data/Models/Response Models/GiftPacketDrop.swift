//
//  GiftPacketDrop.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 24/03/22.
//

import Foundation

// MARK: - GiftPacketDrop
struct GiftPacketDrop: Codable {
    let signature: String?
    let data: DataClass?
    let hexPacketID: String?

    enum CodingKeys: String, CodingKey {
        case signature, data
        case hexPacketID = "hex_packet_id"
    }
}

// MARK: - DataClass
struct DataClass: Codable {
    let recipientsCap: Int?
    let endTime: String?
    let creatorAddress, id, minAmount, title: String?
    let poolAddress, maxAmount, chatRoomID: String?

    enum CodingKeys: String, CodingKey {
        case recipientsCap = "recipients_cap"
        case endTime = "end_time"
        case creatorAddress = "creator_address"
        case id
        case minAmount = "min_amount"
        case title
        case poolAddress = "pool_address"
        case maxAmount = "max_amount"
        case chatRoomID = "chat_room_id"
    }
}
