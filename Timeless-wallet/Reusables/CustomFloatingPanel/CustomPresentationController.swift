//
//  CustomPresentationController.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 2/9/22.
//

import UIKit

enum ModalScaleState {
    case presentation
    case interaction
}

class CustomPresentationController: UIPresentationController {
    private let presentedYOffset: CGFloat = 400
    private let minimumPresentedYOffset: CGFloat = 60
    private let maximumScale: CGFloat = 0.89
    private var direction: CGFloat = 0
    private var state: ModalScaleState = .interaction
    private var beginY: CGFloat = 0
    private var maxCornerRadius: CGFloat = 20
    private var currentRadius: CGFloat = 38.5
    var isFull = false
    var onDismiss: (() -> Void)?

    private lazy var dimmingView: UIView! = {
        let container = presentedViewController.view!
        let view = UIView(frame: container.bounds)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.alpha = 0
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTap(tap:)))
        )
        return view
    }()

    // Scroll handling
    private var initialScrollOffset: CGPoint = .zero
    private var stopScrollDeceleration = false
    private var scrollBounce = false
    private var scrollIndictorVisible = false

    weak var scrollView: UIScrollView? {
        didSet {
            oldValue?.panGestureRecognizer.removeTarget(self, action: nil)
            scrollView?.panGestureRecognizer.addTarget(self, action: #selector(didPan(pan:)))
        }
    }

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(pan:)))
        panGesture.delegate = self
        presentedViewController.view.addGestureRecognizer(panGesture)
        currentRadius = UIView.safeAreaBottom != 0 ? 38.5 : 0
        presentedViewController.view.layer.cornerRadius = 10
        presentedViewController.view.clipsToBounds = true
    }

    @objc func didPan(pan: UIPanGestureRecognizer) {
        guard let view = pan.view, let superView = view.superview,
              let presented = presentedView, let container = containerView else { return }

        let location = pan.translation(in: superView)

        switch pan.state {
        case .began:
            presented.frame.size.height = container.frame.height
            beginY = presented.frame.origin.y
        case .changed:
            let velocity = pan.velocity(in: superView)
            var yValue = beginY + location.y
            yValue = max(yValue, minimumPresentedYOffset)
            presented.frame.origin.y = yValue
            if yValue == minimumPresentedYOffset {
                unlockScrollView()
            } else {
                lockScrollView()
            }
            let percentage: CGFloat
            let percentageRadius: CGFloat
            if yValue >= presentedYOffset {
                percentage = 1
                percentageRadius = 0
            } else {
                let proportion = (yValue - minimumPresentedYOffset) / (presentedYOffset - minimumPresentedYOffset)
                percentageRadius = (1 - proportion)
                percentage = proportion * (1 - maximumScale) + maximumScale
            }
            direction = velocity.y
            presentingViewController.view.transform = CGAffineTransform(scaleX: percentage, y: percentage)
            let cornerRadius = currentRadius + (maxCornerRadius - currentRadius) * percentageRadius
//            presentingViewController.view.layer.cornerRadius = cornerRadius
        case .ended:
            if direction > 0 {
                containerView?.isUserInteractionEnabled = false
                presentedViewController.view.isUserInteractionEnabled = false
                presentedViewController.dismiss(animated: true, completion: nil)
                containerView?.isUserInteractionEnabled = false
                return
            }
            let maxPresentedY = container.frame.height - presentedYOffset
            switch presented.frame.origin.y {
            case 0...maxPresentedY:
                changeScale(to: .interaction)
            default:
                containerView?.isUserInteractionEnabled = false
                presentedViewController.view.isUserInteractionEnabled = false
                presentedViewController.dismiss(animated: true, completion: nil)
            }
            unlockScrollView()
        default:
            break
        }
    }

    @objc func didTap(tap: UITapGestureRecognizer) {
        containerView?.isUserInteractionEnabled = false
        presentedViewController.view.isUserInteractionEnabled = false
        presentedViewController.dismiss(animated: true, completion: nil)
    }

    func changeScale(to state: ModalScaleState) {
        guard let presented = presentedView else { return }

        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
            guard let self = self else { return }
            if self.direction > 1 {
                presented.frame.origin.y = self.presentedYOffset
                self.isFull = false
                self.presentingViewController.view.transform = CGAffineTransform(scaleX: 1, y: 1)
//                self.presentingViewController.view.layer.cornerRadius = self.currentRadius
            } else {
                self.isFull = true
                presented.frame.origin.y = self.minimumPresentedYOffset
                self.presentingViewController.view.transform = CGAffineTransform(scaleX: self.maximumScale, y: self.maximumScale)
//                self.presentingViewController.view.layer.cornerRadius = self.maxCornerRadius
            }
        }, completion: { _ in
            self.state = state
        })
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard containerView != nil else { return .zero }
        return CGRect(x: 0,
                      y: self.presentedYOffset,
                      width: UIScreen.main.bounds.width,
                      height: UIScreen.main.bounds.height - self.presentedYOffset)
    }

    override func presentationTransitionWillBegin() {
        guard dimmingView.superview == nil else { return }
        containerView?.addSubview(dimmingView)
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.dimmingView.alpha = 0.5
        }
    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator else { return }
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            self.dimmingView.alpha = 0
            self.presentingViewController.view.transform = CGAffineTransform(scaleX: 1, y: 1)
//            self.presentingViewController.view.layer.cornerRadius = self.currentRadius
            }) { [weak self] _ in
            self?.onDismiss?()
        }
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }

    private func lockScrollView() {
        scrollView?.isScrollEnabled = false
    }

    private func unlockScrollView() {
        scrollView?.isScrollEnabled = true
    }

    private func stopScrolling(at contentOffset: CGPoint) {
        // Must use setContentOffset(_:animated) to force-stop deceleration
        guard let scrollView = scrollView else { return }
        var offset = scrollView.contentOffset
        setValue(contentOffset, to: &offset)
        scrollView.setContentOffset(offset, animated: false)
    }

    func setValue(_ newValue: CGPoint, to point: inout CGPoint) {
        point.y = newValue.y
    }
}

extension CustomPresentationController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
