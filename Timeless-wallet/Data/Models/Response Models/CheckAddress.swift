//
//  CheckAddress.swift
//  Timeless-wallet
//
//  Created by Phu's Mac on 24/02/2022.
//

import Foundation

struct CheckAddress: Codable {
    enum CodingKeys: String, CodingKey {
        case title
        case avatar
        case id
        case address
        case ownerid = "owner_id"
    }

    var title: String?
    var avatar: String?
    var id: String?
    var address: String?
    var ownerid: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        avatar = try container.decodeIfPresent(String.self, forKey: .avatar)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        address = try container.decodeIfPresent(String.self, forKey: .address)
        ownerid = try container.decodeIfPresent(String.self, forKey: .ownerid)
    }
}
