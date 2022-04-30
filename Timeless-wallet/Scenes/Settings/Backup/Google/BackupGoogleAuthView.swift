//
//  BackupGoogleAuthView.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 08/11/2021.
//

import SwiftUI

struct BackupGoogleAuthView: View {
    @AppStorage(ASSettings.Setting.backupGoogleAuthenticator.key)
    private var backupGoogleAuthenticator = ASSettings.Setting.backupGoogleAuthenticator.defaultValue
    @State private var hasBackup = false
    @State private var renderUI = false
}

// MARK: - Body view
extension BackupGoogleAuthView {
    var body: some View {
        ScrollView(showsIndicators: false) {
            ZStack {
                VStack(spacing: 0) {
                    ZStack {
                        HStack {
                            Button(action: { onTapClose() }) {
                                Image.closeBackup
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .frame(width: 30)
                            }
                            .padding(.leading, 24)
                            .offset(y: 2)
                            Spacer()
                        }
                        Text("Back up")
                            .tracking(0.5)
                            .foregroundColor(Color.white)
                            .font(.system(size: 18, weight: .bold))
                    }
                    .padding(.top, 37)
                    Text(hasBackup ? "Back up completed" : "Not backup up")
                        .tracking(-0.3)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(hasBackup ? Color.textBackupGoogle : Color.textNonBackupGoogle)
                        .opacity(0.8)
                        .padding(.top, -1)
                        .padding(.bottom, 12)
                    VStack(spacing: 0) {
                        Text("Back up to Google Authenticator")
                            .tracking(-0.45)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color.white)
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 14)
                            .padding(.top, UIView.hasNotch ? 42 : UIScreen.main.bounds.height / (667 / 15))
                            .padding(.bottom, 15)
                        Text("Don’t risk your money! Backup your wallet so you can recover it if you lose this device.")
                            .tracking(-0.2)
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color.contactNamePreview)
                            .font(.system(size: 14, weight: .medium))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 34)
                            .padding(.bottom, UIView.hasNotch ? 57 : UIScreen.main.bounds.height / (667 / 15))
                        if renderUI {
                            loadingView
                        } else {
                            loadingView
                        }

                        // swiftlint:disable line_length
                        Text("WARNING: You must also back up your Google Authenticator to ensure you’re able to recover the wallet when you lose the device.")
                            .tracking(-0.2)
                            .lineSpacing(5)
                            .font(.system(size: 14, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.textBackupGoogleWarning)
                            .padding(.horizontal, 34)
                            .padding(.bottom, 21)
                        Button(action: { onTapBackup() }) {
                            ZStack {
                                Color.timelessBlue
                                HStack(spacing: 7) {
                                    Image.lockShield
                                        .resizable()
                                        .foregroundColor(Color.white)
                                        .font(.system(size: 17, weight: .semibold))
                                        .frame(width: 14, height: 17)
                                    Text("Google Authenticator")
                                        .foregroundColor(Color.white)
                                        .font(.system(size: 17, weight: .semibold))
                                }
                            }
                        }
                        .frame(height: 41)
                        .cornerRadius(10)
                        .padding(.horizontal, 39)
                        .padding(.bottom, UIView.hasNotch ? 41 : UIScreen.main.bounds.height / (667 / 20))
                    }
                    .background(Color.searchBackground)
                    .cornerRadius(12)
                    .padding(.horizontal, 25)
                    Button(action: { onTapRestore() }) {
                        ZStack {
                            Color.searchBackground
                                .frame(height: 51)
                                .cornerRadius(12)
                                .padding(.horizontal, 25)
                            Text("Restore")
                                .foregroundColor(Color.white)
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    .padding(.vertical, 12)
                }
            }
            .minHeight(UIScreen.main.bounds.height)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            renderUI.toggle()
        }
        .onAppear { onAppearHandler() }
        .background(Color.black)
        .ignoresSafeArea()
        .hideNavigationBar()
    }
}

extension BackupGoogleAuthView {
    private var headerView: some View {
        ZStack {
            HStack {
                Button(action: { onTapClose() }) {
                    Image.closeBackup
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 30)
                }
                .padding(.leading, 24)
                .offset(y: 2)
                Spacer()
            }
            Text("Back up")
                .tracking(0.5)
                .foregroundColor(Color.white)
                .font(.system(size: 18, weight: .bold))
        }
    }

    private var loadingView: some View {
        LottieView(name: "circle-loading", loopMode: .constant(.loop), isAnimating: .constant(true))
            .scaledToFill()
            .frame(width: 150, height: 131)
            .padding(.bottom, UIView.hasNotch ? 33 : UIScreen.main.bounds.height / (667 / 15))
    }
}

// MARK: - Methods
extension BackupGoogleAuthView {
    private func onAppearHandler() {
        hasBackup = backupGoogleAuthenticator
    }

    private func onTapClose() {
        dismiss()
    }

    private func onTapBackup() {
        Lock.shared.requireAuthetication { isAuthenticated in
            guard isAuthenticated else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                present(BackupGoogleAuthExportView(onExport: {
                    hasBackup = true
                    backupGoogleAuthenticator = true
                }), presentationStyle: .automatic)
            }
        }
    }

    private func onTapRestore() { }
}
