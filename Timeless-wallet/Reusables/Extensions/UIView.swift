//
//  UIView.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 27/10/2021.
//

import Foundation
import SwiftUI

extension UIView {

    static var hasNotch: Bool {
        if let window = UIApplication.shared.keyWindowInConnectedScenes {
            return window.safeAreaInsets.bottom > 0
        }
        return false
    }

    static var safeAreaBottom: CGFloat {
         if #available(iOS 11, *) {
            if let window = UIApplication.shared.keyWindowInConnectedScenes {
                return window.safeAreaInsets.bottom
            }
         }
         return 0
    }

    static var safeAreaTop: CGFloat {
         if #available(iOS 11, *) {
            if let window = UIApplication.shared.keyWindowInConnectedScenes {
                return window.safeAreaInsets.top
            }
         }
         return 0
    }

    static var safeAreaLeft: CGFloat {
         if #available(iOS 11, *) {
            if let window = UIApplication.shared.keyWindowInConnectedScenes {
                return window.safeAreaInsets.left
            }
         }
         return 0
    }

    static var safeAreaRight: CGFloat {
         if #available(iOS 11, *) {
            if let window = UIApplication.shared.keyWindowInConnectedScenes {
                return window.safeAreaInsets.right
            }
         }
         return 0
    }
}

extension UIView {
    func fit(subview: UIView, horizontalPadding: CGFloat = 0, verticalPadding: CGFloat = 0) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.willMove(toSuperview: self)
        addSubview(subview)
        addConstraints(NSLayoutConstraint
                        .constraints(withVisualFormat: "H:|-(\(horizontalPadding))-[subview]-(\(horizontalPadding))-|",
                                     options: [],
                                     metrics: nil,
                                     views: ["subview": subview]))
        addConstraints(NSLayoutConstraint
                        .constraints(withVisualFormat: "V:|-(\(verticalPadding))-[subview]-(\(verticalPadding))-|",
                                     options: [],
                                     metrics: nil,
                                     views: ["subview": subview]))
        subview.didMoveToSuperview()
    }

    func fit<T: View>(subview: T, ignoreSafeArea: Bool = true, enableInteraction: Bool = true, removeFromSuperview: Bool = false) {
        let hostView = UIHostingController(rootView: subview, ignoreSafeArea: ignoreSafeArea)
        hostView.view.backgroundColor = .clear
        if !enableInteraction {
            hostView.view.isUserInteractionEnabled = false
        }
        if removeFromSuperview {
            hostView.view.removeFromSuperview()
        }
        self.fit(subview: hostView.view!)
    }
}

extension UIView {
    func asImage(rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
