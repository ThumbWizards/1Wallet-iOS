//
//  BackupICloudView.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 08/11/2021.
//

import SwiftUI

struct BackupICloudView: View {
    // MARK: - Properties
    @AppStorage(ASSettings.Backup.currentBackupFilePath.key)
    var currentBackupFilePath = ASSettings.Backup.currentBackupFilePath.defaultValue

    @UserDefault(
        key: ASSettings.Backup.ubiquityIdentityToken.key,
        defaultValue: ASSettings.Backup.ubiquityIdentityToken.defaultValue
    )
    var ubiquityIdentityToken: Any

    @ObservedObject private var viewModel = ViewModel.shared
    @State private var renderUI = false
}

// MARK: - Body view
extension BackupICloudView {
    var body: some View {
        ScrollView(showsIndicators: false) {
            ZStack {
                if currentBackupFilePath.isEmpty {
                    noBackupView
                } else {
                    backupCompleteView
                }
            }
            .minHeight(UIScreen.main.bounds.height)
        }
        .onAppear(perform: {
            guard let token = FileManager.default.ubiquityIdentityToken else { return }
            if !((ubiquityIdentityToken as? NSObject)?.isEqual(token) ?? false) {
                Backup.shared.resetBackupState()
            }
        })
        .background(Color.black)
        .ignoresSafeArea()
        .hideNavigationBar()
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            renderUI.toggle()
        }
    }
}

extension BackupICloudView {
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

    private var noBackupView: some View {
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
            Text("Not backup up")
                .tracking(-0.3)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(!currentBackupFilePath.isEmpty ? Color.textBackupGoogle : Color.textNonBackupGoogle)
                .opacity(0.8)
                .padding(.top, -1)
                .padding(.bottom, 12)
            VStack(spacing: 0) {
                Text("Back up to iCloud")
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
                    .padding(.bottom, UIView.hasNotch ? 95 : UIScreen.main.bounds.height / (667 / 50))
                if renderUI {
                    loadingVIew
                } else {
                    loadingVIew
                }
                Button(action: { onTapBackup() }) {
                    ZStack {
                        Color.timelessBlue
                        HStack(spacing: 7) {
                            Image.lockiCloudFill
                                .resizable()
                                .foregroundColor(Color.white)
                                .font(.system(size: 17, weight: .semibold))
                                .frame(width: 20, height: 15)
                                .offset(x: 2)
                            Text("Backup to iCloud")
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
            // Do not allow restore if user has not backed up yet
            Button(action: { Backup.shared.showBackupFileListView() }) {
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
            .disabled(currentBackupFilePath.isEmpty)
            .opacity(currentBackupFilePath.isEmpty ? 0.3 : 1.0)
        }
    }

    private var loadingVIew: some View {
        LottieView(name: "circle-loading", loopMode: .constant(.loop), isAnimating: .constant(true))
            .scaledToFill()
            .frame(width: 150, height: 131)
            .padding(.bottom, UIView.hasNotch ? 134.75 : UIScreen.main.bounds.height / (667 / 119))
    }

    private var backupCompleteView: some View {
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
            Text(!currentBackupFilePath.isEmpty ? "Back up completed" : "Not backup up")
                .tracking(-0.3)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(!currentBackupFilePath.isEmpty ? Color.textBackupGoogle : Color.textNonBackupGoogle)
                .opacity(0.8)
                .padding(.top, -1)
                .padding(.bottom, 12)
            VStack(spacing: 0) {
                Text("Back up complete")
                    .tracking(-0.45)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(Color.white)
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 14)
                    .padding(.top, UIView.hasNotch ? 42 : UIScreen.main.bounds.height / (667 / 15))
                    .padding(.bottom, 15)
                // swiftlint:disable line_length
                Text("Your wallet is backed up\n\nIf you lose this device, you can recover your encrypted wallet backup from iCloud.")
                    .tracking(-0.2)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(Color.contactNamePreview)
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 34)
                    .padding(.bottom, UIView.hasNotch ? 65 : UIScreen.main.bounds.height / (667 / 40))
                Image.backUpLock
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding(.bottom, UIView.hasNotch ? 152 : UIScreen.main.bounds.height / (667 / 118))
                Button(action: { onTapBackup() }) {
                    ZStack {
                        Color.backupiCloudBtnManage
                        HStack(spacing: 7) {
                            Text("Manage iCloud Backups")
                                .foregroundColor(Color.textManageiCloud)
                                .font(.system(size: 17, weight: .regular))
                        }
                    }
                }
                .frame(height: 41)
                .cornerRadius(.infinity)
                .padding(.horizontal, 16)
                .padding(.bottom, UIView.hasNotch ? 41 : UIScreen.main.bounds.height / (667 / 20))
            }
            .background(Color.searchBackground)
            .cornerRadius(12)
            .padding(.horizontal, 25)
            Color.clear
                .frame(height: 75)

        }
    }
}

// MARK: - Methods
extension BackupICloudView {
    private func onTapClose() { dismiss() }
    private func onTapBackup() {
        guard currentBackupFilePath.isEmpty else {
            showConfirmation(.manageBackups)
            return
        }
        present(BackupICloudPasswordView())
    }
}
