//
//  ExchangeRateService.swift
//  Timeless-wallet
//
//  Created by Vinh Dang on 11/24/21.
//

import Foundation
import Combine
import BigInt
import web3swift

class ExchangeRateService: BaseRestAPI<ExchangeRateService.RequestType>, ExchangeRateServiceProtocol {
    static let shared = ExchangeRateService()

    func ONEToUSD(amount: BigUInt) -> AnyPublisher<Result<Double, ExchangeRateError>, Never> {
        let oneAmount = Web3Service.shared.amountFromWeiUnit(amount: amount,
                                                              weiUnit: OneWalletService.weiUnit)
        return tokenToUSD(token: "ONE", amount: oneAmount)
    }

    func tokenToUSD(token: Web3Service.Erc20Token, amount: BigUInt) -> AnyPublisher<Result<Double, ExchangeRateError>, Never> {
        let tokenAmount = Web3Service.shared.amountFromWeiUnit(amount: amount,
                                                                weiUnit: token.weiUnit)
        if token.isStableCoin {
            return Just(.success(tokenAmount)).eraseToAnyPublisher()
        }
        return tokenToUSD(token: token.trackedSymbol, amount: tokenAmount)
    }

    func marketData(for token: Web3Service.Erc20Token?) -> AnyPublisher<TokenMarketData, ExchangeRateError> {
        var tokenSymbol: String
        if token != nil {
            tokenSymbol = token!.trackedSymbol
        } else {
            tokenSymbol = "ONE"
        }
        guard !(token?.isStableCoin ?? false) else {
            return Just(TokenMarketData(symbol: tokenSymbol, usdPrice: 1, priceChangePercentage24h: 0))
                .setFailureType(to: ExchangeRateError.self)
                .eraseToAnyPublisher()
        }
        return call(type: .fetchPrice(tokenSymbol), params: nil)
            .unwrapResultJSONFromAPI()
            .map { $0.data }
            .decodeFromJson(BinancePriceResponse.self)
            .map { res in
                TokenMarketData(symbol: tokenSymbol,
                                usdPrice: Double(res.lastPrice) ?? 0,
                                priceChangePercentage24h: Double(res.priceChangePercent) ?? 0)
            }
            .mapError { _ in
                .binanceApiError
            }
            .eraseToAnyPublisher()
    }

    func swapRateFromONE(to token: Web3Service.Erc20Token,
                         amount: BigUInt) -> AnyPublisher<Result<BigUInt, ExchangeRateError>, Never> {
        return fetchSwapRate(amount: amount, path: [OneWalletService.sushiONEContractAddress, token.contractAddress])
    }

    func swapRateToONE(from token: Web3Service.Erc20Token,
                       amount: BigUInt) -> AnyPublisher<Result<BigUInt, ExchangeRateError>, Never> {
        return fetchSwapRate(amount: amount, path: [token.contractAddress, OneWalletService.sushiONEContractAddress])
    }
}

private extension ExchangeRateService {
    func fetchTokenPrice(token: String) -> AnyPublisher<Result<Double, ExchangeRateError>, Never> {
        return call(type: .fetchPrice(token), params: nil)
            .unwrapResultJSONFromAPI()
            .map { $0.data }
            .decodeFromJson(BinancePriceResponse.self)
            .map { res in
                guard let rate = Double(res.lastPrice) else {
                    return .failure(.binanceApiError)
                }
                return .success(rate)
            }
            .catch { _ in
                Just(.failure(.binanceApiError))
            }
            .eraseToAnyPublisher()
    }

    func tokenToUSD(token: String, amount: Double) -> AnyPublisher<Result<Double, ExchangeRateError>, Never> {
        return fetchTokenPrice(token: token)
            .map { result in
                switch result {
                case .success(let rate):
                    return .success(amount * rate)
                case .failure:
                    return result
                }
            }
            .eraseToAnyPublisher()
    }

    func fetchSwapRate(amount: BigUInt, path: [EthereumAddress]) -> AnyPublisher<Result<BigUInt, ExchangeRateError>, Never> {
        // swiftlint:disable identifier_name
        guard let contract = Web3Service.shared.sushiSwapContract,
              let tx = contract.read("getAmountsOut", parameters: [amount, path] as [AnyObject]) else {
                  return Just(.failure(.web3Error)).eraseToAnyPublisher()
              }
        return tx.callPromise(transactionOptions: Web3Service.shared.defaultTransactionOptions)
            .publisher
            .map { result -> Result<BigUInt, ExchangeRateError> in
                  guard let data = result["amounts"] as? [BigUInt], data.count == 2 else {
                      return .failure(.web3Error)
                  }
                  return .success(data[1])
            }
            .replaceError(with: .failure(.web3Error))
            .eraseToAnyPublisher()
    }
}

extension ExchangeRateService {
    struct BinancePriceResponse: Codable {
        let lastPrice: String
        let priceChangePercent: String
    }

    enum ExchangeRateError: Error {
        case binanceApiError
        case web3Error
    }

    enum RequestType: EndPointType {
        case fetchPrice(_ token: String)

        var baseURL: String {
            return "https://api.binance.com/api/"
        }

        var version: String {
            return "v3/"
        }

        var path: String {
            switch self {
            case .fetchPrice(let token):
                return "ticker/24hr?symbol=\(token)USDT"
            }
        }

        var httpMethod: HTTPMethod {
            switch self {
            case .fetchPrice:
                return .get
            }
        }

        var headers: [String: String] {
            return NetworkHelper.httpPreTokenHeader
        }
    }
}
