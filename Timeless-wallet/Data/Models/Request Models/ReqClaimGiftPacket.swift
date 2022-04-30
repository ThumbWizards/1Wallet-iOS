//
//  ReqClaimGiftPacket.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 20/01/22.
//

import Foundation

class ReqClaimGiftPacket {

    var walletAddress: String?

    func toDictionary() -> [String: Any] {
        var dictOut = [String: Any]()
        dictOut["wallet_address"] = walletAddress
        return dictOut
    }
}
