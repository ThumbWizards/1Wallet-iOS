//
//  RestoreICloudBackupView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 06/11/2021.
//

import SwiftUI
import FilesProvider

struct RestoreICloudBackupView: View {
    var file: FileObject
    // MARK: - Properties
    @ObservedObject private var viewModel = BackupICloudView.ViewModel.shared
    @State private var backupPasswordStr = ""
    @State private var textField: UITextField?
    @State private var secureField: UITextField?
    @State private var renderUI = false
    @State private var showPass = false
    let minimumPassLenght = 8
    private var isValidPassword: Bool {
        !backupPasswordStr.isEmpty && backupPasswordStr.count >= minimumPassLenght
    }
    private let generator = UINotificationFeedbackGenerator()
}

// MARK: - Body view
extension RestoreICloudBackupView {
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
                        Spacer()
                    }
                    Text("Restore from iCloud")
                        .tracking(-0.1)
                        .foregroundColor(Color.white87)
                        .font(.system(size: 18, weight: .semibold))
                        .offset(y: 2)
                }
                .padding(.top, 30.5)
                VStack(spacing: 0) {
                    Spacer()
                        .maxHeight(55)
                    Text("Enter passphrase")
                        .font(.system(size: 28, weight: .bold))
                        .tracking(-0.4)
                        .foregroundColor(Color.white)
                        .padding(.bottom, 13)
                    // swiftlint:disable line_length
                    Text("To restore your wallet, enter the passphrase you had entered during backup to encrypt your wallet stored in the iCloud.")
                        .tracking(-0.2)
                        .lineSpacing(5)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.contactNamePreview)
                        .padding(.horizontal, 40)
                    Spacer()
                        .maxHeight(60)
                    if renderUI {
                        loadingView
                    } else {
                        loadingView
                    }
                    Spacer()
                        .maxHeight(71)
                    textFieldPassword()
                    Spacer()
                        .maxHeight(27)
                    Button(action: { onTapRestore() }) {
                        RoundedRectangle(cornerRadius: .infinity)
                            .frame(height: 41)
                            .foregroundColor(isValidPassword ? Color.timelessBlue : Color.textfieldEmailBG)
                            .overlay(
                                HStack(spacing: 5) {
                                    Image.arrowClockwiseiCloud
                                        .resizable()
                                        .frame(width: 20, height: 15)
                                        .foregroundColor(isValidPassword ? Color.white : Color.textfieldEmailText)
                                        .font(.system(size: 17))
                                    Text("Restore from iCloud")
                                        .font(.system(size: 17))
                                        .foregroundColor(isValidPassword ? Color.white : Color.textfieldEmailText)
                                }
                            )
                    }
                    .padding(.horizontal, 44)
                    .padding(.bottom, 16)
                    .disabled(!isValidPassword)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            renderUI.toggle()
        }
        .onTapGesture { onTapOut() }
        .loadingOverlay(isShowing: viewModel.isLoading)
    }
}

// MARK: - Subview
extension RestoreICloudBackupView {
    private var loadingView: some View {
        LottieView(name: "circle-loading", loopMode: .constant(.loop), isAnimating: .constant(true))
            .scaledToFill()
            .frame(width: 150, height: 131)
    }

    // swiftlint:disable function_body_length
    private func textFieldPassword() -> some View {
        RoundedRectangle(cornerRadius: .infinity)
            .foregroundColor(.clear)
            .frame(height: 44)
            .overlay(
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: .infinity)
                        .stroke(Color.strokeBackupiCloud, lineWidth: 1)
                    Text("Backup password")
                        .tracking(0.5)
                        .font(.system(size: 16))
                        .foregroundColor(Color.backupPassText)
                        .padding(.leading, 16)
                        .opacity(backupPasswordStr.isBlank ? 1 : 0)
                    HStack(spacing: 0) {
                        ZStack(alignment: .leading) {
                            SecureField("", text: $backupPasswordStr)
                                .font(.system(size: 16))
                                .foregroundColor(Color.white)
                                .accentColor(Color.timelessBlue)
                                .disableAutocorrection(true)
                                .keyboardType(.alphabet)
                                .opacity(showPass ? 0 : 1)
                                .onTapGesture {
                                    // AVOID KEYBOARD CLOSE
                                }
                                .introspectTextField { textField in
                                    if secureField == nil {
                                        secureField = textField
                                    }
                                }
                            TextField("", text: $backupPasswordStr)
                                .font(.system(size: 16))
                                .foregroundColor(Color.white)
                                .disableAutocorrection(true)
                                .keyboardType(.alphabet)
                                .accentColor(Color.timelessBlue)
                                .opacity(showPass ? 1 : 0)
                                .onTapGesture {
                                    // AVOID KEYBOARD CLOSE
                                }
                                .introspectTextField { textField in
                                    if self.textField == nil {
                                        self.textField = textField
                                    }
                                }
                        }
                        Button(action: {
                            generator.notificationOccurred(.success)
                            showPass.toggle()
                        }) {
                            ZStack {
                                Color.almostClear
                                    .frame(width: 40, height: 40)
                                Image.eye
                                    .resizable()
                                    .foregroundColor(Color.white.opacity(0.8))
                                    .frame(width: 21, height: 14)
                                    .opacity(showPass ? 0 : 1)
                                Image.eyeSlash
                                    .resizable()
                                    .foregroundColor(Color.white.opacity(0.8))
                                    .frame(width: 21, height: 16)
                                    .opacity(showPass ? 1 : 0)
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
                        if showPass {
                            textField?.becomeFirstResponder()
                        } else {
                            secureField?.becomeFirstResponder()
                        }
                    }
            )
            .padding(.horizontal, 44)
    }
}

// MARK: - Methods
extension RestoreICloudBackupView {
    private func onTapOut() { UIApplication.shared.endEditing() }
    private func onTapClose() { dismiss() }
    private func onTapRestore() {
        UIApplication.shared.endEditing()
        viewModel.restoreBackup(file: file, backupPassword: backupPasswordStr, incorrectPass: {
            backupPasswordStr.removeAll()
        })
    }
}
