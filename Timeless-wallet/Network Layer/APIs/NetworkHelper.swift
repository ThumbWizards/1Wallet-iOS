//
//  HeaderManager.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 23/10/21.
//

import Foundation

class NetworkHelper {
    static let shared = NetworkHelper()
    let reachability = Reachability()

    static var httpPreTokenHeader: [String: String] {
        return ["Content-Type": "application/json"]
    }
    static var httpTokenHeader: [String: String] {
        return ["Accept": "application/json",
                "Content-Type": "application/json"]
    }

    static var httpVersionHeader: [String: String] {
        return ["Accept": "application/json",
                "Content-Type": "application/json",
                "X-APP-VERSION": Bundle.main.buildInfo]
    }

    static var httpWalletHeader: [String: String] {
        return ["Accept": "application/json",
                "Content-Type": "application/json",
                "X-WALLET-ADDRESS": Wallet.currentWallet?.address ?? "",
                "X-APP-VERSION": Bundle.main.buildInfo,
                "X-WALLET-SIGNATURE": Wallet.currentEncodedSignature ?? ""]
    }

    static var httpCryptoHeader: [String: String] {
        return ["Content-Type": "application/json",
                "X-ONEWALLET-RELAYER-SECRET": "onewallet",
                "X-NETWORK": "harmony-mainnet",
                "X-MAJOR-VERSION": "15",
                "X-MINOR-VERSION": "1"]
    }
    static var httpFormHeader: [String: String] {
        return ["Content-Type": "application/x-www-form-urlencoded"]
    }

    // MARK: - Init
    private init() {
        startNetworkNotifier()
    }
}

// Reachability
extension NetworkHelper {
    func startNetworkNotifier() {
        do {
            try reachability?.startNotifier()
            reachability?.whenReachable = { _ in
                NotificationCenter.default.post(name: .reachabilityChanged, object: nil)
            }
            reachability?.whenUnreachable = { _ in
                NotificationCenter.default.post(name: .reachabilityChanged, object: nil)
            }
        } catch {
            print("Unable to start notifier")
        }
    }
}
