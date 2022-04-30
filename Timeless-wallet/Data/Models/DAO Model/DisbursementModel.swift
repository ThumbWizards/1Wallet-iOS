//
//  DisbursementModel.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 03/02/22.
//

import web3swift
import GetStream
import StreamChat
import StreamChatUI

struct DisbursementModel {
    var multisigWallet: EthereumAddress?
    var recipientWallet: EthereumAddress?
    var oneBalance: CGFloat?
    var usdBalance: CGFloat?
    var daoName: String?
    var charityThumb: String?
    var purpose: String?
    var chatData = [String: RawJSON]()

    init(with data: [String: RawJSON]) {
        self.chatData = data
        self.multisigWallet = .init(getSafeAddress())
        self.daoName = getDaoName()
        self.charityThumb = getCharityThumb()
    }

    func getSafeAddress() -> String {
        if let safeAddress = chatData["safeAddress"] {
            return "\(fetchRawData(raw: safeAddress) as? String ?? "")"
        } else {
            return ""
        }
    }

    func getDaoName() -> String {
        if let daoName = chatData["daoName"] {
            return "\(fetchRawData(raw: daoName) as? String ?? "")"
        } else {
            return ""
        }
    }

    func getCharityThumb() -> String {
        if let charityThumb = chatData["charityThumb"] {
            return "\(fetchRawData(raw: charityThumb) as? String ?? "")"
        } else {
            return ""
        }
    }
}
