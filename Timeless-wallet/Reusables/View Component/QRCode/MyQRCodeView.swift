//
//  MyQRCodeView.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 25/11/2021.
//

import SwiftUI
import SwiftUIX

struct MyQRCodeView: View {
    var wallet: Wallet
    @State private var qrCodeCGImage: CGImage?
    @State private var isShowing = false
}

// MARK: - Body view
extension MyQRCodeView {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                headerView
                VStack(spacing: 0) {
                    Text("My QR Code")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(Color.white)
                        .padding(.top, 34)
                        .padding(.bottom, 65)
                    qrCodeView
                        .onTapGesture {
                            onCopyAddress()
                        }
                    Text(IdentityService.shared.user?.nameFullAlias ?? "")
                        .tracking(0.5)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.white)
                        .opacity(0.8)
                        .padding(.top, 13)
                    Text(wallet.address.convertEthereumToBech32().trimStringByCount(count: 10))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color.white)
                        .opacity(0.8)
                        .padding(.top, 8)
                        .padding(.bottom, 90)
                        .onTapGesture {
                            onCopyAddress()
                        }
                    Button(action: {
                        let view = UIHostingController(rootView: SharedQRImageView(qrCodeCGImage: qrCodeCGImage!,
                                                                                   wallet: wallet)).view
                        UIApplication.shared.keyWindowInConnectedScenes?.addSubview(view!)
                        view?.frame = CGRect(origin: CGPoint(x: 0, y: 200), size: CGSize(width: 210, height: 250))
                        UIApplication.shared.keyWindowInConnectedScenes?.layoutSubviews()
                        view?.backgroundColor = .clear
                        let uiimage = view?.asImage(rect: CGRect(origin: .zero, size: CGSize(width: 210, height: 250)))
                        view?.removeFromSuperview()
                        let activityViewController = UIActivityViewController(activityItems: [uiimage,
                                                                                              wallet.address.convertEthereumToBech32()],
                                                                                              applicationActivities: nil)
                        present(activityViewController)
                    }) {
                        ZStack {
                            Color.myQRShareBtn
                            HStack(spacing: 9) {
                                Image("share_image_icon")
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
                    .disabled(qrCodeCGImage == nil)
                    .opacity(qrCodeCGImage == nil ? 0.3 : 1)
                }
                .width(UIScreen.main.bounds.width - 50)
                .background(Color.searchBackground)
                .cornerRadius(12)
                .padding(.bottom, 8)
                Text("use it to share contact or receive money")
                    .tracking(-0.7)
                    .font(.system(size: 16))
                    .foregroundColor(Color.white)
                    .opacity(0.4)
            }
            .minHeight(UIScreen.main.bounds.height)
            .offset(y: 13)
        }
        .background(Color.black)
        .ignoresSafeArea()
        .hideNavigationBar()
        .onAppear {
            if qrCodeCGImage == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        qrCodeCGImage = QRCodeHelper
                            .generateQRCodeCFImage(from: wallet.address.convertEthereumToBech32())
                    }
                }
            }
        }
    }
}

extension MyQRCodeView {
    private var headerView: some View {
        ZStack {
            HStack {
                Button(action: { onTapClose() }) {
                    Image("closeBackup")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 30)
                }
                .padding(.leading, 24)
                .offset(y: 2)
                Spacer()
            }
        }
        .padding(.bottom, 12)
    }

    private var qrCodeView: some View {
        ZStack {
            Circle()
                .foregroundColor(Color.textfieldEmailBG)
                .frame(width: 182, height: 182)
            ZStack {
                if let qrCodeCGImage = qrCodeCGImage {
                    Image(cgImage: qrCodeCGImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .padding(4)
                }
            }
            .frame(width: 110, height: 110)
            .background(qrCodeCGImage == nil ? Color.primaryBackground.opacity(0.3) : Color.white)
            .cornerRadius(10)
            .loadingOverlay(isShowing: qrCodeCGImage == nil)
        }
    }
}
// MARK: - Methods
extension MyQRCodeView {
    private func onTapClose() { dismiss() }

    private func onCopyAddress() {
        showSnackBar(.coppiedAddress)
        UIPasteboard.general.string = Wallet.currentWallet?.address.convertEthereumToBech32()
    }
}
