//
//  ChoosePasscodeView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/10/21.
//

import SwiftUI
import Combine
import LocalAuthentication

struct ChoosePasscodeView {
    @StateObject private var viewModel = ViewModel()
    @State private var attempts = 1.0
    @State private var passCode = ""
    @State private var cachePassCode = ""
    @State private var dismissCancellable: AnyCancellable?
    @State private var errorColorDisplay = false
    @AppStorage(ASSettings.General.appSetupState.key)
    private var appSetupState = ASSettings.General.appSetupState.defaultValue
    @AppStorage(ASSettings.Settings.lockMethod.key)
    private var lockMethod = ASSettings.Settings.lockMethod.defaultValue
    private let generator = UINotificationFeedbackGenerator()
    var shouldTriggerICloudBackup = false
}

extension ChoosePasscodeView: View {
    var body: some View {
        ZStack {
            Color.sheetBG
            passCodeView
        }
        .ignoresSafeArea()
    }
}

extension ChoosePasscodeView {
    private var passCodeView: some View {
        VStack(spacing: 26.5) {
            ZStack {
                Text("Choose a passcode to\nprotect your wallet")
                    .tracking(0.4)
                    .lineSpacing(5)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .opacity(cachePassCode.isEmpty ? 1 : 0)
                Text("Re-enter the same passcode")
                    .tracking(0.4)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.9))
                    .opacity(cachePassCode.isEmpty ? 0 : 1)
            }
            ZStack {
                ZStack(alignment: .top) {
                    HStack(spacing: 26) {
                        ForEach(0 ..< 6) { index in
                            self.passCodeCircleView(at: index)
                        }
                    }
                    .padding(.bottom, UIScreen.main.bounds.height * 0.32)
                    .modifier(ShakeAnimation(animatableData: CGFloat(attempts)))
                    Text("Update via SETTING > APP SECURITY")
                        .font(.system(size: 12))
                        .foregroundColor(Color.updateViaSettingText)
                        .padding(.top, 49)
                        .opacity(cachePassCode.isEmpty ? 1 : 0)
                }
                TextField("", text: $passCode)
                    .keyboardType(.numberPad)
                    .opacity(0)
                    .introspectTextField { textField in
                        textField.becomeFirstResponder()
                        textField.keyboardAppearance = .dark
                    }
                    .onChange(of: passCode) { newCode in
                        guard newCode.count <= 6 else {
                            return
                        }
                        Utils.playHapticEvent()
                        if newCode.count == 6 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                if cachePassCode.isEmpty {
                                    cachePassCode = newCode
                                    passCode = ""
                                } else if cachePassCode == newCode {
                                    if errSecSuccess == Lock.shared.setPasscode(passCode) {
                                        bioAuth()
                                    }
                                } else {
                                    //error
                                    generator.notificationOccurred(.error)
                                    errorColorDisplay = true
                                    withAnimation(.default) {
                                        self.attempts += 1
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        errorColorDisplay = false
                                        cachePassCode = ""
                                        passCode = ""
                                    }
                                }
                            }
                        } else {
                            Utils.playHapticEvent()
                        }
                    }
            }
        }
        .offset(y: -8)
    }
    private func passCodeCircleView(at index: Int) -> some View {
        ZStack {
            if index < passCode.count {
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

extension ChoosePasscodeView {
    private func bioAuth() {
        Lock.shared.firstTimeRequestLock = false
        lockMethod = ASSettings.LockMethod.passcodeBiometric.rawValue
        dismissCancellable = dismiss()?.sink(receiveValue: { _ in
            if shouldTriggerICloudBackup {
                appSetupState = ASSettings.AppSetupState.backup.rawValue
                present(BackupICloudPasswordView())
            }
        })
    }
}
