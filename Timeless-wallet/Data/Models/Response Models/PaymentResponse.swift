//
//  PaymentResponse.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 1/12/22.
//

import Foundation

struct PaymentResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case isAddressValid, isTagValid, form, paymentId
    }

    var isAddressValid: Bool?
    var isTagValid: Bool?
    var form: String?
    var paymentId: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isAddressValid = try container.decodeIfPresent(Bool.self, forKey: .isAddressValid)
        isTagValid = try container.decodeIfPresent(Bool.self, forKey: .isTagValid)
        form = try container.decodeIfPresent(String.self, forKey: .form)
        paymentId = try container.decodeIfPresent(String.self, forKey: .paymentId)
    }
}
