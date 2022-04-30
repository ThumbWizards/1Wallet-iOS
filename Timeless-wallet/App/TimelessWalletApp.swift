//
//  Timeless_walletApp.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 22/10/21.
//

import SwiftUI
import GetStream
import UIKit
import StreamChat

extension Notification.Name {
    // Used to refresh the whole app state in some certain cases like: logout, restore, ...
    static let appStateChange = Notification.Name("appStateChange")
}

@main
struct TimelessWalletApp: App {
    // swiftlint:disable weak_delegate
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate

    @ObservedObject private var cryptoViewModel = CryptoHelper.shared.viewModel
    @ObservedObject private var splashViewModel = SplashVideoView.ViewModel.shared
    @ObservedObject private var lock = Lock.shared

    @AppStorage(ASSettings.General.firstLaunch.key)
    private var firstLaunch = ASSettings.General.firstLaunch.defaultValue

    @AppStorage(ASSettings.General.appSetupState.key)
    private var appSetupState = ASSettings.General.appSetupState.defaultValue

    @AppStorage(ASSettings.Setting.testnetSetting.key)
    private var testnetSetting = ASSettings.Setting.testnetSetting.defaultValue

    @State private var showFullScreenCover = false
    @State private var mainId = UUID().uuidString

    static var firstAppear = true

    init() {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().tintColor = UIColor(Color.timelessBlue)
        initgetStreamClient()
    }

    private func initgetStreamClient() {
        Client.config = .init(apiKey: AppConstant.chatAPIKey,
                              appId: AppConstant.getStreamAppId,
                              logsEnabled: true)
    }
}

extension TimelessWalletApp {
    var body: some Scene {
        WindowGroup {
            ZStack {
                if IdentityService.shared.isAuthenticated {
                    ZStack {
                        mainView
                            .opacity(lock.isLocked ? 0 : 1)
                            .id(mainId)
                    }
                    /*.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification),
                               perform: { _ in
                        mainId = UUID().uuidString
                    })*/
                    .onReceive(NotificationCenter.default.publisher(for: .appStateChange),
                               perform: { _ in
                        mainId = UUID().uuidString
                    })
                } else {
                    onboardingView
                }
            }
            .opacity(splashViewModel.hideScreen ? 0 : 1)
            .animation(.default, value: splashViewModel.hideScreen)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                if splashViewModel.hideScreen {
                    splashViewModel.hideScreen = false
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                firstLaunch = true
            }
        }
    }
}

extension TimelessWalletApp {
    private var mainView: some View {
        NavigationView {
            TabBarView()
                .hideNavigationBar()
                .fullScreenCover(isPresented: $showFullScreenCover, onDismiss: { }, content: {
                    AppSetupView()
                })
                .onAppear {
                    DispatchQueue.global(qos: .userInitiated).async {
                        _ = Wallet.currentMerkleTree
                    }
                    if testnetSetting {
                        let statusBar = UIView(frame: CGRect(x: 0,
                                                             y: 0,
                                                             width: UIScreen.main.bounds.width,
                                                             height: UIView.safeAreaTop))
                        statusBar.backgroundColor = UIColor(Color.timelessRed)
                        statusBar.tag = 100
                        UIApplication.shared.windows.first?.addSubview(statusBar)
                    }
                    // Launch the initial app setup flow (username, passcode, backup, ...)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        switch appSetupState {
                        case ASSettings.AppSetupState.backup.rawValue: break
                        case ASSettings.AppSetupState.done.rawValue: break
                        default: showFullScreenCover = true
                        }
                    }
                }
                // Workaround : Universal Links Camera does not pass url to .onOpenURL
                // https://developer.apple.com/forums/thread/674141
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    guard let url = userActivity.webpageURL else {
                        return
                    }
                    if IdentityService.shared.isAuthenticated {
                        DeeplinkHelper.shared.handleDeepLink(url: url)
                    }
                }
                .onOpenURL { url in
                    if IdentityService.shared.isAuthenticated {
                        DeeplinkHelper.shared.handleDeepLink(url: url)
                    }
                }
        }
    }

    private var onboardingView: some View {
        NavigationView {
            OnboardingSplashScreenView()
                .hideNavigationBar()
        }
    }
}
