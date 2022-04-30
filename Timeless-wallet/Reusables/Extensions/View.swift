//
//  View+Extension.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 10/25/21.
//

import SwiftUI
import SwiftUIX
import Combine
import SwiftMessages

func push<V: View>(_ view: V) {
    let uiView = UIHostingController(rootView: view)
    uiView.view.backgroundColor = UIColor(Color.clear)

    UIApplication.shared.topmostViewController?.nearestNavigationController?.pushViewController(uiView, animated: true)
}

func present<V: View>(_ view: V, presentationStyle: ModalPresentationStyle? = nil) {
    UIApplication.shared.topmostViewController?.present(view, presentationStyle: presentationStyle)
}

func present(_ view: UIViewController, animated: Bool = true) {
    UIApplication.shared.topmostViewController?.present(view, animated: animated, completion: nil)
}

@discardableResult
func dismiss() -> Future<Bool, Never>? {
    UIApplication.shared.topmostViewController?.dismissSelf()
}

func dismissAll(callBack: (() -> Void)? = nil) {
    UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true,
                                                                    completion: { callBack?() })
}

func pop() {
    UIApplication.shared.topmostViewController?.nearestNavigationController?.popViewController(animated: true)
}

extension View {
    func subtleBlinkAndBounce(
        duration: TimeInterval = SubtleBlinkAndBounceViewModifier.defaultAnimationDuration
    ) -> some View {
        modifier(
            SubtleBlinkAndBounceViewModifier(
                duration: duration
            )
        )
    }
    /// Context Menu
    /// - Parameters:
    ///   - preview: Custom preview view
    ///   - preferredContentSize: Preview size
    ///   - actions: Array of all actions
    ///   - onActionBlock: Action block
    /// - Returns: previewContextView
    func previewContextMenu<Preview: View>(
        preview: Preview,
        preferredContentSize: CGSize? = nil,
        actions: [ContextActionType] = [],
        onActionBlock: ((ContextActionType) -> Void)? = nil,
        detailAction: (() -> Void)? = nil
    ) -> some View {
        modifier(
            PreviewContextViewModifier<Preview>(
                preview: preview,
                preferredContentSize: preferredContentSize,
                actions: actions,
                onActionBlock: onActionBlock,
                detailAction: detailAction
            )
        )
    }
}

extension View {
    func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyleModifier(radius: radius, corners: corners))
    }
}

let snakBarMessages = SwiftMessages()
func showSnackBar(_ type: SnackBarType) {
    var config = snakBarMessages.defaultConfig
    config.presentationStyle = .top
    config.duration = .seconds(seconds: 3)
    config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)

    let view = UIHostingController(rootView: type.view).view
    view!.backgroundColor = UIColor(Color.clear)
    snakBarMessages.show(config: config, view: view!)
}

func hideSnackBar() {
    snakBarMessages.hide()
}

let confirmMessages = SwiftMessages()
func showConfirmation(_ type: ConfirmationType, interactiveHide: Bool = true, isBlur: Bool = false) {
    var config = confirmMessages.defaultConfig
    config.interactiveHide = interactiveHide
    config.presentationStyle = .bottom
    config.duration = .forever
    if isBlur {
        config.dimMode = .blur(style: .regular, alpha: 1, interactive: interactiveHide)
    } else {
        config.dimMode = .color(color: UIColor(red: 0 / 255.0,
                                               green: 0 / 255.0,
                                               blue: 0 / 255.0,
                                               alpha: 0.7),
                                interactive: interactiveHide)
    }
    config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)

    let view = UIHostingController(rootView: type.view,
                                   ignoreSafeArea: true).view
    view!.backgroundColor = UIColor(Color.clear)
    confirmMessages.show(config: config, view: view!)
}

func hideConfirmationSheet() {
    confirmMessages.hide()
}

extension View {
    public func asUIImage(backgroundColor: UIColor? = nil) -> UIImage {
        // This function changes our View to UIView, then calls another function
        // to convert the newly-made UIView to a UIImage.
        let controller = UIHostingController(rootView: self)

        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)

        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        if backgroundColor != nil {
            controller.view.backgroundColor = backgroundColor
        }

        // Here is the call to the function that converts UIView to UIImage: `.asImage()`
        let image = controller.view.asUIImage()
        controller.view.removeFromSuperview()
        return image
    }
}

extension UIView {
    public func asUIImage() -> UIImage {
        // This is the function to convert UIView to UIImage
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
            .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}
