//
//  ClaimGiftPacket.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 24/03/22.
//

import Foundation

// MARK: - ClaimGiftPacket
struct ClaimGiftPacket: Codable {
    let data: ClaimGiftDataClass?
    let hexPacketID, signature: String?

    enum CodingKeys: String, CodingKey {
        case data
        case hexPacketID = "hex_packet_id"
        case signature
    }
}

// MARK: - DataClass
struct ClaimGiftDataClass: Codable {
    let packetID, packetAddress, walletAddress, id: String?
    let amount: String?

    enum CodingKeys: String, CodingKey {
        case packetID = "packet_id"
        case packetAddress = "packet_address"
        case walletAddress = "wallet_address"
        case id, amount
    }
}
