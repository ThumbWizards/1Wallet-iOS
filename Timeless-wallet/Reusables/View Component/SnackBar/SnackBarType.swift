//
//  SnackBarType.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 16/11/2021.
//

import Foundation
import SwiftUI
import StreamChat
import StreamChatUI

enum SnackBarType {
    case none
    case error(_ error: Error? = nil)
    case backupDoesNotExist
    case backupCompleted
    case restoreCompleted
    case coppiedAddress
    case walletCreatedSuccessfully
    case insufficientBalance(name: String)
    case newContactCreated
    case contactSaved
    case redPacketClaimed
    case sendCancelled
    case copyFeedbackEmail
    case redPacketAmountValidation
    case message(text: String, hideIcon: Bool = false)
    case errorMsg(text: String)
    case transactionCancelled
    case walletTransactionFailed
    case copyTokenID
    case internetConnectionError
    case savedToPhotos
    case coppied
    case qrDetails(url: String, didTap: (() -> Void))
    case chatNotificationMute(text: String)
    case chatNotificationUnMute(text: String)
    case somethingWentWrongRandomText
    case redPacketMissedRandomText
    case redPacketExpiredRandomText
    case chatMessageCopied
}

extension SnackBarType {
    @ViewBuilder
    var view: some View {
        switch self {
        case .error(let error):
            if let error = error as? AddContactError {
                switch error {
                case .usernameNotFound:
                    SnackBarIconTextView(snackBarIcon: Image.exclamationMarkCircleFill,
                                         snackBarTitle: "Username not found",
                                         background: Color.snackBarBackground)

                case .addressNotValid:
                    SnackBarIconTextView(snackBarIcon: Image.exclamationMarkCircleFill,
                                         snackBarTitle: "Address you've entered is not valid",
                                         background: Color.snackBarBackground)

                }
            } else if let error = error as? API.APIError {
                switch error {
                case .noInternet:
                    SnackBarIconTextView(snackBarIcon: Image.exclamationMarkCircleFill,
                                         snackBarTitle: "Internet connection error",
                                         background: Color.snackBarBackground)
                default: SnackBarSomethingWentWrong()
                }
            } else {
                SnackBarSomethingWentWrong()

            }
        case .coppiedAddress:
            SnackBarIconTextView(snackBarIcon: Image.iconOKHand,
                                 snackBarTitle: "Wallet address copied",
                                 background: Color.snackBarBackground)
        case .backupDoesNotExist:
            SnackBarIconTextView(snackBarIcon: Image.exclamationMarkCircleFill,
                                 snackBarTitle: "Backup does not exist!",
                                 background: Color.snackBarBackground)
        case .backupCompleted:
            SnackBarIconTextView(snackBarIcon: Image.gift,
                                 snackBarTitle: "Backup successfully created",
                                 background: Color.snackBarBackground)
        case .restoreCompleted:
            SnackBarIconTextView(snackBarIcon: Image.gift,
                                 snackBarTitle: "Backup successfully restored",
                                 background: Color.snackBarBackground)
        case .walletCreatedSuccessfully:
            SnackBarIconTextView(snackBarIcon: Image.gift,
                                 snackBarTitle: "Wallet successfully created",
                                 background: Color.snackBarBackground)
        case .insufficientBalance(let name):
            SnackBarIconTextView(snackBarIcon: Image.exclamationMarkCircleFill,
                                 snackBarTitle: "Insufficient \(name) balance",
                                 background: Color.snackBarBackground)
        case .newContactCreated:
            SnackBarIconTextView(snackBarIcon: Image.gift,
                                 snackBarTitle: "New contact created",
                                 background: Color.snackBarBackground)
        case .contactSaved:
            SnackBarIconTextView(snackBarIcon: Image.gift,
                                 snackBarTitle: "Contact saved",
                                 background: Color.snackBarBackground)
        case .redPacketClaimed:
            SnackBarIconTextView(snackBarIcon: Image.gift,
                                 snackBarTitle: "RedPacket claimed successfully!",
                                 background: Color.snackBarBackground)

        case .sendCancelled:
            SnackBarIconTextView(snackBarIcon: Image.exclamationMarkCircleFill,
                                 snackBarTitle: "Send op successfully cancelled")

        case .copyFeedbackEmail:
            SnackBarIconTextView(snackBarIcon: Image.iconOKHand,
                                 snackBarTitle: "Email address copied",
                                 background: Color.snackBarBackground)

        case .redPacketAmountValidation:
            SnackBarIconTextView(snackBarIcon: Image.exclamationMarkCircleFill,
                                 snackBarTitle: "Try increasing the amount, Scrooge",
                                 background: Color.snackBarBackground)

        case let .message(message, hideIcon):
            SnackBarIconTextView(snackBarIcon: Image.exclamationMarkCircleFill,
                                 snackBarTitle: message,
                                 background: Color.snackBarBackground,
                                 hideIcon: hideIcon)

        case .errorMsg(text: let error):
            SnackBarIconTextView(snackBarIcon: Image.exclamationMarkCircleFill,
                                 snackBarTitle: error,
                                 background: Color.snackBarBackground)

        case .transactionCancelled:
            SnackBarIconTextView(snackBarIcon: Image.exclamationMarkCircleFill,
                                 snackBarTitle: "Transaction cancelled")

        case .walletTransactionFailed:
            SnackBarIconTextView(snackBarIcon: Image.exclamationMarkCircleFill,
                                 snackBarTitle: "Transaction failed",
                                 background: Color.snackBarBackground)

        case .copyTokenID:
            SnackBarIconTextView(snackBarIcon: Image.iconOKHand,
                                 snackBarTitle: "Token ID copied",
                                 background: Color.snackBarBackground)

        case .internetConnectionError:
            SnackBarIconTextView(snackBarIcon: Image.exclamationMarkCircleFill,
                                 snackBarTitle: "Internet connection error",
                                 background: Color.snackBarBackground)

        case .savedToPhotos:
            SnackBarIconTextView(snackBarIcon: Image.iconOKHand,
                                 snackBarTitle: "Saved to Photos",
                                 background: Color.snackBarBackground)

        case .coppied:
            SnackBarIconTextView(snackBarIcon: Image.iconOKHand,
                                 snackBarTitle: "copied",
                                 background: Color.snackBarBackground,
                                 showCheckMark: true)

        case let .qrDetails(url, didTap):
            SnackBarSubTitleView(
                snackBarIcon: Image.qrcode,
                snackBarTitle: "Website QR Code",
                snackBarSubtitle: "Open \(url) in safari",
                iconColor: .white,
                didTap: didTap
            )
        case .chatNotificationMute(let message):
            SnackBarIconTextView(snackBarIcon: Image.mute,
                                 snackBarTitle: message,
                                 background: Color.snackBarBackground)
        case .chatNotificationUnMute(let message):
            SnackBarIconTextView(snackBarIcon: Image.unMute,
                                 snackBarTitle: message,
                                 background: Color.snackBarBackground)
        case .somethingWentWrongRandomText:
            SnackBarSomethingWentWrong()
        case .redPacketMissedRandomText:
            SnackBarIconTextView(snackBarIcon: Image.turtle,
                                 snackBarTitle: Constants.RedPacketClaimedText.randomText.randomElement() ?? "",
                                 background: Color.snackBarBackground,
                                 customFrame: CGSize(width: 30, height: 20))
        case .redPacketExpiredRandomText:
            SnackBarIconTextView(snackBarIcon: Image.turtle,
                                 snackBarTitle: Constants.RedPacketExpiredText.randomText.randomElement() ?? "",
                                 background: Color.snackBarBackground,
                                 customFrame: CGSize(width: 30, height: 20))
        case .chatMessageCopied:
            SnackBarIconTextView(snackBarIcon: Image.docOnDoc,
                                 snackBarTitle: "Message copied to clipboard",
                                 background: Color.snackBarBackground)
        default:
            EmptyView()
        }
    }
}
