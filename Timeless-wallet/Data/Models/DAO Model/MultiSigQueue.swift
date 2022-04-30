//
//  MultiSigQueue.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 07/02/22.
//

import Foundation
import BigInt
import web3swift

class MultiSigQueue: Codable, Identifiable {
    let amount: String?
    var approvals: [String]
    let created: String?
    let creator: String
    let id: String?
    let nonce: String?
    let recipient: String?
    let rejected: Bool?
    let rejections: [String]
    let safe: Safe
    let safeId: String?
    let safeTxGas: String?
    let txId: String?
    var isCheck = false

    enum CodingKeys: String, CodingKey {
        case amount = "amount"
        case approvals = "approvals"
        case created = "created"
        case creator = "creator"
        case id = "id"
        case nonce = "nonce"
        case recipient = "recipient"
        case rejected = "rejected"
        case rejections = "rejections"
        case safe = "safe"
        case safeId = "safe_id"
        case safeTxGas = "safe_tx_gas"
        case txId = "tx_id"
    }


    var createDate: Date {
        let formatter = ISO8601DateFormatter()
        if let created = created {
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return formatter.date(from: created) ?? .init()
        }
        return .init()
    }

    var oneAmountStr: String {
        return Utils.formatONE(oneAmount)
    }

    var canExecute: Bool {
        return (self.approvals.count) >= self.safe.threshold
    }

    var oneAmount: Double {
        guard let strAmount = amount, let bigAmount = BigUInt(strAmount) else {
            return 0
        }
        return Web3Service.shared.amountFromWeiUnit(
            amount: bigAmount,
            weiUnit: OneWalletService.weiUnit)
    }

    var daoText: String {
        return safe.metadata?["daoName"] ?? ""
    }

    var daoURLStr: String? {
        return safe.metadata?["daoName"] ?? ""
    }

    var daoImage: String? {
        return safe.metadata?["charityThumb"]
    }

    var startDateString: String {
        if createDate.isDateInToday() {
            return "Today"
        }
        return Formatters.Date.mediumDateFormat.string(from: createDate)
    }

    var pendingCount: Int {
        return self.safe.threshold - (self.approvals.count)
    }

    var transaction: [QueuedConfirmationType] {
        return safe.owners?.compactMap({ owner -> QueuedConfirmationType in
            var type: QueuedStatus!
            if approvals.contains(owner) {
                type = .accept
            } else if rejections.contains(owner) {
                type = .decline
            } else {
                type = .maybe
            }
            return  QueuedConfirmationType.init(walletAddress: owner, status: type)
        }) ?? []
    }

}

struct TransactionCustomType: Hashable {
    var info: TransactionInfo
    var address: String
    var status: TransactionStatus?
}

struct Safe: Codable {
    enum CodingKeys: String, CodingKey, CaseIterable {
        case address
        case created
        case creator
        case expiry
        case id
        case metadata
        case owners
        case threshold
    }
    let address: String?
    let created: String?
    let creator: String?
    let expiry: String?
    let id: String?
    let metadata: [String: String]?
    let owners: [String]?
    let threshold: Int
}

struct QueuedConfirmationType: Hashable {
    var walletAddress: String
    var status: QueuedStatus
}

enum QueuedStatus {
    case accept
    case decline
    case maybe
}
