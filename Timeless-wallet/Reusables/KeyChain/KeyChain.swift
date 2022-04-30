//
//  KeyStore.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 29/10/2021.
//
// swiftlint:disable force_try

import Foundation
import os
import LocalAuthentication
import Sentry
import SwiftUI
import EllipticCurveKeyPair
import CryptoKit

class KeyChain {
    static var shared = KeyChain()
    static var latestVersion = 1

    init() {
        migrateData()
        encryptKeyInitialize()
    }

    @UserDefault(
        key: ASSettings.General.freshInstall.key,
        defaultValue: ASSettings.General.freshInstall.defaultValue
    )
    private var freshInstall: Bool

    @UserDefault(
        key: ASSettings.KeyChain.currentVersion.key,
        defaultValue: ASSettings.KeyChain.currentVersion.defaultValue
    )
    private var currentVersion: Int

    enum Key: CaseIterable {
        case allWallets
        case allWalletSeeds
        case allEffectiveTimes
        // Backup password should be SHA256, ex: SHA256.hash(data: pass.data(using: .utf8)!)
        case backupPassword
        case passcode
        case allWalletSignatures // Deprecated, please use `allWalletSignaturesV1`
        case allWalletSignaturesV1
        case allStreamChatAccessTokens
        case allWalletRootHexes
        case encryptKey
        case backupV0

        var rawValue: String {
            switch self {
            case .allWallets:
                return "wallets"
            case .allWalletSeeds:
                return "allWalletSeeds"
            case .allEffectiveTimes:
                return "allEffectiveTimes"
            case .backupPassword:
                return "backupPassword"
            case .passcode:
                return "passcode"
            case .allWalletSignatures:
                return "allWalletSignatures"
            case .allWalletSignaturesV1:
                return "allWalletSignatures.v1"
            case .allStreamChatAccessTokens:
                return "allStreamChatAccessTokens"
            case .allWalletRootHexes:
                return "allWalletRootHexes"
            case .encryptKey:
                return "encryptKey"
            case .backupV0:
                return "backup.v0"
            }
        }

        static var allCasesWithoutBackup: [Key] {
            let cases = allCases.filter { !$0.rawValue.hasSuffix(".backup") }
            return cases
        }

        static var allV0Cases: Set<Key> {
            [.allWallets,
             .allWalletSeeds,
             .allEffectiveTimes,
             .backupPassword,
             .passcode,
             .allWalletSignatures,
             .allStreamChatAccessTokens]
        }

        static var allV0DeprecatedCases: Set<Key> {
            [.allWalletSignatures]
        }

        static var secureKeys: Set<Key> {
            EllipticCurveKeyPair.Device.hasSecureEnclave ? [.allWalletSeeds,
                                                            .backupPassword,
                                                            .passcode,
                                                            .allWalletSignaturesV1,
                                                            .allStreamChatAccessTokens,
                                                            .encryptKey,
                                                            .backupV0] : []
        }
    }

    func migrateData() {
        guard !freshInstall else {
            currentVersion = Self.latestVersion
            return
        }
        // Data migration
        if currentVersion < Self.latestVersion {
            for version in currentVersion...Self.latestVersion - 1 {
                switch version {
                case 0:
                    var backupData: [String: Data] = [:]
                    Key.allV0Cases.forEach { key in
                        backupData[key.rawValue] = retrieve(key: key, autoDecrypt: false)
                    }
                    guard !backupData.isEmpty else {
                        break
                    }
                    if store(key: .backupV0,
                             obj: backupData) != errSecSuccess {
                        if let passcode = backupData[Key.passcode.rawValue] {
                            let encryptKey = SymmetricKey(data: passcode)
                            let backupDataEncrypted = try! ChaChaPoly.seal(try! JSONEncoder().encode(backupData),
                                                                           using: encryptKey)
                            _ = store(key: .backupV0, data: backupDataEncrypted.combined)
                        } else {
                            _ = store(key: .backupV0, obj: backupData)
                        }
                    }
                    Key.secureKeys.forEach { key in
                        if let data = backupData[key.rawValue] {
                            _ = store(key: key, data: data)
                        }
                    }
                    // Invalid after migrate to v1
                    Key.allV0DeprecatedCases.forEach { key in
                        _ = clear(key: key)
                    }
                    currentVersion += 1
                default: break
                }
            }
        }
    }

    func store<T: Encodable>(key: Key, obj: T, synchronizable: CFBoolean = kCFBooleanFalse) -> OSStatus {
        // swiftlint:disable force_try
        return store(key: key, data: try! JSONEncoder().encode(obj))
    }

    func store(key: Key, data: Data, synchronizable: CFBoolean = kCFBooleanFalse, autoEncrypt: Bool = true) -> OSStatus {
        var data = data
        if autoEncrypt, Key.secureKeys.contains(key) {
            data = try! KeyPair.manager.encrypt(data)
        }
        let addquery: [String: Any] = [kSecClass as String: kSecClassGenericPassword as String,
                                       kSecAttrAccount as String: key.rawValue,
                                       kSecValueData as String: data,
                                       kSecAttrSynchronizable as String: synchronizable]
        SecItemDelete(addquery as CFDictionary)
        return SecItemAdd(addquery as CFDictionary, nil)
    }

    func clear(key: Key) -> OSStatus {
        let addquery: [String: Any] = [kSecClass as String: kSecClassGenericPassword as String,
                                       kSecAttrAccount as String: key.rawValue,
                                       kSecAttrSynchronizable as String: kSecAttrSynchronizableAny]
        return SecItemDelete(addquery as CFDictionary)
    }

    func retrieve<T: Decodable>(key: Key, defaultValue: T?) -> T? {
        guard let data = retrieve(key: key) else {
            return defaultValue
        }
        return (try? JSONDecoder().decode(T.self, from: data)) ?? defaultValue
    }

    func retrieve(key: Key, autoDecrypt: Bool = true) -> Data? {
        let getquery: [String: Any] = [kSecClass as String: kSecClassGenericPassword as String,
                                       kSecAttrAccount as String: key.rawValue,
                                       kSecReturnData as String: kCFBooleanTrue!,
                                       kSecMatchLimit as String: kSecMatchLimitOne,
                                       kSecAttrSynchronizable as String: kSecAttrSynchronizableAny]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        guard status == errSecSuccess else {
            os_log("keyStore.retrieve SecItemCopyMatching error \(status)")
            return nil
        }

        guard let data = item as? Data? else {
            os_log("keyStore.retrieve not data")
            return nil
        }

        guard let data = data else {
            return nil
        }

        if autoDecrypt, Key.secureKeys.contains(key) {
            return try! KeyPair.manager.decrypt(data)
        }

        return data
    }
}

extension KeyChain {
    func encryptKeyInitialize() {
        guard encryptKey == nil else {
            return
        }

        let rawKeyData = UUID().uuidString.data(using: .utf8)!.sha256Data
        _ = store(key: .encryptKey, data: rawKeyData)
    }

    var encryptKey: Data? {
        return retrieve(key: .encryptKey)
    }
}
