//
//  ReqWallet.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 26/10/2021.
//

import Foundation

struct ReqNewWallet {
    // MARK: - Variables
    let root: String
    let height: Int
    let interval: Int
    // swiftlint:disable identifier_name
    let t0: Int
    let lifespan: Int
    let slotSize: Int
    let lastResortAddress: String
    let spendingLimit: String
    let spendingInterval: Int
    let backlinks: [String]
    let merkleTree: MerkleTree
    
    // v15 params
    let innerCores: [String]
    let identificationKeys: [String]
    let lastLimitAdjustmentTime: Int
    let highestSpendingLimit: String

    // MARK: - Functions
    func toDictionary() -> [String: Any] {
        var dictOut = [String: Any]()
        dictOut["root"] = root
        dictOut["height"] = height
        dictOut["interval"] = interval
        dictOut["t0"] = t0
        dictOut["lifespan"] = lifespan
        dictOut["slotSize"] = slotSize
        dictOut["lastResortAddress"] = lastResortAddress
        dictOut["spendingLimit"] = spendingLimit
        dictOut["spendingInterval"] = spendingInterval
        dictOut["backlinks"] = backlinks
        dictOut["innerCores"] = innerCores
        dictOut["identificationKeys"] = identificationKeys
        dictOut["lastLimitAdjustmentTime"] = lastLimitAdjustmentTime
        dictOut["highestSpendingLimit"] = highestSpendingLimit

        return dictOut
    }
}
