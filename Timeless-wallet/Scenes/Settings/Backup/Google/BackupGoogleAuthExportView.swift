//
//  BackupGoogleAuthExportView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 05/11/2021.
//

import SwiftUI

struct BackupGoogleAuthExportView: View {
    // MARK: - Properties
    @SwiftUI.Environment(\.presentationMode) private var presentationMode
    @State private var qrCodeCGImage: CGImage?
    @State private var isShowing = false
    @State private var screenBrightness: CGFloat = 1
    var onExport: () -> Void
}

// MARK: - Body view
extension BackupGoogleAuthExportView {
    var body: some View {
        ZStack(alignment: .top) {
            Color.sheetBG
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Button(action: { onTapClose() }) {
                            Image.closeBackup
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                        .padding(.leading, 18.5)
                        Spacer()
                    }
                    Text("Export Seed")
                        .tracking(-0.3)
                        .foregroundColor(Color.white87)
                        .font(.system(size: 18, weight: .semibold))
                        .offset(y: 2)
                }
                .padding(.top, 30.5)
                .padding(.bottom, 68.5)
                Text("Google Authenticator")
                    .font(.system(size: 22))
                    .foregroundColor(Color.white)
                    .padding(.bottom, 14)
                Text("Exported data is encrypted with a client generated key")
                    .tracking(-0.1)
                    .lineSpacing(3)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 14))
                    .foregroundColor(Color.white60)
                    .padding(.horizontal, 49)
                qrCodeView
                    .padding(.top, UIView.hasNotch ? 39 : 10)
                    .padding(.bottom, UIView.hasNotch ? 50 : 10)
                Text(Wallet.currentWallet?.googleAuthDeepLink ?? "")
                    .font(.system(size: 11))
                    .foregroundColor(Color.white40)
                    .multilineTextAlignment(.center)
                    .padding(11)
                    .background(Color.myQRShareBtn)
                    .cornerRadius(10)
                    .padding(.horizontal, 41.5)
                    .padding(.bottom, 30)
                Button(action: { onTapExport() }) {
                    RoundedRectangle(cornerRadius: .infinity)
                        .frame(height: 41)
                        .foregroundColor(Color.timelessBlue)
                        .overlay(
                            Text("Export")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color.white)
                        )
                }
                .padding(.horizontal, 41.5)
                .padding(.bottom, UIView.hasNotch ? 0 : 24)
            }
        }
        .ignoresSafeArea()
        .onReceive(NotificationCenter.default.publisher(for: UIScreen.brightnessDidChangeNotification)) { _ in
            screenBrightness = UIScreen.main.brightness
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            UIScreen.main.brightness = 1
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            screenBrightness = UIScreen.main.brightness
            UIScreen.main.brightness = 1
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            setDefaultBrightness()
        }
        .onAppear {
            screenBrightness = UIScreen.main.brightness
            UIScreen.main.brightness = 1
            if qrCodeCGImage == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        qrCodeCGImage = QRCodeHelper
                            .generateQRCodeCFImage(from: Wallet.currentWallet?.googleAuthDeepLink ?? "")
                    }
                }
            }
        }
        .onDisappear {
            setDefaultBrightness()
        }
    }
}

extension BackupGoogleAuthExportView {
    private var qrCodeView: some View {
        ZStack {
            Circle()
                .foregroundColor(Color.textfieldEmailBG)
                .frame(width: 221, height: 221)
            ZStack {
                if let qrCodeCGImage = qrCodeCGImage {
                    Image(cgImage: qrCodeCGImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .padding(4)
                }
            }
            .frame(width: 140, height: 140)
            .background(qrCodeCGImage == nil ? Color.primaryBackground.opacity(0.3) : Color.white)
            .cornerRadius(10)
            .loadingOverlay(isShowing: qrCodeCGImage == nil)
        }
    }
}

// MARK: - Methods
extension BackupGoogleAuthExportView {
    private func setDefaultBrightness() {
        UIScreen.main.brightness = screenBrightness
    }
    private func onTapClose() {
        presentationMode.wrappedValue.dismiss()
    }
    private func onTapExport() {
        if let url = URL(string: Wallet.currentWallet?.googleAuthDeepLink ?? ""),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            onExport()
            onTapClose()
        } else {
            showConfirmation(.installGoogleAuthenticator)
        }
    }
}
