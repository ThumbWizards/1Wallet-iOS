//
//  Lock.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 03/11/2021.
//

import Foundation
import CryptoKit
import LocalAuthentication
import SwiftUI

class Lock: ObservableObject {
    static var shared = Lock()
    var firstTimeRequestLock = true
    @AppStorage(ASSettings.General.appSetupState.key)
    private var appSetupState = ASSettings.General.appSetupState.defaultValue
    @AppStorage(ASSettings.Settings.lockMethod.key)
    private var lockMethod = ASSettings.Settings.lockMethod.defaultValue
    @AppStorage(ASSettings.Settings.autoLockType.key)
    private var autoLockType = ASSettings.Settings.autoLockType.defaultValue
    @AppStorage(ASSettings.General.firstLaunch.key)
    private var firstLaunch = ASSettings.General.firstLaunch.defaultValue
    @UserDefault(
        key: ASSettings.Settings.lastUnlockTime.key,
        defaultValue: nil
    )
    private var lastUnlockTime: Date?

    @UserDefault(
        key: ASSettings.Settings.lastEnterBackgroundTime.key,
        defaultValue: nil
    )
    private var lastEnterBackgroundTime: Date?

    init() {
        appLockEnable = passcode != nil
        isLocked = appLockEnable
        // swiftlint:disable discarded_notification_center_observer
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification,
                                               object: nil,
                                               queue: .main) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.isLocked = self.appLockEnable
            self.dismissModalStack()
        }
        // swiftlint:disable discarded_notification_center_observer
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification,
                                               object: nil,
                                               queue: .main) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.isLocked = true
            self.lastEnterBackgroundTime = Date()
        }
    }

    @Published var appLockEnable = true
    @Published var isLocked = true
    var isPresentBiometricView = false

    var passcode: Data? {
        return KeyChain.shared.retrieve(key: .passcode)
    }

    func setPasscode(_ password: String) -> OSStatus {
        let status = KeyChain.shared.store(key: .passcode, data: password.data(using: .utf8)!.sha256Data)
        if status == errSecSuccess {
            appLockEnable = true
        }
        return status
    }

    func removePasscode() -> OSStatus {
        let status = KeyChain.shared.clear(key: .passcode)
        if status == errSecSuccess {
            appLockEnable = false
        }
        return status
    }

    func isPasscodeValid(_ checkingPasscode: String) -> Bool {
        return checkingPasscode.data(using: .utf8)!.sha256Data == passcode
    }

    func handleDeeplink() {
        if let url = DeeplinkHelper.shared.deeplinkUrl {
            DeeplinkHelper.shared.executeDeeplink(url)
        }
    }

    // swiftlint:disable line_length
    func requestUnlock(shouldRefreshApp: Bool = false) {
        appLockEnable = passcode != nil && lockMethod != ASSettings.LockMethod.none.rawValue
        var isExpired = true
        if let lastUnlockTime = lastUnlockTime {
            isExpired = Date() >= lastUnlockTime + (
                ASSettings.AutoLockType(rawValue: autoLockType) ?? .immediately).lockTimeInterval
        }
        isLocked = appLockEnable && isExpired
        if isLocked {
            guard !isPresentBiometricView else { return }
            let host = UIHostingController(rootView: BiometricView(callback: { [weak self] isAuthenticated in
                guard let self = self else {
                    return
                }
                self.isLocked = !isAuthenticated
                if isAuthenticated {
                    self.lastUnlockTime = Date()
                    self.handleDeeplink()
                }
            }, isShowSplash: firstLaunch).onDisappear { [weak self] in
                guard let self = self else {
                    return
                }
                self.isPresentBiometricView = false
                if shouldRefreshApp {
                    hideSnackBar()
                    hideConfirmationSheet()
                }
                guard !quickActionHandler(), Lock.shared.firstTimeRequestLock else {
                    Lock.shared.firstTimeRequestLock = false
                    return
                }
                Lock.shared.firstTimeRequestLock = false
                guard self.appSetupState == ASSettings.AppSetupState.backup.rawValue else {
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    present(BackupICloudPasswordView())
                }
            })
            host.modalPresentationStyle = .overFullScreen
            host.modalTransitionStyle = .crossDissolve
            present(host, animated: false)
            isPresentBiometricView = true
        } else {
            guard !isPresentBiometricView else { return }
            if firstLaunch {
                let host = UIHostingController(rootView: SplashVideoView(isPlayingSplash: .constant(true), isLocked: false).onDisappear { [weak self] in
                    guard let self = self else { return }
                    self.nonPassCodeSetup(shouldRefreshApp)
                })
                host.modalPresentationStyle = .overFullScreen
                host.modalTransitionStyle = .crossDissolve
                present(host, animated: false)
            } else {
                nonPassCodeSetup(shouldRefreshApp)
            }
        }
    }

    private func nonPassCodeSetup(_ shouldRefreshApp: Bool) {
        if shouldRefreshApp {
            hideSnackBar()
            hideConfirmationSheet()
        }
        if IdentityService.shared.isAuthenticated {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let self = self else { return }
                self.handleDeeplink()
            }
            if !TimelessWalletApp.firstAppear {
                _ = quickActionHandler()
            } else {
                TimelessWalletApp.firstAppear = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    switch self.appSetupState {
                    case ASSettings.AppSetupState.backup.rawValue:
                        if !Lock.shared.appLockEnable, !quickActionHandler() {
                            present(BackupICloudPasswordView())
                        }
                    case ASSettings.AppSetupState.done.rawValue:
                        if !Lock.shared.appLockEnable {
                            _ = quickActionHandler()
                        }
                    default: present(AppSetupView(), presentationStyle: .overFullScreen)
                    }
                }
            }
        }
    }

    // Require verify with biometric or passcode for an action
    func requireAuthetication(for action: @escaping (Bool) -> Void) {
        UIApplication.shared.endEditing()
        guard passcode != nil else {
            action(true)
            return
        }
        bioAuth { fallbackToPasscode in
            if fallbackToPasscode {
                present(BiometricView(callback: action, skipBioAuth: true).hideNavigationBar(),
                        presentationStyle: .overFullScreen)
            } else {
                action(true)
            }
        }
    }

    func bioAuth(fallbackToPasscode: @escaping (Bool) -> Void) {
        guard lockMethod == ASSettings.LockMethod.passcodeBiometric.rawValue else {
            fallbackToPasscode(true)
            return
        }
        let context = LAContext()
        var error: NSError?
        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            var reason = ""
            switch context.biometryType {
            case .faceID:
                reason = "Use Face ID to authorize"
            case .touchID:
                reason = "Use Touch ID to authorize"
            case .none:
                break
            @unknown default:
                break
            }
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                DispatchQueue.main.async {
                    fallbackToPasscode(!success)
                }
            }
        } else {
            fallbackToPasscode(true)
        }
    }
}

extension Lock {
    private func resetAppState() {
        CreateWalletViewModel.shared.isLoading = false
        TabBarView.ViewModel.shared.selectedTab = 1 // 0: Discover | 1: WalletView | 2: Chat
    }

    private func dismissModalStack() {
        let shouldRefreshApp = lastEnterBackgroundTime == nil ? false : lastEnterBackgroundTime! <= Date() - 10 * 60
        if shouldRefreshApp {
            UIApplication.shared.endEditing()
        }
        if let viewController = UIApplication.shared.topmostViewController,
           viewController.presentingViewController != nil,
           shouldRefreshApp {
            var refreshApp = true
            if IdentityService.shared.isAuthenticated {
                switch appSetupState {
                case ASSettings.AppSetupState.backup.rawValue: break
                case ASSettings.AppSetupState.done.rawValue: break
                default: refreshApp = false
                }
            }
            if refreshApp {
                var vcc = viewController.presentingViewController!
                while vcc.presentingViewController != nil {
                    vcc = vcc.presentingViewController!
                }
                vcc.dismiss(animated: false) {
                    self.resetAppState()
                    self.requestUnlock(shouldRefreshApp: shouldRefreshApp)
                }
            }
        } else {
            if shouldRefreshApp {
                resetAppState()
            }
            requestUnlock(shouldRefreshApp: shouldRefreshApp)
        }
    }
}
