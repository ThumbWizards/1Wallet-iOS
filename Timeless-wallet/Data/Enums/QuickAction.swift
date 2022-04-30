//
//  QuickAction.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 08/11/2021.
//

import UIKit
import SwiftUI

struct QuickAction: Hashable {
    var type: String
    var title: String
    var subtitle: String
    var icon: String

    func quickAction() -> UIApplicationShortcutItem {
        return UIApplicationShortcutItem(type: self.type,
                                         localizedTitle: self.title,
                                         localizedSubtitle: self.subtitle,
                                         icon: .init(systemImageName: self.icon),
                                         userInfo: ["type": self.type as NSSecureCoding])
    }
}

enum ActionTypes: CaseIterable {
    case receive
    case send
    case scan

    var instance: QuickAction {
        switch self {
        case .receive: return QuickAction(type: "receive",
                                             title: "Receive",
                                             subtitle: "",
                                             icon: "qrcode")
        case .send: return QuickAction(type: "send",
                                             title: "Send",
                                             subtitle: "",
                                             icon: "paperplane")
        case .scan: return QuickAction(type: "scan",
                                               title: "Scan",
                                               subtitle: "",
                                               icon: "qrcode.viewfinder")
        }
    }
}

let allDynamicActions: [QuickAction] = [
    ActionTypes.receive.instance,
    ActionTypes.send.instance,
    ActionTypes.scan.instance,
]

var shortcutItemToProcess: UIApplicationShortcutItem?

class CustomSceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        shortcutItemToProcess = shortcutItem
    }

    func sceneWillResignActive(_ scene: UIScene) {
        if IdentityService.shared.isAuthenticated {
            var shortcutItems: [UIApplicationShortcutItem] = []
            for action in allDynamicActions {
                shortcutItems.append(action.quickAction())
            }
            UIApplication.shared.shortcutItems = shortcutItems
        } else {
            UIApplication.shared.shortcutItems = []
        }
    }
}

func quickActionHandler() -> Bool {
    guard let type = shortcutItemToProcess?.userInfo?["type"] as? String, !Wallet.allWallets.isEmpty else {
        return false
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        switch type {
        case "send":
            present(NavigationView { SendView().hideNavigationBar() })
        case "scan":
            Utils.scanWallet { strScanned in
                showConfirmation(.qrOptions(result: strScanned))
            }
        case "receive":
            present(ProfileModal(wallet: WalletInfo.shared.currentWallet), presentationStyle: .fullScreen)
        default: break
        }
        shortcutItemToProcess = nil
    }

    return true
}
