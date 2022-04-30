//
//  TransferOne.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 10/02/22.
//

import StreamChat
import web3swift

struct TransferOne {
    // MARK: - Variables
    var destinationAddress: EthereumAddress?
    var scannedAddress: String?
    var transferAmount: Float?
    var fractionDigits: Int?
    var strFormattedAmount: String?
    var recipientName = ""
}
