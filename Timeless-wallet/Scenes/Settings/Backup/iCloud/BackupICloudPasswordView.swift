//
//  BackupICloudPasswordView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 05/11/2021.
//

import SwiftUI
import Combine
import Navajo_Swift

struct BackupICloudPasswordView: View {
    // MARK: - Properties
    @State private var viewModel = BackupICloudView.ViewModel.shared
    @State private var backupPasswordStr = ""
    @State private var confirmPasswordStr = ""
    @State private var showPasswordMismatch = false
    @State private var passwordStrengthStr = "Minimum 8 characters"
    @State private var cancelable = Set<AnyCancellable>()
    @State private var textFieldBackup: UITextField?
    @State private var textFieldConfirm: UITextField?
    @State private var secureFieldBackup: UITextField?
    @State private var secureFieldConfirm: UITextField?
    @State private var renderUI = false
    @State private var showBackupPass = false
    @State private var showConfirmPass = false

    let minimumPassLenght = 8

    private var isValidBackupPassword: Bool {
        backupPasswordStr.count >= minimumPassLenght
    }

    private var isValidConfirmPassword: Bool {
        confirmPasswordStr.count >= minimumPassLenght && confirmPasswordStr.count >= backupPasswordStr.count
    }

    private var isValidPassword: Bool {
        backupPasswordStr.count >= minimumPassLenght && backupPasswordStr == confirmPasswordStr
    }

    enum PasswordField {
        case backup
        case confirm
    }

    private let generator = UINotificationFeedbackGenerator()
}

// MARK: - Body view
extension BackupICloudPasswordView {
    var body: some View {
        ZStack(alignment: .top) {
            Color.sheetBG
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Button(action: { onTapClose() }) {
                            Image.closeBackup
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 30)
                        }
                        .padding(.leading, 18.5)
                        .offset(y: -1)
                        Spacer()
                    }
                    VStack(spacing: 3.5) {
                        Text("Choose a password")
                            .tracking(0)
                            .foregroundColor(Color.white87)
                            .font(.system(size: 18, weight: .semibold))
                        Text("To encrypt the backup")
                            .tracking(-0.2)
                            .foregroundColor(Color.subtitleSheet)
                            .font(.system(size: 14, weight: .medium))
                    }
                }
                .padding(.top, 26.5)
                VStack(spacing: 0) {
                    Spacer()
                        .maxHeight(46)
                    Text("Back up to iCloud")
                        .font(.system(size: 28, weight: .bold))
                        .tracking(-0.4)
                        .foregroundColor(Color.white)
                        .padding(.bottom, 14)
                    // swiftlint:disable line_length
                    Text("Passphrase ensures only you can restore your wallet should you lose your device. If you forget the passphrase, you will NOT be able to restore your saved wallets.")
                        .tracking(-0.2)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.contactNamePreview)
                        .padding(.horizontal, 30)
                    Spacer()
                        .maxHeight(48)
                    textFieldPassword(.backup)
                    textFieldPassword(.confirm)
                    ctaButtonView
                        .padding(.horizontal, 44)
                        .padding(.bottom, 16)
                    Text("Must be at least 8 characters alphanumeric passphrase.")
                        .tracking(-0.7)
                        .foregroundColor(Color.updateViaSettingText)
                        .font(.system(size: 12))
                        .offset(y: -8)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            renderUI.toggle()
        }
        .onTapGesture { onTapOut() }
        .onChange(of: backupPasswordStr, perform: { backupPasswordStr in
            guard isValidBackupPassword else {
                showPasswordMismatch = false
                passwordStrengthStr = "Minimum 8 characters"
                return
            }
            guard !confirmPasswordStr.isEmpty else {
                switch Navajo.strength(ofPassword: backupPasswordStr) {
                case .veryWeak: passwordStrengthStr = "🤦 bad"
                case .weak: passwordStrengthStr = "😓 weak"
                case .reasonable: passwordStrengthStr = "🤔 moderate"
                case .strong: passwordStrengthStr = "👍 good"
                case .veryStrong: passwordStrengthStr = "💪 strong"
                }
                return
            }
            showPasswordMismatch = backupPasswordStr != confirmPasswordStr
        })
        .onChange(of: confirmPasswordStr) { confirmPasswordStr in
            showPasswordMismatch = isValidConfirmPassword && backupPasswordStr != confirmPasswordStr
        }
    }
}

// MARK: - Subview
extension BackupICloudPasswordView {
    private func textFieldPassword(_ field: PasswordField) -> some View {
        RoundedRectangle(cornerRadius: .infinity)
            .foregroundColor(.clear)
            .frame(height: 44)
            .overlay(
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: .infinity)
                        .stroke(Color.strokeBackupiCloud, lineWidth: 1)
                    Text(field == .backup ? "Backup password" : "Confirm password")
                        .tracking(0.5)
                        .font(.system(size: 16))
                        .foregroundColor(Color.backupPassText)
                        .padding(.leading, 16)
                        .opacity((field == .backup ? backupPasswordStr : confirmPasswordStr).isEmpty ? 1 : 0)
                    HStack(spacing: 0) {
                        ZStack(alignment: .leading) {
                            SecureField("", text: field == .backup ? $backupPasswordStr : $confirmPasswordStr)
                                .font(.system(size: 16))
                                .foregroundColor(Color.white)
                                .accentColor(Color.timelessBlue)
                                .opacity(field == .backup ? (showBackupPass ? 0 : 1) : (showConfirmPass ? 0 : 1))
                                .onTapGesture {
                                    // AVOID KEYBOARD CLOSE
                                }
                                .introspectTextField { textField in
                                    if field == .backup, self.secureFieldBackup == nil {
                                        self.secureFieldBackup  = textField
                                    } else if field == .confirm, self.secureFieldConfirm == nil {
                                        self.secureFieldConfirm = textField
                                    }
                                }
                            TextField("", text: field == .backup ? $backupPasswordStr : $confirmPasswordStr)
                                .font(.system(size: 16))
                                .foregroundColor(Color.white)
                                .disableAutocorrection(true)
                                .keyboardType(.alphabet)
                                .accentColor(Color.timelessBlue)
                                .opacity(field == .backup ? (showBackupPass ? 1 : 0) : (showConfirmPass ? 1 : 0))
                                .onTapGesture {
                                    // AVOID KEYBOARD CLOSE
                                }
                                .introspectTextField { textField in
                                    if field == .backup, self.textFieldBackup == nil {
                                        self.textFieldBackup = textField
                                    } else if field == .confirm, self.textFieldConfirm == nil {
                                        self.textFieldConfirm = textField
                                    }
                                }
                        }
                        .frame(height: 44)
                        Button(action: {
                            generator.notificationOccurred(.success)
                            if field == .backup {
                                showBackupPass.toggle()
                            } else {
                                showConfirmPass.toggle()
                            }
                        }) {
                            ZStack {
                                Color.almostClear
                                    .frame(width: 40, height: 40)
                                Image.eye
                                    .resizable()
                                    .foregroundColor(Color.white.opacity(0.8))
                                    .frame(width: 21, height: 14)
                                    .opacity(field == .backup ? (showBackupPass ? 0 : 1) : (showConfirmPass ? 0 : 1))
                                Image.eyeSlash
                                    .resizable()
                                    .foregroundColor(Color.white.opacity(0.8))
                                    .frame(width: 21, height: 16)
                                    .opacity(field == .backup ? (showBackupPass ? 1 : 0) : (showConfirmPass ? 1 : 0))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            )
            .background(
                Color.almostClear
                    .padding(.horizontal, -6)
                    .padding(.vertical, -5)
                    .onTapGesture {
                        if field == .backup {
                            if showBackupPass {
                                textFieldBackup?.becomeFirstResponder()
                            } else {
                                secureFieldBackup?.becomeFirstResponder()
                            }
                        } else {
                            if showConfirmPass {
                                textFieldConfirm?.becomeFirstResponder()
                            } else {
                                secureFieldConfirm?.becomeFirstResponder()
                            }
                        }
                    }
            )
            .padding(.horizontal, 44)
            .padding(.bottom, field == .backup ? 11 : 30)
    }

    private var ctaButtonView: some View {
        Button(action: { onTapConfirm() }) {
            RoundedRectangle(cornerRadius: .infinity)
                .frame(height: 41)
                .foregroundColor(isValidPassword ? Color.timelessBlue : Color.textfieldEmailBG)
                .overlay(
                    ZStack {
                        if isValidPassword {
                            HStack(spacing: 9) {
                                if LocalAuthManager.shared.biometricType == .touchID {
                                    Image.touchid
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fit)
                                        .frame(width: 17)
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(Color.white)
                                } else {
                                    Image.faceId
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fit)
                                        .frame(width: 17)
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(Color.white)
                                }
                                Text("Confirm Backup")
                                    .tracking(0)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(Color.white)
                            }
                        } else {
                            Text(showPasswordMismatch ? "Password Mismatch" : passwordStrengthStr)
                                .tracking(0)
                                .font(.system(size: 17))
                                .foregroundColor(Color.textfieldEmailText)
                        }
                        if showPasswordMismatch {
                            HStack {
                                if renderUI {
                                    errorView
                                } else {
                                    errorView
                                }
                                Spacer()
                            }
                        }
                    }
                )
        }
        .disabled(!isValidPassword)
    }

    private var errorView: some View {
        LottieView(name: "lottieError", loopMode: .constant(.loop), isAnimating: .constant(true))
            .scaledToFill()
            .frame(width: 45, height: 45)
            .offset(y: 2.5)
            .padding(.leading, 19)
    }
}

// MARK: - Methods
extension BackupICloudPasswordView {
    private func onTapOut() {
        UIApplication.shared.endEditing()
    }
    private func onTapClose() { dismiss() }
    private func onTapConfirm() {
        viewModel.newBackup(backupPassword: backupPasswordStr)
    }
}
