//
//  SettingsView+Modal.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 01/11/2021.
//

import SwiftUI

enum SheetType: CaseIterable {
    case exportSeed
    case chooseAPassword
    case restoreFromiCloud
}

enum SettingsItem: CaseIterable {
    case googleAuthenticator
    case iCloudKeychain
    case appLock
    case lockMethod
    case autoLock
    case requireForTransaction
    case currency
    case walletBalance
    case theme
    case weather
    case guardDog
    case privacyPolicy
    case publicProfile
    case publicNFTExhibition
    case acceptNewChatsFrom
    case developerSettings
    case oneFormat
    case chatWithUs
    case requestFeatures
    case discord
    case telegram
    case twitter
    case upcomingHarmonyEvents

    var title: String {
        switch self {
        case .googleAuthenticator: return "Google Authenticator"
        case .iCloudKeychain: return "iCloud Keychain"
        case .appLock: return "App Lock"
        case .lockMethod: return "Lock Method"
        case .autoLock: return "Auto-Lock"
        case .requireForTransaction: return "Required for Transaction"
        case .currency: return "Currency"
        case .walletBalance: return "Wallet Balance (Fiat)"
        case .theme: return "Theme"
        case .weather: return "Weather"
        case .guardDog: return "Guard dog"
        case .privacyPolicy: return "Privacy Policy"
        case .publicProfile: return "Public Profile"
        case .publicNFTExhibition: return "Public NFT Exhibition"
        case .acceptNewChatsFrom: return "Accept new chats from"
        case .developerSettings: return "Developer Settings"
        case .oneFormat: return "ONE Format"
        case .chatWithUs: return "Chat with us"
        case .requestFeatures: return "Request features"
        case .discord: return "Discord"
        case .telegram: return "Telegram"
        case .twitter: return "Twitter"
        case .upcomingHarmonyEvents: return "Upcoming Harmony events"
        }
    }

    var image: Image {
        switch self {
        case .googleAuthenticator, .privacyPolicy: return Image.shieldCheckerBoard
        case .iCloudKeychain: return Image.keyiCloud
        case .appLock: return Image.appsiPhone
        case .lockMethod: return LocalAuthManager.shared.biometricType == .touchID ? Image.touchid : Image.faceId
        case .autoLock: return Image.lock
        case .requireForTransaction, .currency: return Image.dollarSignCircle
        case .walletBalance: return Image.bitcoinSignCircle
        case .theme: return Image.moonStars
        case .weather: return Image.cloudSunFill
        case .guardDog: return Image.pawPrint
        case .publicProfile: return Image.personCropCircle
        case .publicNFTExhibition: return Image.photoCircle
        case .acceptNewChatsFrom: return Image.bubbleLeftAndExclamationmarkBubbleRight
        case .developerSettings: return Image.chevronLeftSlashChevronRight
        case .oneFormat: return Image.circleHexagongrid
        case .chatWithUs: return Image.bubleLeftAndBubleRight
        case .requestFeatures: return Image.listBulletRectanglePortrait
        case .discord: return Image.discord
        case .telegram: return Image.telegram
        case .twitter: return Image.twitter
        case .upcomingHarmonyEvents: return Image.calendar
        }
    }

    var imageSize: CGSize {
        switch self {
        case .googleAuthenticator: return CGSize(width: 13, height: 16)
        case .iCloudKeychain: return CGSize(width: 19.5, height: 14)
        case .appLock: return CGSize(width: 10.5, height: 17.5)
        case .lockMethod: return CGSize(width: 16, height: 16)
        case .autoLock: return CGSize(width: 10.5, height: 16)
        case .requireForTransaction: return CGSize(width: 16.5, height: 16.5)
        case .currency: return CGSize(width: 16.5, height: 16.5)
        case .walletBalance: return CGSize(width: 16.5, height: 16.5)
        case .theme: return CGSize(width: 17, height: 17)
        case .weather: return CGSize(width: 19.5, height: 14)
        case .guardDog: return CGSize(width: 17, height: 16.5)
        case .privacyPolicy: return CGSize(width: 13, height: 16)
        case .publicProfile: return CGSize(width: 16.5, height: 16.5)
        case .publicNFTExhibition: return CGSize(width: 16.5, height: 16.5)
        case .acceptNewChatsFrom: return CGSize(width: 23, height: 18.5)
        case .developerSettings: return CGSize(width: 23, height: 16)
        case .oneFormat: return CGSize(width: 17.5, height: 17.5)
        case .chatWithUs: return CGSize(width: 23, height: 18.5)
        case .requestFeatures: return CGSize(width: 14, height: 17.5)
        case .discord: return CGSize(width: 26.5, height: 18)
        case .telegram: return CGSize(width: 24, height: 24)
        case .twitter: return CGSize(width: 23.5, height: 20.5)
        case .upcomingHarmonyEvents: return CGSize(width: 22.5, height: 20.5)
        }
    }

    var toggleValue: Bool {
        switch self {
        case .appLock, .requireForTransaction, .walletBalance, .publicProfile, .publicNFTExhibition, .oneFormat: return true
        default: return false
        }
    }
}

enum SettingsSection: CaseIterable {
    case backupAndRecovery
    case appSecurity
    case preference
    case privacy
    case advanced
    case supportAndFeedback
    case joinHarmonauts

    var title: String {
        switch self {
        case .backupAndRecovery: return "BACKUP AND RECOVERY"
        case .appSecurity: return "APP SECURITY"
        case .preference: return "PREFERENCE"
        case .privacy: return "PRIVACY"
        case .advanced: return "ADVANCED"
        case .supportAndFeedback: return "SUPPORT & FEEDBACK"
        case .joinHarmonauts: return "JOIN HARMONAUTS"
        }
    }

    var itemList: [SettingsItem] {
        switch self {
        case .backupAndRecovery: return [.googleAuthenticator, .iCloudKeychain]
        case .appSecurity: return [.appLock]
        case .preference: return [.currency, .walletBalance, .theme, .weather, .guardDog]
        case .privacy: return [.privacyPolicy, .publicProfile, .publicNFTExhibition, .acceptNewChatsFrom]
        case .advanced: return [.developerSettings, .oneFormat]
        case .supportAndFeedback: return [.chatWithUs, .requestFeatures]
        case .joinHarmonauts: return [.discord, .telegram, .twitter, .upcomingHarmonyEvents]
        }
    }

    // swiftlint:disable line_length
    var bottomText: String {
        switch self {
        case .backupAndRecovery, .appSecurity, .supportAndFeedback, .joinHarmonauts: return ""
        case .preference: return "Choose from displaying wallet balance in Coin or Fiat equivalent to selecting your most faithful guard dog as appicon to safeguard your assets."
        case .privacy: return "When ON (public), all NFT collectibles associated with the wallet will be visible to the community via the Timeless profile."
        case .advanced: return "When toggled ON, wallet address is displayed in Bech32 Format (one) vs Default Hex Format (0x)"
        }
    }
}
