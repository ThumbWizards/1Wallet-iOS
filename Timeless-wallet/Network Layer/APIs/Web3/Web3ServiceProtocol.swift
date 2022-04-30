//
//  Web3ServiceProtocol.swift
//  Timeless-wallet
//
//  Created by Vinh Dang on 12/1/21.
//

import Foundation
import Combine
import web3swift
import BigInt

protocol Web3ServiceProtocol {
    var network: RPCNetwork { get }
    func getBalance(at address: EthereumAddress) throws -> BigUInt
    func getErc20TokenBalance(for token: Web3Service.Erc20Token,
                              at address: EthereumAddress) throws -> BigUInt
    func getBalance(at address: EthereumAddress) -> AnyPublisher<BigUInt, Error>
    func getErc20TokenBalance(for token: Web3Service.Erc20Token,
                              at address: EthereumAddress) -> AnyPublisher<BigUInt, Error>
    func getTokenAllowance(for token: Web3Service.Erc20Token,
                           at wallet: EthereumAddress,
                           spender: EthereumAddress) -> AnyPublisher<BigUInt, Error>

    // Contracts
    func oneWalletContract(at address: EthereumAddress) -> web3.web3contract?
    func erc20Contract(at address: EthereumAddress) -> web3.web3contract?
    func erc721Contract(at address: EthereumAddress) -> web3.web3contract?
    func erc1155Contract(at address: EthereumAddress) -> web3.web3contract?
    var sushiSwapContract: web3.web3contract? { get }

    // Misc.
    func decimalAmountFromWeiUnit(amount: BigUInt, weiUnit: Int) -> Decimal
    func amountFromWeiUnit(amount: BigUInt, weiUnit: Int) -> Double
    func amountToWeiUnit(amount: Double, weiUnit: Int) -> BigUInt
    var sushiSwapRouterAddress: EthereumAddress { get }
    var defaultTransactionOptions: TransactionOptions { get }
}
