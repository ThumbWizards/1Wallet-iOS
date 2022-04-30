//
//  WalletAddress.swift
//
//  Created by Ajay Ghodadra on 01/12/21
//  Copyright (c) . All rights reserved.
//

import Foundation

struct WalletAddress: Codable {

    enum CodingKeys: String, CodingKey {
        case address
        case id
        case title
    }

    var address: String?
    var id: String?
    var title: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decodeIfPresent(String.self, forKey: .address)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
    }
}
