//
//  CreateDaoModel.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 01/02/22.
//

import Foundation
import web3swift
import StreamChatUI
import StreamChat

struct CreateDaoModel {
    var isDiscoverable: Bool?
    var description: String?
    var charityThumb: String?
    var signers: [SignerWallet] = []
    var daoName: String?
    var minimumContribution = 10 //ONE
    var expireDate: Date?
    var threshold: Int?
    var masterWalletAddress: EthereumAddress? // where all the donation will credit

    var expireTimeStamp: Double? {
        return expireDate?.ticks
    }

    var strExpireDate: String {
        guard let daoExpireDate = expireDate else {
            return ""
        }
        let formatter = Formatters.Date.daoExpireDate
        return formatter.string(from: daoExpireDate)
    }

    func chatExtraData(groupId: String, safeAddress: String, completion: @escaping (([String: RawJSON]?) -> Void)) {
        let userIds = signers.compactMap { $0.walletAddress?.address }
        let rawUserId: [RawJSON] = userIds.map { .string($0) }
        let encodeGroupId = groupId.base64Encoded.string ?? ""
        let expireDate = String(expireDate?.ticks ?? 0).base64Encoded.string ?? ""
        var extraData: [String: RawJSON] = [:]
        DynamicLinkBuilder.generateDaoShareLink(
            groupId: encodeGroupId,
            expireDate: expireDate) { url in
                guard let shareLink = url else {
                    completion(nil)
                    return
                }
                extraData["daoJoinLink"] = .string(shareLink.absoluteString)
                extraData["masterWalletAddress"] = .string(masterWalletAddress?.address ?? "")
                extraData["safeAddress"] = .string(safeAddress)
                extraData["signers"] = .array(rawUserId)
                extraData["threshold"] = .string(String(threshold ?? 0))
                extraData["groupCreator"] = .string(ChatClient.shared.currentUserId ?? "")
                extraData["daoDescription"] = .string(description ?? "")
                extraData["isDiscoverable"] = .bool(isDiscoverable ?? false)
                extraData["charityThumb"] = .string(charityThumb ?? "")
                extraData["daoName"] = .string(daoName ?? "")
                extraData["minimumContribution"] = .string(String(minimumContribution))
                extraData["daoExpireDate"] = .string(strExpireDate)
                completion(extraData)
            }
    }

    func getMetadata() -> [String: String] {
        var metadata = [String: String]()
        metadata["masterWalletAddress"] = (masterWalletAddress?.address ?? "")
        metadata["groupCreator"] = ChatClient.shared.currentUserId ?? ""
        metadata["charityThumb"] = charityThumb
        metadata["daoName"] = daoName
        metadata["expireDate"] = strExpireDate
        return metadata
    }
}
