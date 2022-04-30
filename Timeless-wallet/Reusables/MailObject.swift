//
//  MailObject.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 22/11/2021.
//

import MessageUI

class MailObject: NSObject, MFMailComposeViewControllerDelegate {
    static let shared = MailObject()

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

    func sendMail(subject: String,
                  recipients: [String],
                  ccRecipients: [String]? = nil,
                  body: String,
                  presentingVC: UIViewController? = UIApplication.shared.getTopViewController()) {
        if !MFMailComposeViewController.canSendMail() {
            presentingVC?.present(MailComposerAlert.cannotSendMailAlertController(), animated: true)
            return
        }
        let mail = MFMailComposeViewController()
        mail.setSubject(subject)
        mail.mailComposeDelegate = self
        mail.setToRecipients(recipients)
        mail.setCcRecipients(ccRecipients)
        mail.setMessageBody(body, isHTML: false)
        presentingVC?.present(mail, animated: true)
    }
}

class MessageObject: NSObject, MFMessageComposeViewControllerDelegate {
    static let shared = MessageObject()
    var complete: (() -> Void)?

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .sent:
            controller.dismiss(animated: true) {
                self.complete?()
            }
        default:
            controller.dismiss(animated: true)
        }
    }

    func message(phoneNumber: String,
                 body: String,
                 presentingVC: UIViewController? = UIApplication.shared.getTopViewController()) {
        if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            controller.messageComposeDelegate = self
            controller.recipients = [phoneNumber]
            controller.body = body
            presentingVC?.present(controller, animated: true)
        }
    }
}
