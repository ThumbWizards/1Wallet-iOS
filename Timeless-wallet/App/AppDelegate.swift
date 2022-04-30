//
//  AppDelegate.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 10/27/21.
//

import UIKit
import Sentry
import StreamChatUI
import Firebase
import Stipop
import StreamChat
import UserNotifications
import VideoPlayer
import GiphyUISDK

class AppDelegate: NSObject, UIApplicationDelegate {
    @UserDefault(
        key: ASSettings.General.firstLaunch.key,
        defaultValue: ASSettings.General.firstLaunch.defaultValue
    )
    private var firstLaunch: Bool?
    @UserDefault(
        key: ASSettings.Settings.lastUnlockTime.key,
        defaultValue: ASSettings.Settings.lastUnlockTime.defaultValue
    )
    private var lastUnlockTime: Date?
    @UserDefault(
        key: ASSettings.NotificationService.deviceToken.key,
        defaultValue: ASSettings.NotificationService.deviceToken.defaultValue
    )
    private var deviceToken: Data?
    static var orientationLock = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        application.registerForRemoteNotifications()
        lastUnlockTime = nil
        // Validate environment variables
        AppConstant.validate()
        VideoPlayer.preloadByteCount = 1024 * 1024 * 10 // = 10M
        // Create a Sentry client and start crash handler
        startSentry()
        chatClientConfig()
        configDynamicLink()
        Stipop.initialize()
        requestAuthorization()
        return true
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            shortcutItemToProcess = shortcutItem
        }
        let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = CustomSceneDelegate.self

        return sceneConfiguration
    }
}

// MARK: - Push notifications
extension AppDelegate {
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        self.deviceToken = deviceToken
        guard ChatClient.shared.currentUserId != nil else {
            return
        }
        GetStreamChat.shared.addDeviceTokenTOCurrentUser(token: deviceToken)
    }
}

extension AppDelegate {
    // sentry
    func startSentry() {
        #if !DEBUG
        SentrySDK.start { options in
            options.dsn = "https://b908b8e81cc74ca49f93d9b3eb144f5b@o307284.ingest.sentry.io/6104623"
        }
        #endif
    }

    // inject apikeys in getStream sdk
    func chatClientConfig() {
        ChatClientConfiguration.shared.apiKey = AppConstant.chatAPIKey
        StickerApi.apiKey = AppConstant.stipopAPIKey
        Giphy.configure(apiKey: AppConstant.giphyAPIKey)
        StickerApi.userId = ChatClient.shared.currentUserId?.string ?? ""
    }

    func configDynamicLink() {
        #if Release
        let filePath = Bundle.main.path(forResource: "GoogleService-Info-release", ofType: "plist")!
        let options = FirebaseOptions(contentsOfFile: filePath)
        FirebaseApp.configure(options: options!)
        #else
        let filePath = Bundle.main.path(forResource: "GoogleService-Info-debug", ofType: "plist")!
        let options = FirebaseOptions(contentsOfFile: filePath)
        FirebaseApp.configure(options: options!)
        #endif
    }

    private func requestAuthorization() {
        NotificationsHelper.shared.configure()
        NotificationsHelper.shared.registerForRemoteNotifications()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        firstLaunch = true
    }
}
