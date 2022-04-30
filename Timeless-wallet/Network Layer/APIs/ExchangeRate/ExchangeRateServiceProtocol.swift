//
//  ExchangeRateServiceProtocol.swift
//  Timeless-wallet
//
//  Created by Vinh Dang on 11/24/21.
//

import Foundation
import Combine
import BigInt

protocol ExchangeRateServiceProtocol {
    func ONEToUSD(amount: BigUInt) -> AnyPublisher<Result<Double, ExchangeRateService.ExchangeRateError>, Never>
    func tokenToUSD(token: Web3Service.Erc20Token,
                    amount: BigUInt) -> AnyPublisher<Result<Double, ExchangeRateService.ExchangeRateError>, Never>
    func marketData(for token: Web3Service.Erc20Token?) -> AnyPublisher<TokenMarketData, ExchangeRateService.ExchangeRateError>
    func swapRateFromONE(to token: Web3Service.Erc20Token,
                         amount: BigUInt) -> AnyPublisher<Result<BigUInt, ExchangeRateService.ExchangeRateError>, Never>
    func swapRateToONE(from token: Web3Service.Erc20Token,
                       amount: BigUInt) -> AnyPublisher<Result<BigUInt, ExchangeRateService.ExchangeRateError>, Never>
}

struct TokenMarketData {
    let symbol: String
    let usdPrice: Double
    let priceChangePercentage24h: Double
}
