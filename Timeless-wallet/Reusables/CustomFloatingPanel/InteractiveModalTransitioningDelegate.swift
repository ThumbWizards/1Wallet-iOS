//
//  InteractiveModalTransitioningDelegate.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 2/9/22.
//

import UIKit

class InteractiveModalTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    var interactiveDismiss = true
    weak var scrollView: UIScrollView? {
        didSet {
            customPresentationController?.scrollView = scrollView
        }
    }
    var customPresentationController: CustomPresentationController?
    var onDismiss: (() -> Void)?

    init(from presented: UIViewController, to presenting: UIViewController) {
        super.init()
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        customPresentationController = CustomPresentationController(presentedViewController: presented, presenting: presenting)
        customPresentationController?.scrollView = scrollView
        customPresentationController?.onDismiss = onDismiss
        return customPresentationController
    }
}
