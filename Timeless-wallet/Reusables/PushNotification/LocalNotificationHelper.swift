//
//  LocalNotificationHelper.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 14/03/22.
//

import Foundation
import UserNotifications

class LocalNotificationHelper {
    static let identifier = "timeless-localnotification"

    static func requestNewMessageNotification(_ title: String, message: String) {
        let userNotificationCenter = UNUserNotificationCenter.current()
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.body = message
        notificationContent.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5,
                                                        repeats: false)
        let request = UNNotificationRequest(identifier: identifier,
                                            content: notificationContent,
                                            trigger: trigger)
        userNotificationCenter.add(request, withCompletionHandler: nil)
    }
}
