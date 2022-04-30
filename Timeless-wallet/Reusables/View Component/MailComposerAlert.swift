//
//  MailComposerAlert.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 22/11/2021.
//

import SwiftUI
import UIKit

enum MailComposerAlert {
    struct MailAlertModel {
        let title = "Error launching email client"
        let subtitle = "Would you like to manually copy our feedback email address to your clipboard?"
        let copyButtonTitle = "Copy email address"
        let cancelButtonTitle = "Cancel"
    }

    static func cannotSendMailAlert() -> Alert {
        let model = MailAlertModel()
        return Alert(
            title: Text(model.title),
            message: Text(model.subtitle),
            primaryButton: .default(Text(model.copyButtonTitle)),
            secondaryButton: .cancel(Text(model.cancelButtonTitle)))
    }

    static func cannotSendMailAlertController() -> UIAlertController {
        let model = MailAlertModel()
        let alert = UIAlertController(title: model.title,
                                      message: model.subtitle,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: model.copyButtonTitle, style: .default, handler: { _ in
            showSnackBar(.copyFeedbackEmail)
            UIPasteboard.general.string = "hello@timeless.space"
        }))
        alert.addAction(UIAlertAction(title: model.cancelButtonTitle, style: .cancel, handler: nil))
        return alert
    }
}
