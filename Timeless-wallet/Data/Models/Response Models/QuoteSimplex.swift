//
//  QuoteSimplex.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 1/12/22.
//

import Foundation

struct QuoteSimplex: Codable {
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case quoteID = "quote_id"
        case digitalMoney = "digital_money"
        case fiatMoney = "fiat_money"
        case supportedDigitalCurrencies = "supported_digital_currencies"
        case supportedFiatCurrencies = "supported_fiat_currencies"
    }

    var userID: String?
    var quoteID: String?
    var digitalMoney: DigitalMoney?
    var fiatMoney: FiatMoney?
    var supportedDigitalCurrencies: [String]?
    var supportedFiatCurrencies: [String]?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userID = try container.decodeIfPresent(String.self, forKey: .userID)
        quoteID = try container.decodeIfPresent(String.self, forKey: .quoteID)
        digitalMoney = try? container.decode(DigitalMoney?.self, forKey: .digitalMoney)
        fiatMoney = try? container.decode(FiatMoney?.self, forKey: .fiatMoney)
        supportedDigitalCurrencies = try container.decodeIfPresent([String].self, forKey: .supportedDigitalCurrencies)
        supportedFiatCurrencies = try container.decodeIfPresent([String].self, forKey: .supportedFiatCurrencies)
    }

    struct DigitalMoney: Codable {
        var currency: String?
        var amount: Double?
    }

    struct FiatMoney: Codable {
        var currency: String?
        var baseAmount: Double?
        var totalAmount: Double?
        var amount: Double?

        enum CodingKeys: String, CodingKey {
            case currency
            case baseAmount = "base_amount"
            case totalAmount = "total_amount"
            case amount
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            currency = try container.decodeIfPresent(String.self, forKey: .currency)
            baseAmount = try container.decodeIfPresent(Double.self, forKey: .baseAmount)
            totalAmount = try container.decodeIfPresent(Double.self, forKey: .totalAmount)
            amount = try container.decodeIfPresent(Double.self, forKey: .amount)
        }
    }
}
