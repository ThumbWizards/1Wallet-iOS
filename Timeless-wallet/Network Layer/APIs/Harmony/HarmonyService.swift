//
//  HarmonyService.swift
//  Timeless-wallet
//
//  Created by Zien on 1/19/22.
//

import Foundation
import Combine
import web3swift

class HarmonyService: BaseRestAPI<HarmonyService.RequestType>, HarmonyServiceProtocol {
    static var shared = HarmonyService()

    func transactionHistory(for address: EthereumAddress, page: Int = 0) -> AnyPublisher<(transactions: [RawTransactionInfo], nextPage: Int?), Error> {
        let pageSize = 1000
        let params: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "hmy_getTransactionsHistory",
            "params": [[
                "address": address.address,
                "pageIndex": page,
                "pageSize": pageSize,
                "fullTx": true,
                "txType": "ALL",
                "order": "DESC"
            ]],
            "id": 1
        ]
        return self.call(type: .getTransactionHistory, params: params)
            .map { $0.data }
            .decodeFromJson(TransactionHistoryResponse.self)
            .map { res in
                let transactions = res.result.transactions
                let nextPage = transactions.count >= pageSize ? page + 1 : nil
                return (transactions: transactions, nextPage: nextPage)
            }
            .eraseToAnyPublisher()
    }
}

extension HarmonyService {
    enum RequestType: EndPointType {
        case getTransactionHistory

        // MARK: Vars & Lets
        var baseURL: String {
            // TODO: Refactor so that this one can use network variable in HarmonyService class
            // return AppConstant.rpcMainNetUrl
            // TODO: Hard code this for now as the bridge endpoint doesn't return transaction history data
            return "https://api.harmony.one"
        }

        var path: String {
            return ""
        }

        var httpMethod: HTTPMethod {
            return .post
        }

        var headers: [String: String] {
            return NetworkHelper.httpTokenHeader
        }
    }

    struct TransactionHistoryResponse: Codable {
        let id: Int
        let jsonrpc: String
        let result: TransactionHistoryResult

        struct TransactionHistoryResult: Codable {
            let transactions: [RawTransactionInfo]
        }
    }
}
