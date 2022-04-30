//
//  BiometricView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 10/26/21.
//

import SwiftUI
import LocalAuthentication
import Introspect

struct BiometricView {
    @StateObject private var viewModel = ViewModel()
    @State private var isShowPassCode = false
    @State private var attempts = 1.0
    @State private var errorColorDisplay = false
    @State private var isPlayingSplash = false
    @State private var alreadyDismiss = false
    @State private var animateSplash = false
    @State private var textField: UITextField?
    @State private var keyboardHeight = CGFloat.zero
    @State private var authenticatedSuccess = false
    @AppStorage(ASSettings.Settings.lockMethod.key)
    private var lockMethod = ASSettings.Settings.lockMethod.defaultValue
    private let generator = UINotificationFeedbackGenerator()
    var callback: (Bool) -> Void
    var isShowSplash = false
    var skipBioAuth = false
}

extension BiometricView: View {
    var body: some View {
        ZStack {
            if isShowSplash {
                ZStack {
                    Color.black
                    SplashVideoView(isPlayingSplash: $isPlayingSplash)
                        .scaleEffect(animateSplash ? 1 : 0.7)
                        .opacity(animateSplash ? 1 : 0)
                }
            }
            ZStack {
                Color.primaryBackground
                passCodeView
            }
            .opacity(isPlayingSplash ? 0 : 1)
        }
        .ignoresSafeArea()
        .keyboardAppear(keyboardHeight: $keyboardHeight)
        .onChange(of: keyboardHeight) { value in
            if value > 0, authenticatedSuccess {
                textField?.resignFirstResponder()
            }
        }
        .onAppear {
            enableBioAuth()
        }
        .onDisappear {
            textField = nil
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification, object: nil)) { _ in
            enableBioAuth()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            if isPlayingSplash {
                dismiss()
                callback(true)
                alreadyDismiss = true
            }
        }
    }
}

extension BiometricView {
    private var passCodeView: some View {
        VStack {
            Text("Enter your current passcode")
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(Color.white.opacity(0.9))
            ZStack {
                HStack(spacing: 22) {
                    ForEach(0 ..< 6) { index in
                        self.passCodeCircleView(for: viewModel.passCode, at: index)
                    }
                }
                .padding(.bottom, UIScreen.main.bounds.height * 0.32)
                .modifier(ShakeAnimation(animatableData: CGFloat(attempts)))

                if !authenticatedSuccess {
                    TextField("", text: $viewModel.passCode)
                        .keyboardType(.numberPad)
                        .opacity(0)
                        .introspectTextField { textField in
                            if self.textField == nil {
                                self.textField = textField
                                self.textField?.keyboardAppearance = .dark
                                if self.authenticatedSuccess {
                                    self.textField?.resignFirstResponder()
                                } else {
                                    self.textField?.becomeFirstResponder()
                                }
                            }
                        }
                        .onChange(of: viewModel.passCode) { newCode in
                            guard newCode.count <= 6 else {
                                return
                            }
                            Utils.playHapticEvent()
                            if newCode.count == 6 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    viewModel.passCode = newCode
                                    if Lock.shared.isPasscodeValid(viewModel.passCode) {
                                        //success
                                        onAuthenticatedSuccess(isPasscode: true)
                                    } else {
                                        //error
                                        generator.notificationOccurred(.error)
                                        errorColorDisplay = true
                                        withAnimation(.default) {
                                            self.attempts += 1
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                            errorColorDisplay = false
                                            viewModel.passCode = ""
                                        }
                                    }
                                }
                            }
                        }
                }
            }
        }
    }

    private func passCodeCircleView(for code: String, at index: Int) -> some View {
        ZStack {
            if index < code.count {
                Image.circleFill
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(errorColorDisplay ? Color.timelessRed : Color.timelessBlue)
            } else {
                Image.circle
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(errorColorDisplay ? Color.timelessRed : Color.white60)
            }
        }
        .animation(nil)
    }
}

extension BiometricView {
    private func bioAuth() {
        Lock.shared.bioAuth { fallbackToPasscode in
            // authentication has now completed
            if !fallbackToPasscode {
                // authenticated successfully
                onAuthenticatedSuccess(isPasscode: fallbackToPasscode)
            }
        }
    }

    private func enableBioAuth() {
        if !skipBioAuth,
           lockMethod == ASSettings.LockMethod.passcodeBiometric.rawValue {
            bioAuth()
        }
    }

    private func onAuthenticatedSuccess(isPasscode: Bool) {
        authenticatedSuccess = true
        textField?.resignFirstResponder()
        DispatchQueue.main.asyncAfter(deadline: .now() + (isPasscode ? 0 : 0.7)) {
            withAnimation {
                isPlayingSplash = isShowSplash
                animateSplash = isPlayingSplash
                if isShowSplash {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.6) {
                        withAnimation {
                            animateSplash = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            if !alreadyDismiss {
                                dismiss()
                                callback(true)
                            }
                        }
                    }
                } else {
                    dismiss()
                    callback(true)
                }
            }
        }
    }
}
