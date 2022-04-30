//
//  StreamChatToken.swift
//
//  Created by Ajay Ghodadra on 09/11/21
//  Copyright (c) . All rights reserved.
//

import Foundation

struct StreamChatToken: Codable {

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiredAt = "expired_at"
        case issuedAt = "issued_at"
    }

    var accessToken: String?
    var expiredAt: String?
    var issuedAt: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken)
        expiredAt = try container.decodeIfPresent(String.self, forKey: .expiredAt)
        issuedAt = try container.decodeIfPresent(String.self, forKey: .issuedAt)
    }
}
