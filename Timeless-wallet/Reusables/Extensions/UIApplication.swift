//
//  UIApplication.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 27/10/2021.
//

import Foundation
import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    var keyWindowInConnectedScenes: UIWindow? {
        return UIApplication.shared.connectedScenes
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }

    func getTopViewController() -> UIViewController? {
        if var topController = keyWindowInConnectedScenes?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return keyWindowInConnectedScenes?.rootViewController
    }
}

// Confetti animation
extension UIApplication {
    func startConfettiAnimation() {
        stopConfettiAnimation()
        guard let viewWindow = getApplicationWindow() else { return }
        let animationView = ConfettiSuccessAnimation(frame: .zero)
        viewWindow.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: viewWindow.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: viewWindow.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: viewWindow.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: viewWindow.bottomAnchor)
        ])
    }

    private func getApplicationWindow() -> UIWindow? {
        return keyWindowInConnectedScenes
    }

    func stopConfettiAnimation() {
        getApplicationWindow()?.subviews
            .filter({ $0 is ConfettiSuccessAnimation })
            .forEach({ $0.removeFromSuperview() })
    }
}
