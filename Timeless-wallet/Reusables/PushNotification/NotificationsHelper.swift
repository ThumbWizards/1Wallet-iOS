//
//  NotificationsHelper.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 11/03/22.
//

import UIKit
import UserNotifications

class NotificationsHelper: NSObject {

    static let shared = NotificationsHelper()
    
    func configure() {
        UNUserNotificationCenter.current().delegate = self
    }

    /// Register For Remote Notifications
    func registerForRemoteNotifications() {
        let application = UIApplication.shared
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) {_, error in
            if error == nil {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }

    /// Handle Remote Notification
    ///
    /// - Parameter userInfo: Notification Data
    func handleRemoteNotification(with userInfo: [AnyHashable: Any]) {
        
    }
}

// MARK: UNUserNotificationCenterDelegate
extension NotificationsHelper: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userData = response.notification.request.content.userInfo
        handleRemoteNotification(with: userData)
        completionHandler()
    }
}
