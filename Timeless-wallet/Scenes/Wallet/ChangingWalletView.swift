//
//  ChangingWalletView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 07/03/2022.
//

import SwiftUI

struct ChangingWalletView {
    // MARK: - Inpur Parameters
    var wallet: Wallet

    // MARK: - Properties
    @ObservedObject private var walletInfo = WalletInfo.shared
    @State private var opacityChangedAvatar = false
}

extension ChangingWalletView: View {
    var body: some View {
        ZStack {
            Color.primaryBackground
            VStack(spacing: 31.5) {
                Text(wallet.nameFullAlias)
                    .lineLimit(1)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 10)
                WalletAvatar(wallet: wallet, frame: CGSize(width: 135, height: 135), isCircle: false)
                    .cornerRadius(20)
                    .padding(.bottom, 13.5)
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)
            }
            .offset(y: -2)
            .scaleEffect(opacityChangedAvatar ? 1 : 0.9)
            .opacity(opacityChangedAvatar ? 1 : 0.001)
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.65)) {
                    opacityChangedAvatar = true
                }
            }
        }
        .onChange(of: walletInfo.isShowingAnimation) { value in
            if !value {
                withAnimation(.easeInOut(duration: 0.3)) {
                    opacityChangedAvatar = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    dismiss()
                }
            }
        }
    }
}
