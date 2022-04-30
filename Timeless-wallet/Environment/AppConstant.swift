//
//  AppConstant.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 23/10/21.
//

import Foundation
import Keys

/// AppConstant
public struct AppConstant {
    static let keys = TimelessWalletKeys()
    static let iCloudContainerId = "iCloud.\(Bundle.main.bundleIdentifier ?? "")"
    static var giphyAPIKey: String = keys.giphyAPIKey
    static var stipopAPIKey: String = keys.stipopAPIKey
    static var firebaseProfileFallBackUrl: String = keys.firebaseProfileFallBackUrl
    static var firebaseFallBackUrl: String = keys.firebaseFallBackUrl
    static var firebaseAppStoreID: String = keys.firebaseAppStoreID
    static var firebaseDynamicLinkDomain: String = keys.firebaseDynamicLinkDomain
    static var firebaseDynamicLinkBaseURL: String = keys.firebaseDynamicLinkBaseURL
    static var getStreamAppId: String = keys.getStreamAppId
    static var rpcTestNetUrl: String = keys.rpcTestNetUrl
    static var rpcMainNetUrl: String = keys.rpcMainNetUrl
    static var oneWalletServiceUrl: String = keys.oneWalletServiceUrl
    static var chatAPIKey: String = keys.getStreamAPIKey
    static var openWeatherApiKey: String = keys.openWeatherApiKey
    static var simplexApiKey: String = keys.simplexApiKey
    static var serverURL: String = keys.serverURL

    static func validate() {
        if AppConstant.giphyAPIKey.isEmpty ||
            AppConstant.stipopAPIKey.isEmpty ||
            AppConstant.firebaseProfileFallBackUrl.isEmpty ||
            AppConstant.firebaseFallBackUrl.isEmpty ||
            AppConstant.firebaseAppStoreID.isEmpty ||
            AppConstant.firebaseDynamicLinkDomain.isEmpty ||
            AppConstant.firebaseDynamicLinkBaseURL.isEmpty ||
            AppConstant.getStreamAppId.isEmpty ||
            AppConstant.rpcTestNetUrl.isEmpty ||
            AppConstant.rpcMainNetUrl.isEmpty ||
            AppConstant.oneWalletServiceUrl.isEmpty ||
            AppConstant.chatAPIKey.isEmpty ||
            AppConstant.openWeatherApiKey.isEmpty ||
            AppConstant.simplexApiKey.isEmpty ||
            AppConstant.serverURL.isEmpty {
            fatalError("Defined variables in .env file, Check README file for more information.")
        }

    }
}
