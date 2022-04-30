//
//  SendAccessoryView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 11/11/2021.
//

import UIKit
import SwiftUI

class SendAccessoryView: UIView {
    // hostingController contain the SendKeyboardToolbar
    var hostingController: UIHostingController<SendKeyboardToolbar>?
    var customHeightConstraint: NSLayoutConstraint?
    var containerHeightConstraint: NSLayoutConstraint?
    let containerView = UIView()

    init(frame: CGRect,
         hostingPermissionViewController: UIHostingController<SendKeyboardToolbar>
    ) {
        super.init(frame: frame)
        self.hostingController = hostingPermissionViewController
        addSubview(containerView)
        containerView.backgroundColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        containerHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: 44)
        containerHeightConstraint?.isActive = true

        guard let sendAccessoryView = hostingController?.view else { return }
        sendAccessoryView.backgroundColor = UIColor(Color.keyboardAccessoryBG)
        self.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        self.addSubview(sendAccessoryView)
        sendAccessoryView.translatesAutoresizingMaskIntoConstraints = false
        let bottomConstraint = NSLayoutConstraint(item: sendAccessoryView,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .bottom,
                                                  multiplier: 1,
                                                  constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: sendAccessoryView,
                                                   attribute: .leading,
                                                   relatedBy: .equal,
                                                   toItem: self,
                                                   attribute: .leading,
                                                   multiplier: 1,
                                                   constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: sendAccessoryView,
                                                    attribute: .trailing,
                                                    relatedBy: .equal,
                                                    toItem: self,
                                                    attribute: .trailing,
                                                    multiplier: 1,
                                                    constant: 0)
        addConstraints([bottomConstraint, leadingConstraint, trailingConstraint])
        customHeightConstraint = NSLayoutConstraint(item: sendAccessoryView,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: 44)
        sendAccessoryView.addConstraint(customHeightConstraint!)
    }

    func setHeight(height: CGFloat) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.customHeightConstraint?.constant = height
            self?.layoutSubviews()
        } completion: { _ in
            self.containerHeightConstraint?.constant = height
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        // Calculate intrinsicContentSize that will fit the content after extend or collapse
        let size = self.hostingController!.view.sizeThatFits(
            CGSize(
                width: self.hostingController!.view.bounds.width,
                height: CGFloat.greatestFiniteMagnitude
            )
        )
        return CGSize(width: self.bounds.width, height: size.height)
    }
}


class SendAccessoryAmountView: UIView {
    // hostingController contain the SendKeyboardToolbar
    var hostingController: UIHostingController<SendAmountToolbar>?
    var customHeightConstraint: NSLayoutConstraint?
    var containerHeightConstraint: NSLayoutConstraint?
    let containerView = UIView()

    init(frame: CGRect,
         hostingPermissionViewController: UIHostingController<SendAmountToolbar>
    ) {
        super.init(frame: frame)
        self.hostingController = hostingPermissionViewController
        addSubview(containerView)
        containerView.backgroundColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        containerHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: 44)
        containerHeightConstraint?.isActive = true

        guard let sendAccessoryView = hostingController?.view else { return }
        sendAccessoryView.backgroundColor = UIColor(Color.keyboardAccessoryBG)
        self.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        self.addSubview(sendAccessoryView)
        sendAccessoryView.translatesAutoresizingMaskIntoConstraints = false
        let bottomConstraint = NSLayoutConstraint(item: sendAccessoryView,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .bottom,
                                                  multiplier: 1,
                                                  constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: sendAccessoryView,
                                                   attribute: .leading,
                                                   relatedBy: .equal,
                                                   toItem: self,
                                                   attribute: .leading,
                                                   multiplier: 1,
                                                   constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: sendAccessoryView,
                                                    attribute: .trailing,
                                                    relatedBy: .equal,
                                                    toItem: self,
                                                    attribute: .trailing,
                                                    multiplier: 1,
                                                    constant: 0)
        addConstraints([bottomConstraint, leadingConstraint, trailingConstraint])
        customHeightConstraint = NSLayoutConstraint(item: sendAccessoryView,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: 44)
        sendAccessoryView.addConstraint(customHeightConstraint!)
    }

    func setHeight(height: CGFloat) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.customHeightConstraint?.constant = height
            self?.layoutSubviews()
        } completion: { _ in
            self.containerHeightConstraint?.constant = height
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        // Calculate intrinsicContentSize that will fit the content after extend or collapse
        let size = self.hostingController!.view.sizeThatFits(
            CGSize(
                width: self.hostingController!.view.bounds.width,
                height: CGFloat.greatestFiniteMagnitude
            )
        )
        return CGSize(width: self.bounds.width, height: size.height)
    }
}
