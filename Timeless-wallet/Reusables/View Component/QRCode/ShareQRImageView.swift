//
//  ShareQRImageView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 12/8/21.
//

import SwiftUI

struct SharedQRImageView: View {
    var qrCodeCGImage: CGImage
    var wallet: Wallet
    var body: some View {
        ZStack {
            Color.searchBackground
            VStack(spacing: 0) {
                WalletAvatar(wallet: wallet, frame: CGSize(width: 116, height: 116))
                    .padding(.bottom, 46)
                if let name = Wallet.currentWallet?.nameFullAlias {
                    Text(name)
                        .tracking(0.5)
                        .lineLimit(1)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.white)
                        .opacity(0.8)
                        .padding(.horizontal, 10)
                    WalletAddressView(address: wallet.address, trimCount: 10)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color.white87)
                        .minimumScaleFactor(0.5)
                        .opacity(0.8)
                        .frame(height: 20)
                        .padding(.horizontal, 10)
                } else {
                    WalletAddressView(address: wallet.address, trimCount: 10)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.white)
                        .opacity(0.8)
                        .padding(.horizontal, 10)
                }
                ZStack {
                    Image(cgImage: qrCodeCGImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .padding(4)
                }
                .frame(width: 160, height: 160)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.top, 21)
            }
        }
        .frame(width: 326, height: 447)
    }
}
