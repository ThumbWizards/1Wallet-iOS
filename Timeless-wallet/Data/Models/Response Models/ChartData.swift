//
//  ChartData.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 1/18/22.
//

import Foundation

struct ChartData: Codable {
    enum CodingKeys: String, CodingKey {
        case prices
    }

    var prices: [[Double]]?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        prices = try container.decodeIfPresent([[Double]].self, forKey: .prices)
    }
}
