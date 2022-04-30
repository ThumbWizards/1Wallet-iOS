//
//  RPCNetwork.swift
//  Timeless-wallet
//
//  Created by Vinh Dang on 1/5/22.
//

import Foundation
import BigInt

protocol RPCNetwork {
    var rpcUrl: URL { get }
    var networkID: BigUInt { get }
}

enum HarmonyNetwork: RPCNetwork {
    case mainNet
    case testNet

    var rpcUrl: URL {
        switch self {
        case .mainNet:
            return URL(string: AppConstant.rpcMainNetUrl)!
        case .testNet:
            return URL(string: AppConstant.rpcTestNetUrl)!
        }
    }

    var networkID: BigUInt {
        switch self {
        case .mainNet:
            return BigUInt(1_666_600_000)
        case .testNet:
            return BigUInt(1_666_700_000)
        }
    }
}
