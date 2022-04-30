//
//  ContextActionType.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 28/10/21.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - ContextMenu Action Type
enum ContextActionType: Hashable {
    case shareEvent
    case openInMap
    case editEvent
    case deleteEvent
    case copy
    case showQRCode
//    case rename
    case disconnect
    case pay
    case message
    case editContact
    case deleteContact
    case info
    case blockExplorer
    case shop
    case flex
    case editAvatar
}

extension ContextActionType {
    var icon: UIImage? {
        switch self {
        case .shareEvent:
            return UIImage(systemName: "square.and.arrow.up")
        case .openInMap:
            return UIImage(systemName: "map")
        case .editEvent, .editContact, .editAvatar: // & .rename
            return UIImage(systemName: "square.and.pencil")
        case .deleteEvent:
            return UIImage(systemName: "trash")
        case .copy:
            return UIImage(systemName: "doc.on.doc")
        case .showQRCode:
            return UIImage(systemName: "qrcode")
        case .disconnect:
            return UIImage(systemName: "trash.fill")
        case .pay:
            return UIImage(systemName: "bitcoinsign.circle")
        case .message:
            return UIImage(systemName: "bubble.left.and.bubble.right")
        case .deleteContact:
            return UIImage(systemName: "trash")
        case .info:
            return UIImage(systemName: "info.circle")
        case .blockExplorer:
            return UIImage(systemName: "pawprint")
        case .shop:
            return UIImage(systemName: "tshirt")
        case .flex:
            return UIImage(systemName: "square.and.arrow.up")
        }
    }

    var title: String {
        switch self {
        case .shareEvent:
            return "Share Event"
        case .openInMap:
            return "Open in Map"
        case .editEvent:
            return "Edit Event"
        case .deleteEvent:
            return "Delete Event"
        case .copy:
            return "Copy Address"
        case .showQRCode:
            return "Show QR code"
//        case .rename:
//            return "Rename wallet"
        case .disconnect:
            return "Disconnect & Remove"
        case .info:
            return "Info"
        case .blockExplorer:
            return "Block Explorer"
        case .shop:
            return "Shop"
        case .flex:
            return "Flex"
        case .pay:
            return "Pay"
        case .message:
            return "Message"
        case .editContact:
            return "Edit Contact"
        case .deleteContact:
            return "Delete Contact"
        case .editAvatar:
            return "Edit Avatar"
        }
    }

    var attributes: UIMenuElement.Attributes {
        switch self {
        case .deleteEvent, .disconnect, .deleteContact:
            return [.destructive]
        default:
            return []
        }
    }
}
