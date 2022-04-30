//
//  ASSettings.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 23/10/21.
//

import SwiftUI

enum ASSettings {}

struct ASSettingItem<Type> {
    var key: String
    var defaultValue: Type
}

// MARK: - UserInfo Setting Keys + Values
extension ASSettings {
    enum AppSetupState: String {
        case none
        case username
        case security
        case passcode
        case backup
        case done
    }

    enum LockMethod: String {
        case none
        case passcode
        case passcodeBiometric

        var title: String {
            switch self {
            case .passcode: return "Passcode"
            case .passcodeBiometric:
                var biometricText = ""
                switch LocalAuthManager.shared.biometricType {
                case .faceID: biometricText = "Face ID"
                case .touchID: biometricText = "Touch ID"
                case .none, .unknown: biometricText = "Biometric"
                }
                return "Passcode / \(biometricText)"
            case .none: return ""
            }
        }

        static var allCases: [Self] {
            return [.passcode, .passcodeBiometric]
        }
    }

    enum AutoLockType: String, CaseIterable {
        case immediately
        case inactiveFor1Minute
        case inactiveFor5Minute
        case inactiveFor15Minute
        case inactiveFor30Minute

        var title: String {
            switch self {
            case .immediately: return "Immediately"
            case .inactiveFor1Minute: return "Inactive for 1 minute"
            case .inactiveFor5Minute: return "Inactive for 5 minutes"
            case .inactiveFor15Minute: return "Inactive for 15 minutes"
            case .inactiveFor30Minute: return "Inactive for 30 minutes"
            }
        }

        var lockTimeInterval: TimeInterval {
            switch self {
            case .immediately: return 0
            case .inactiveFor1Minute: return 60
            case .inactiveFor5Minute: return 60 * 5
            case .inactiveFor15Minute: return 60 * 15
            case .inactiveFor30Minute: return 60 * 30
            }
        }
    }

    enum ThemeType: String, CaseIterable {
        case dark
        case light
        case system

        var title: String {
            switch self {
            case .dark: return "Dark"
            case .light: return "Light"
            case .system: return "System"
            }
        }
    }

    enum GuardDogType: String, CaseIterable {
        case whiteGuardDog
        case redGuardDog
        case blurGuardDog
    }

    enum AcceptNewChatFromType: String, CaseIterable {
        case anyone
        case contact

        var title: String {
            switch self {
            case .anyone: return "Anyone"
            case .contact: return "Contact"
            }
        }

        // swiftlint:disable line_length
        var subtitle: String {
            switch self {
            case .anyone: return "Fellow Time Travelers may contact you.  If they become a nuisance, you can always block them :)"
            case .contact: return "Only your contact may start a new 1-1 chat or invite you to a group. Any chat initiated from non-contact will first require your confirmation"
            }
        }

        var image: Image {
            switch self {
            case .anyone: return Image.globeAmericas
            case .contact: return Image.personTextRectangle
            }
        }

        var imageSize: CGSize {
            switch self {
            case .anyone: return CGSize(width: 16, height: 16)
            case .contact: return CGSize(width: 18, height: 15)
            }
        }
    }

    enum AssetsOrder: String, CaseIterable {
        case network
        case positionSize

        var title: String {
            switch self {
            case .network: return "Network"
            case .positionSize: return "Position Size"
            }
        }

        var selection: Int {
            switch self {
            case .network: return 0
            case .positionSize: return 1
            }
        }
    }

    enum General {
        static var firstLaunch = ASSettingItem(key: "general-firstLaunch", defaultValue: true)
        static var freshInstall = ASSettingItem(key: "general-freshInstall", defaultValue: true)
        static var appSetupState = ASSettingItem(key: "general-appSetupState",
                                                 defaultValue: ASSettings.AppSetupState.none.rawValue)
    }

    enum Contact {
        static var expandFullWallet = ASSettingItem(key: "contact-expandFullWallet", defaultValue: false)
        static var contactList = ASSettingItem(key: "contact-list",
                                               defaultValue: Data())
    }

    enum Setting {
        static var requireForTransaction = ASSettingItem(key: "setting-requireForTransaction", defaultValue: true)
        static var publicProfile = ASSettingItem(key: "setting-publicProfile", defaultValue: true)
        static var publicNFTExhibition = ASSettingItem(key: "setting-publicNFTExhibition", defaultValue: true)
        static var testnetSetting = ASSettingItem(key: "setting-testnetSetting", defaultValue: false)
        static var backupGoogleAuthenticator = ASSettingItem(key: "setting-backupGoogleAuthenticator", defaultValue: false)
    }

    enum Backup {
        static var currentBackupFilePath = ASSettingItem(key: "backup-currentBackupFilePath", defaultValue: "")
        static var ubiquityIdentityToken = ASSettingItem(key: "backup-ubiquityIdentityToken", defaultValue: (Any).self)
    }

    enum UserInfo {
        static var currentWalletAddress = ASSettingItem(key: "userInfo-currentWalletAddress", defaultValue: "")
    }

    enum Settings {
        static var firstDeposit = ASSettingItem(key: "settings-firstDeposit", defaultValue: true)
        static var isShowingWeather = ASSettingItem(key: "settings-is-showing-weather", defaultValue: false)
        static var selectedWeatherType = ASSettingItem(key: "settings-selected-weather",
                                                       defaultValue: WeatherType.Fahrenheit.rawValue)
        static var titleLocation = ASSettingItem(key: "settings-selected-location-title",
                                                 defaultValue: "Current Location")
        static var lockMethod = ASSettingItem(key: "settings-lockMethod",
                                              defaultValue: ASSettings.LockMethod.none.rawValue)
        static var autoLockType = ASSettingItem(key: "settings-autoLockType",
                                                defaultValue: ASSettings.AutoLockType.immediately.rawValue)
        static var lastUnlockTime = ASSettingItem(key: "settings-lastUnlockTime",
                                                  defaultValue: Date())
        static var lastEnterBackgroundTime = ASSettingItem(key: "settings-lastEnterBackgroundTime",
                                                           defaultValue: Date())
        static var acceptNewChatFromAnyOne = ASSettingItem(key: "settings-acceptNewChatFromAnyOne",
                                              defaultValue: ASSettings.AcceptNewChatFromType.anyone.rawValue)
        static var theme = ASSettingItem(key: "settings-theme",
                                              defaultValue: ASSettings.ThemeType.dark.rawValue)
        static var guardDog = ASSettingItem(key: "settings-guardDog",
                                              defaultValue: ASSettings.GuardDogType.whiteGuardDog.rawValue)
        static var walletBalance = ASSettingItem(key: "settings-walletBalance", defaultValue: true)
        static var showCurrencyWallet = ASSettingItem(key: "settings-showCurrencyWallet", defaultValue: true)
        static var hexFormat = ASSettingItem(key: "settings-hexFormat", defaultValue: true)
    }

    enum Assets {
        static var hideSmallBalances = ASSettingItem(key: "assets-hide-small-balances", defaultValue: false)
        static var assetsOrder = ASSettingItem(key: "assets-order", defaultValue: AssetsOrder.positionSize.selection)
    }

    enum Network {
        static var network = ASSettingItem(key: "choose-network", defaultValue: "")
    }

    enum WalletDetail {
        static var multiSigFilterType = ASSettingItem(key: "wallet-detail-multisig-filter-type",
                                                      defaultValue: 0)
    }

    enum ProfilePicture {
        static var connected = ASSettingItem(key: "connected-wallet", defaultValue: false)
    }

    enum Survey {
        static var selected = ASSettingItem(key: "selected-survey", defaultValue: false)
    }

    enum NotificationService {
        static let deviceToken = ASSettingItem(key: "notification-deviceToken", defaultValue: Data())
    }

    enum KeyChain {
        static var currentVersion = ASSettingItem(key: "currentVersion", defaultValue: 0)
    }
}
