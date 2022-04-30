//
//  WalletQRView.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 31/03/22.
//

import SwiftUI

struct WalletQRView: View {
    @StateObject var viewModel: WalletQRViewModel

    var body: some View {
        ZStack {
            Color.primaryBackground
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 30)
                WalletAvatar(wallet: viewModel.wallet, frame: CGSize(width: 116, height: 116))
                    .padding(.bottom, UIView.hasNotch ? 50 : 30)
                infoView
                    .padding(.bottom, UIView.hasNotch ? 25 : 5)
                qrCodeView(viewModel.wallet)
                    .padding(.bottom, UIView.hasNotch ? 54 : 25)
                Button(action: {
                    onShare(viewModel.wallet)
                }) {
                    ZStack {
                        Color.myQRShareBtn
                        HStack(spacing: 9) {
                            Image.shareImageIcon
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color.white)
                                .font(.system(size: 17, weight: .semibold))
                                .frame(width: 18, height: 19)
                            Text("Share")
                                .foregroundColor(Color.white)
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                }
                .frame(width: 195, height: 49)
                .cornerRadius(10)
                .padding(.bottom, 31)
                .disabled(viewModel.qrCodeCGImage == nil)
                .opacity(viewModel.qrCodeCGImage == nil ? 0.3 : 1)
                Text("use it to share contact or receive money")
                    .tracking(-0.7)
                    .font(.system(size: 16))
                    .foregroundColor(Color.white)
                    .opacity(0.4)
                    .padding(.bottom, 15)
            }
            .width(UIScreen.main.bounds.width - 50)
            .background(Color.searchBackground)
            .cornerRadius(12)
            .padding(.bottom, 8)
            .overlay(
                headerView
                    .offset(y: 12),
                alignment: .topLeading)
        }

        .onReceive(NotificationCenter.default.publisher(for: UIScreen.brightnessDidChangeNotification)) { _ in
            viewModel.screenBrightness = UIScreen.main.brightness
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            UIScreen.main.brightness = 1
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.screenBrightness = UIScreen.main.brightness
            UIScreen.main.brightness = 1
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            viewModel.setDefaultBrightness()
        }
        .onAppear {
            viewModel.generateWalletQRCode()
            viewModel.screenBrightness = UIScreen.main.brightness
            UIScreen.main.brightness = 1
        }
        .onDisappear {
            viewModel.setDefaultBrightness()
        }
    }
}

extension WalletQRView {
    private var infoView: some View {
        VStack(spacing: 0) {
            Text(viewModel.wallet.nameFullAlias)
                .lineLimit(1)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.8))
                .padding(.horizontal, 25)
            Button(action: { viewModel.copyWalletAddress() }) {
                WalletAddressView(address: viewModel.wallet.address, trimCount: 10)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.8))
                    .padding(.horizontal, 25)
                    .padding(.vertical, 8)
                    .background(Color.almostClear)
            }
        }
    }

    private var headerView: some View {
        HStack {
            Button(action: { viewModel.onTapClose() }) {
                Image.closeBackup
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 30)
            }
            .padding(.leading, 24)
            .offset(y: 2)
            Spacer()
        }
        .padding(.bottom, 12)
    }

    private func qrCodeView(_ wallet: Wallet) -> some View {
        ZStack {
            if let qrCodeCGImage = viewModel.qrCodeCGImage {
                Image(cgImage: qrCodeCGImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .padding(4)
            }
        }
        .frame(width: 160, height: 160)
        .background(viewModel.qrCodeCGImage == nil ? Color.primaryBackground.opacity(0.3) : Color.white)
        .cornerRadius(10)
        .onTapGesture { viewModel.copyWalletAddress() }
        .loadingOverlay(isShowing: viewModel.qrCodeCGImage == nil)
    }

    private func onShare(_ wallet: Wallet) {
        guard let qrCodeImage = viewModel.qrCodeCGImage else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let view = UIHostingController(rootView: SharedQRImageView(qrCodeCGImage: qrCodeImage,
                                                                       wallet: wallet)).view
            UIApplication.shared.keyWindowInConnectedScenes?.addSubview(view!)
            view?.frame = CGRect(origin: CGPoint(x: 0, y: 200), size: CGSize(width: 326, height: 447))
            UIApplication.shared.keyWindowInConnectedScenes?.layoutSubviews()
            view?.backgroundColor = .clear
            let uiimage = view?.asImage(rect: CGRect(origin: .zero, size: CGSize(width: 326, height: 447)))
            view?.removeFromSuperview()

            let walletString = "\(wallet.address.convertToWalletAddress())"
            let activityViewController = UIActivityViewController(
                activityItems: [uiimage ?? .init(), MyActivityItemSource(title: "My wallet", text: walletString)],
                applicationActivities: nil
            )
            activityViewController.completionWithItemsHandler = {
                (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                if !completed {
                    // User canceled
                    return
                }
            }
            present(activityViewController)
        }
    }
}
