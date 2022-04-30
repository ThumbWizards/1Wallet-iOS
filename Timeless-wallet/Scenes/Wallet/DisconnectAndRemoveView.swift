//
//  DisconnectAndRemoveView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 26/11/2021.
//

import SwiftUI
import AVFoundation

struct DisconnectAndRemoveView {
    var wallet: Wallet
}

extension DisconnectAndRemoveView {
    private var address: String {
        if let address = Wallet.currentWallet?.address {
            return address
        }
        return ""
    }
}

// MARK: - Body view
extension DisconnectAndRemoveView: View {
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: .infinity)
                .foregroundColor(Color.swipeBar)
                .frame(width: 40, height: 5)
                .padding(.bottom, 31)
            Text("Backup & Remove")
                .tracking(-0.1)
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(Color.white)
                .padding(.bottom, 12)
            Text("Are you sure you want to disconnect this wallet?")
                .tracking(-0.2)
                .lineSpacing(5)
                .foregroundColor(Color.subtitleConfirmationSheet)
                .multilineTextAlignment(.center)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 53.5)
                .padding(.bottom, 38)
            WalletAvatar(wallet: wallet, frame: CGSize(width: 82,
                                     height: 82))
                .padding(.bottom, 17)
            Text(wallet.nameFullAlias)
                .tracking(0.5)
                .lineLimit(1)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color.subtitleConfirmationSheet)
                .padding(.bottom, 9)
                .padding(.horizontal, 41)
            Text(address)
            WalletAddressView(address: address, trimCount: 10)
                .font(.system(size: 12))
                .foregroundColor(Color.subtitleConfirmationSheet)
                .padding(.horizontal, 41)
                .padding(.bottom, 36)
            Button(action: { hideConfirmationSheet() }) {
                RoundedRectangle(cornerRadius: .infinity)
                    .frame(height: 41)
                    .foregroundColor(Color.timelessRed)
                    .overlay(
                        Text("Yes - Backup & Remove")
                            .tracking(0.1)
                            .font(.system(size: 17))
                            .foregroundColor(Color.white)
                    )
            }
            .padding(.horizontal, 41)
            .padding(.bottom, 11)
            Button(action: { onTapCancel() }) {
                RoundedRectangle(cornerRadius: .infinity)
                    .frame(height: 41)
                    .foregroundColor(Color.confirmationSheetCancelBG)
                    .overlay(
                        Text("Cancel")
                            .tracking(0.1)
                            .font(.system(size: 17))
                            .foregroundColor(Color.confirmationSheetCancelBtn)
                    )
            }
            .padding(.horizontal, 41)
            Spacer()
        }
        .padding(.top, 11)
        .height(493)
    }
}

// MARK: - Methods
extension DisconnectAndRemoveView {
    private func onTapBackupAndRemove() {
        hideConfirmationSheet()
    }

    private func onTapCancel() {
        hideConfirmationSheet()
    }
}
