//
//  CustomPresentedViewController.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 2/9/22.
//

import UIKit

class CustomPresentedViewController: UIViewController {
    // swiftlint:disable weak_delegate
    private var detailsTransitioningDelegate: InteractiveModalTransitioningDelegate!
    // swiftlint:disable identifier_name
    var _contentViewController: UIViewController?

    public init(onDismiss: (() -> Void)? = nil) {
        super.init(nibName: nil, bundle: nil)
        detailsTransitioningDelegate = InteractiveModalTransitioningDelegate(from: self, to: self)
        detailsTransitioningDelegate.onDismiss = onDismiss
        modalPresentationStyle = .custom
        transitioningDelegate = detailsTransitioningDelegate
    }

    override func updateViewConstraints() {
        self.view.frame.size.height = UIScreen.main.bounds.height - 350
        self.view.frame.origin.y = 350
        super.updateViewConstraints()
    }

    func set(contentViewController: UIViewController?) {
        if let vc = _contentViewController {
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }

        if let vc = contentViewController {
            addChild(vc)
            view.addSubview(vc.view)
            vc.view.frame.size = UIScreen.main.bounds.size
            vc.didMove(toParent: self)
        }

        _contentViewController = contentViewController
    }

    func track(scrollView: UIScrollView) {
        detailsTransitioningDelegate?.scrollView = scrollView
        scrollView.contentInsetAdjustmentBehavior = .never
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
