//
//  HarmonyServiceProtocol.swift
//  Timeless-wallet
//
//  Created by Zien on 1/19/22.
//

import Foundation
import Combine
import web3swift
import BigInt

protocol HarmonyServiceProtocol {
    func transactionHistory(for address: EthereumAddress, page: Int) -> AnyPublisher<(transactions: [RawTransactionInfo], nextPage: Int?), Error>
}


struct RawTransactionInfo: Codable {
    let from: EthereumAddress
    // swiftlint:disable identifier_name
    let to: EthereumAddress?
    let input: [UInt8]
    let value: BigUInt // in wei unit
    let hash: [UInt8]
    let blockNumber: BigUInt?
    let transactionIndex: BigUInt?
    let nonce: BigUInt
    let timestamp: Int

    private enum CodingKeys: String, CodingKey {
        case from, to, input, value, hash, blockNumber, transactionIndex, nonce, timestamp
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fromStr = try container.decode(String.self, forKey: .from)
        let toStr = try? container.decodeIfPresent(String.self, forKey: .to) ?? nil
        let inputStr = try container.decode(String.self, forKey: .input)
        let valueStr = try container.decode(String.self, forKey: .value)
        let hashStr = try container.decode(String.self, forKey: .hash)
        let blockStr = try? container.decodeIfPresent(String.self, forKey: .blockNumber) ?? nil
        let txIndexStr = try? container.decodeIfPresent(String.self, forKey: .transactionIndex) ?? nil
        let nonceStr = try container.decode(String.self, forKey: .nonce)
        let timestampStr = try container.decode(String.self, forKey: .timestamp)

        from = EthereumAddress(fromStr.convertBech32ToEthereum())!
        to = toStr == nil ? nil : EthereumAddress(toStr!.convertBech32ToEthereum())
        input = [UInt8](hex: inputStr)
        value = BigUInt(valueStr.dropFirst(2), radix: 16)!
        hash = [UInt8](hex: hashStr)
        blockNumber = blockStr != nil ? BigUInt(blockStr!.dropFirst(2), radix: 16)! : nil
        transactionIndex = txIndexStr != nil ? BigUInt(txIndexStr!.dropFirst(2), radix: 16)! : nil
        nonce = BigUInt(nonceStr.dropFirst(2), radix: 16)!
        timestamp = Int(timestampStr.dropFirst(2), radix: 16)!
    }
}
