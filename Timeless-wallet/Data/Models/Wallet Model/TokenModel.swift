//
//  WalletModel.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/23/21.
//

import Foundation

struct TokenModel: Hashable {
    var key: String?
    var icon: String?
    var symbol: String?
    var name: String?
    var decimal: Int?
    var token: Web3Service.Erc20Token?
    var balance: Double?
    var contractAddress: String?
}

class TokenInfo: ObservableObject {
    @Published var listToken: [TokenModel] = []
    static let shared = TokenInfo()

    func getListToken() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let jsonResult = JsonHelper.tokens
            var temp: [TokenModel] = []
            for (key, value) in jsonResult {
                var type: Web3Service.Erc20Token?
                switch key {
                case "1ETH":
                    type = .ETH
                case "1WBTC":
                    type = .WBTC
                case "1USDC":
                    type = .USDC
                case "BUSD":
                    type = .BUSD
                case "USDT":
                    type = .USDT
                case "bscBUSD":
                    type = .bscBUSD
                case "1SUSHI":
                    type = .SUSHI
                case "1DAI":
                    type = .DAI
                case "1AAVE":
                    type = .AAVE
                case "bscUSDT":
                    type = .bscUSDT
                default:
                    break
                }
                let values = TokenModel(key: value["key"] as? String,
                                        icon: value["icon"] as? String,
                                        symbol: value["symbol"] as? String,
                                        name: value["name"] as? String,
                                        decimal: value["decimal"] as? Int,
                                        token: type,
                                        contractAddress: value["contractAddress"] as? String)
                temp.append(values)
            }
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.listToken = temp.sorted { $0.symbol ?? "" < $1.symbol ?? "" }
            }
        }
    }
}
