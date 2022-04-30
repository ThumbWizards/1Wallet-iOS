//
//  ImportWalletView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 29/10/2021.
//

import SwiftUI
import AVFoundation
import SwiftMessages

struct ImportWalletView {
    // MARK: - Properties
    @SwiftUI.Environment(\.colorScheme) var colorScheme: ColorScheme
    @StateObject private var viewModel = ViewModel()
    @State private var showQR = false
    @State private var hideCameraLoading = true
    @State private var renderUI = false
    private var strokeColor: String { colorScheme == .light ? "9CBCFB" : "979797" }
    var sizeQRCode: CGFloat = UIScreen.main.bounds.width - 152
    var rect: CGRect { CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 10, height: sizeQRCode) }
}

// MARK: - Body view
extension ImportWalletView: View {
    @ViewBuilder
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .foregroundColor(Color.white60)
                .frame(width: 40, height: 5)
                .cornerRadius(2.5)
                .padding(.top, 9)
                .padding(.bottom, 25)
            Text("Restore Backup")
                .tracking(-0.4)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.white)
                .padding(.bottom, 12)
            Text("Restore from iCloud, Google Authenticator, or simply watch a public address or HNS name.")
                .tracking(-0.1)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white87)
                .lineSpacing(5)
                .multilineTextAlignment(.center)
                .padding(.bottom, 33)
                .padding(.horizontal, 53.5)
            HStack(spacing: 0) {
                Spacer()
                if renderUI {
                    loadingView
                } else {
                    loadingView
                }
                Spacer()
            }
            Spacer(minLength: 36)
            Button {
                Backup.shared.backupFromSettings = false
                viewModel.restoreFromIcloud()
            } label: {
                HStack {
                    Text("iCloud")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color.white60)
                }
                .frame(width: UIScreen.main.bounds.width - 82, height: 42)
                .background(Color.confirmationSheetCancelBG.cornerRadius(.infinity))
            }
            .padding(.bottom, 11)
//            Disable restore from Google Auth for now
//            Button {
//            } label: {
//                HStack {
//                    Text("Google Authenticator")
//                        .font(.system(size: 17, weight: .semibold))
//                        .foregroundColor(Color.white60)
//                }
//                .frame(width: UIScreen.main.bounds.width - 82, height: 42)
//                .background(Color.confirmationSheetCancelBG.cornerRadius(.infinity))
//            }
//            .padding(.bottom, 11)
            Button {
                hideConfirmationSheet()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    present(WatchPublicAddressModal())
                }
            } label: {
                HStack {
                    Text("Watch public address")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color.white60)
                }
                .frame(width: UIScreen.main.bounds.width - 82, height: 42)
                .background(Color.confirmationSheetCancelBG.cornerRadius(.infinity))
            }
            .padding(.bottom, 46)
        }
        .height(541)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            renderUI.toggle()
        }
    }

    private var loadingView: some View {
        LottieView(name: "circle-loading", loopMode: .constant(.loop), isAnimating: .constant(true))
            .scaledToFill()
            .frame(width: 151, height: 131)
    }
}

// MARK: - Methods
extension ImportWalletView {
    private func onScanSuccess(strScanned: String) {
        if let url = URL(string: strScanned), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
