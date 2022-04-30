//
//  MultisigServiceProtocol.swift
//  Timeless-wallet
//
//  Created by Vinh Dang on 1/25/22.
//

import Foundation
import Combine
import web3swift
import BigInt

protocol MultisigServiceProtocol {
    func createSafe(wallet: OneWalletService.WalletData,
                    owners: [EthereumAddress],
                    threshold: Int,
                    chatRoomId: String,
                    metadata: [String: String]) -> AnyPublisher<EthereumAddress, MultisigError>
    func initiateTransfer(wallet: OneWalletService.WalletData,
                          safeAddress: EthereumAddress,
                          amount: BigUInt,
                          recipient: EthereumAddress) -> AnyPublisher<MultisigService.TxData, MultisigError>
    func approveTransfer(wallet: OneWalletService.WalletData,
                         safeAddress: EthereumAddress,
                         txData: MultisigService.TxData) -> AnyPublisher<MultisigService.TxData, MultisigError>
    func rejectTransfer(wallet: OneWalletService.WalletData,
                        safeAddress: EthereumAddress,
                        txData: MultisigService.TxData) -> AnyPublisher<MultisigService.TxData, MultisigError>
    func executeTransfer(wallet: OneWalletService.WalletData,
                         safeAddress: EthereumAddress,
                         txData: MultisigService.TxData) -> AnyPublisher<MultisigService.TxData, MultisigError>
}

enum MultisigError: Error {
    case web3Error
    case createSafeError
    case noInternet
}
