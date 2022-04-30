//
//  TLWallet.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 15/11/2021.
//

import Foundation

struct TLWallet: Codable {
    enum CodingKeys: String, CodingKey {
        case id, title, address, avatar
    }

    var id: String
    var title: String
    var address: String
    var avatar: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)!
        title = try container.decodeIfPresent(String.self, forKey: .title)!
        address = try container.decodeIfPresent(String.self, forKey: .address)!
        avatar = try container.decodeIfPresent(String.self, forKey: .avatar)!
    }
}
