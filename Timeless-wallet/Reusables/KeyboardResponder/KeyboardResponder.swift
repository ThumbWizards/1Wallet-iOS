//
//  KeyboardResponder.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 09/11/2021.
//

import SwiftUI
import Combine

struct KeyboardAwareModifier: ViewModifier {
    @Binding var keyboardHeight: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(.bottom, 0) // must have
            .onReceive(Publishers.keyboardHeight) { keyboardHeight = $0 }
    }
}

extension View {
    func keyboardAppear(keyboardHeight: Binding<CGFloat>) -> some View {
        ModifiedContent(content: self, modifier: KeyboardAwareModifier(keyboardHeight: keyboardHeight))
    }
}

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

extension UIResponder {
    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }

    private static weak var _currentFirstResponder: UIResponder?

    @objc private func findFirstResponder(_ sender: Any) {
        UIResponder._currentFirstResponder = self
    }

    var globalFrame: CGRect? {
        guard let view = self as? UIView else { return nil }
        return view.superview?.convert(view.frame, to: nil)
    }
}

extension View {
    // Todo: this func does not work perfectly, we will find another approach
    func keyboardSensible(_ offsetValue: Binding<CGFloat>, minusOffset: CGFloat = 0) -> some View {
    return self
        .padding(.bottom, offsetValue.wrappedValue - minusOffset)
        .animation(.spring())
        .onAppear {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                               object: nil,
                                               queue: .main) { notification in

            let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first

            let bottom = keyWindow?.safeAreaInsets.bottom ?? 0

            let value = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
            let height = value.height

            offsetValue.wrappedValue = height - bottom
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                               object: nil,
                                               queue: .main) { _ in
            offsetValue.wrappedValue = 0
        }
    }
  }
}
