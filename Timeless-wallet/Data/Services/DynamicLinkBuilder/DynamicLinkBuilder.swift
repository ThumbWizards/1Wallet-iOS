//
//  DynamicLinkBuilder.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 02/03/22.
//

import FirebaseDynamicLinks
import StreamChatUI

class DynamicLinkBuilder {

    // TODO: Temporary added to generate profile link. will remove it in future.
    static func generateProfileLink() {
        // 1
        var components = URLComponents()
        components.scheme = "https"
        components.host = Constants.DynamicLink.profileBaseUrl
        // 2
        let walletAddress = URLQueryItem(name: "walletAddress", value: "0x6904EEAF5df8f6E182e620aC238073c08907d4E0")
        components.queryItems = [walletAddress]
        // 3
        guard let linkParameter = components.url else {
            return
        }
        // 4
        let domain = AppConstant.firebaseDynamicLinkBaseURL
        guard let linkBuilder = DynamicLinkComponents.init(link: linkParameter, domainURIPrefix: domain) else {
            return
        }
        // 5
        if let myBundleId = Bundle.main.bundleIdentifier {
            linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundleId)
        }
        linkBuilder.iOSParameters?.appStoreID = AppConstant.firebaseAppStoreID
        linkBuilder.navigationInfoParameters = .init()
        linkBuilder.navigationInfoParameters?.isForcedRedirectEnabled = true
        if let fallBackUrl = URL(string: AppConstant.firebaseProfileFallBackUrl) {
            linkBuilder.iOSParameters?.fallbackURL = fallBackUrl
            linkBuilder.otherPlatformParameters = DynamicLinkOtherPlatformParameters()
            linkBuilder.otherPlatformParameters?.fallbackUrl = fallBackUrl
            linkBuilder.androidParameters = DynamicLinkAndroidParameters(packageName: "com.timeless.wallet")
            linkBuilder.androidParameters?.fallbackURL = fallBackUrl
        }
    }

    static func generatePrivateGroupLink(
        groupId: String,
        signature: String,
        expiry: String,
        completion: @escaping ((URL?) -> Void)) {
            // 1
            var components = URLComponents()
            components.scheme = "https"
            components.host = Constants.DynamicLink.privateGroupBaseUrl
            // 2
            let idIDQueryItem = URLQueryItem(name: "id", value: groupId)
            let signatureQueryItem = URLQueryItem(name: "signature", value: signature)
            let expireDateQueryItem = URLQueryItem(name: "expiry", value: expiry)
            components.queryItems = [idIDQueryItem, signatureQueryItem, expireDateQueryItem]
            // 3
            guard let linkParameter = components.url else {
                completion(nil)
                return
            }
            // 4
            let domain = AppConstant.firebaseDynamicLinkBaseURL
            guard let linkBuilder = DynamicLinkComponents.init(link: linkParameter, domainURIPrefix: domain) else {
                completion(nil)
                return
            }
            // 5
            if let myBundleId = Bundle.main.bundleIdentifier {
                linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundleId)
            }
            linkBuilder.navigationInfoParameters = .init()
            linkBuilder.navigationInfoParameters?.isForcedRedirectEnabled = true
            linkBuilder.iOSParameters?.appStoreID = AppConstant.firebaseAppStoreID
            if let fallBackUrl = URL(string: AppConstant.firebaseFallBackUrl) {
                linkBuilder.iOSParameters?.fallbackURL = fallBackUrl
            }
            // 6
            linkBuilder.shorten { url, _, error in
                guard error == nil, let url = url else {
                    completion(nil)
                    return
                }
                completion(url)
            }
    }

    static func generateDaoShareLink(groupId: String, expireDate: String, completion: @escaping ((URL?) -> Void)) {
        // 1
        var components = URLComponents()
        components.scheme = "https"
        components.host = Constants.DynamicLink.daoBaseUrl
        // 2
        let idIDQueryItem = URLQueryItem(name: "id", value: groupId)
        let expireDateQueryItem = URLQueryItem(name: "expiry", value: expireDate)
        components.queryItems = [idIDQueryItem, expireDateQueryItem]
        // 3
        guard let linkParameter = components.url else {
            completion(nil)
            return
        }
        // 4
        let domain = AppConstant.firebaseDynamicLinkBaseURL
        guard let linkBuilder = DynamicLinkComponents.init(link: linkParameter, domainURIPrefix: domain) else {
            completion(nil)
            return
        }
        // 5
        if let myBundleId = Bundle.main.bundleIdentifier {
            linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundleId)
        }
        linkBuilder.navigationInfoParameters = .init()
        linkBuilder.navigationInfoParameters?.isForcedRedirectEnabled = true
        linkBuilder.iOSParameters?.appStoreID = AppConstant.firebaseAppStoreID
        if let fallBackUrl = URL(string: AppConstant.firebaseFallBackUrl) {
            linkBuilder.iOSParameters?.fallbackURL = fallBackUrl
        }
        // 6
        linkBuilder.shorten { url, _, error in
            guard error == nil, let url = url else {
                completion(nil)
                return
            }
            completion(url)
        }
    }
}
