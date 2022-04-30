//
//  OneWalletServiceProtocol.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 26/10/2021.
//

import Foundation
import Combine
import web3swift
import BigInt
import SwiftUI

protocol OneWalletServiceProtocol {
    var newWallet: AnyPublisher<Result<Wallet, OneWalletService.NewWalletError>, Never> { get }
    func transferWithProgress(from wallet: OneWalletService.WalletData?,
                              to destination: EthereumAddress,
                              amount: BigUInt) -> AnyPublisher <OneWalletService.CommitRevealProgress,
                                                                OneWalletService.CommitRevealError>
    func getCurrentUserWalletData() -> OneWalletService.WalletData?
    // swiftlint:disable function_parameter_count
    func swapONEToToken(wallet: OneWalletService.WalletData,
                        token: Web3Service.Erc20Token,
                        amountIn: BigUInt,
                        expectedAmountOut: BigUInt,
                        slippage: Double,
                        deadline: TimeInterval) -> AnyPublisher <OneWalletService.APIResponse,
                                                                 OneWalletService.CommitRevealError>
    // swiftlint:disable function_parameter_count
    func swapTokenToONE(wallet: OneWalletService.WalletData,
                        token: Web3Service.Erc20Token,
                        amountIn: BigUInt,
                        expectedAmountOut: BigUInt,
                        slippage: Double,
                        deadline: TimeInterval) -> AnyPublisher <OneWalletService.APIResponse,
                                                                 OneWalletService.CommitRevealError>
    func approveTokenAllowance(wallet: OneWalletService.WalletData,
                               token: Web3Service.Erc20Token,
                               spender: EthereumAddress,
                               amount: BigUInt) -> AnyPublisher <Bool, OneWalletService.CommitRevealError>
    func callExternalMethod(wallet: OneWalletService.WalletData,
                            amount: BigUInt,
                            contractAddress: EthereumAddress,
                            method: String,
                            data: [UInt8]) -> AnyPublisher <OneWalletService.APIResponse,
                                                            OneWalletService.CommitRevealError>
    func callExternalMethodWithProgress(wallet: OneWalletService.WalletData,
                                        amount: BigUInt,
                                        contract: web3.web3contract,
                                        method: String,
                                        parameters: [AnyObject]) -> AnyPublisher <OneWalletService.CommitRevealProgress,
                                                                                  OneWalletService.CommitRevealError>
    func getNFTTokens(walletAddress: EthereumAddress) -> AnyPublisher <[NFTInfo: [BigUInt]], Never>
    func createSignature(wallet: OneWalletService.WalletData,
                         message: String) -> AnyPublisher <MessageSignature, OneWalletService.CommitRevealError>
    func getWalletInfo(address: EthereumAddress) throws -> OneWalletService.WalletPublicInfo
    func getWalletVersion(address: EthereumAddress) throws -> (major: Int, minor: Int)
    func verifySignature(address: EthereumAddress, message: String, signature: [UInt8]) throws -> Bool
    func transactionHistory(address: EthereumAddress, page: Int) -> AnyPublisher<(transactions: [TransactionInfo], nextPage: Int?), Error>
    func walletAssets(for address: EthereumAddress) -> AnyPublisher<[WalletAssetInfo], Error>
}

struct MessageSignature: Codable {
    let message: String
    let hash: [UInt8]
    let signature: [UInt8]
    let expiry: Date?
}

enum TransactionType {
    case send
    case received
    case swap
    case contract

    var title: String {
        switch self {
        case .send:
            return "Sent"
        case .received:
            return "Received"
        case .swap:
            return "Swapped"
        case .contract:
            return "Contract Execution"
        }
    }

    var icon: Image {
        switch self {
        case .send: return Image.paperPlane
        case .received: return Image.arrowDownToLineCircle
        case .swap: return Image.rectangle2swap
        case .contract: return Image.docText
        }
    }
}

struct TransactionInfo: Equatable, Hashable {
    let type: TransactionType
    let from: EthereumAddress
    let to: EthereumAddress?
    let token: Web3Service.Erc20Token?
    let amount: BigUInt
    let time: Date

    var amountString: String? {
        let amount = Web3Service.shared.amountFromWeiUnit(amount: amount,
                                                          weiUnit: token?.weiUnit ?? OneWalletService.weiUnit)
        switch type {
        case .received:
            return "+\(Utils.formatBalance(amount)) ONE"
        case .send:
            return "-\(Utils.formatBalance(amount)) ONE"
        case .swap:
            return nil
        default:
            return nil
        }
    }

    var amountStringShort: String {
        let amount = Web3Service.shared.amountFromWeiUnit(amount: amount,
                                                          weiUnit: token?.weiUnit ?? OneWalletService.weiUnit)
        return "\(Utils.formatBalance(amount)) \(token?.symbol ?? "ONE")"
    }
}

struct WalletAssetInfo: Hashable {
    let token: Web3Service.Erc20Token?
    let amount: BigUInt
    let displayAmount: Double
    var usdAmount: Double
    var priceChangePercentage24h: Double

    var symbol: String {
        if let token = token {
            return token.symbol
        }
        return "ONE"
    }

    var priceChange: Double {
        abs(usdAmount * priceChangePercentage24h / 100)
    }

    var contractAddress: String {
        if let token = token {
            return token.contractAddress.address
        }
        return ""
    }
}
