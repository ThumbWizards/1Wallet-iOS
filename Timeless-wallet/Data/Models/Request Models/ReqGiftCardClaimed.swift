//
//  ReqGiftCardClaimed.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 28/03/22.
//

import Foundation

class ReqGiftCardClaimed {

    var walletAddress: String?
    var claimId: String?
    var txId: String?

    func toDictionary() -> [String: Any] {
        var dictOut = [String: Any]()
        dictOut["claim_id"] = claimId
        dictOut["wallet_address"] = walletAddress
        dictOut["tx_id"] = txId
        return dictOut
    }
}
