//
//  GiftPacketClaimed.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 28/03/22.
//

import Foundation

// MARK: - ClaimedGiftPacket
struct ClaimedGiftPacket: Codable {
    let packetID, packetAddress, walletAddress, id: String?
    let amount: String?

    enum CodingKeys: String, CodingKey {
        case packetID = "packet_id"
        case packetAddress = "packet_address"
        case walletAddress = "wallet_address"
        case id, amount
    }
}
