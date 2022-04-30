//
//  AppData.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 03/11/2021.
//

import Foundation

struct AppData: Codable {
    enum CodingKeys: String, CodingKey {
        case keyChainVersion, allWallets, allWalletSeeds, allEffectiveTimes, allWalletSignaturesV1, allStreamChatAccessTokens
    }

    var keyChainVersion: Int?
    var allWallets: [Wallet]
    var allWalletSeeds: [String: [UInt8]?]
    var allEffectiveTimes: [String: Date]?
    var allWalletSignaturesV1: [String: MessageSignature]?
    var allStreamChatAccessTokens: [String: String]?
    var allWalletRootHexes: [String: String]?

    func restore() {
        _ = KeyChain.shared.clear(key: .allWallets)
        _ = KeyChain.shared.clear(key: .allWalletSeeds)
        _ = KeyChain.shared.clear(key: .allWalletSignatures)
        _ = KeyChain.shared.clear(key: .allWalletSignaturesV1)
        _ = KeyChain.shared.clear(key: .allEffectiveTimes)
        _ = KeyChain.shared.clear(key: .allStreamChatAccessTokens)
        _ = KeyChain.shared.clear(key: .allWalletRootHexes)
        _ = KeyChain.shared.store(key: .allWallets, obj: allWallets)
        _ = KeyChain.shared.store(key: .allWalletSeeds, obj: allWalletSeeds)
        if let allEffectiveTimes = allEffectiveTimes {
            _ = KeyChain.shared.store(key: .allEffectiveTimes, obj: allEffectiveTimes)
        }
        if let allWalletSignaturesV1 = allWalletSignaturesV1 {
            _ = KeyChain.shared.store(key: .allWalletSignaturesV1, obj: allWalletSignaturesV1)
        }
        if let allStreamChatAccessTokens = allStreamChatAccessTokens {
            _ = KeyChain.shared.store(key: .allStreamChatAccessTokens, obj: allStreamChatAccessTokens)
        }
        if let allWalletRootHexes = allWalletRootHexes {
            _ = KeyChain.shared.store(key: .allWalletRootHexes, obj: allWalletRootHexes)
        }
        if let newWallet = Wallet.currentWallet {
            WalletInfo.shared.currentWallet = newWallet
            TabBarView.ViewModel.shared.syncWithWalletInfo()
        }
        NotificationCenter.default.post(name: .appStateChange, object: nil)
    }
}
