//
//  ConnectSiteModal.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 2/11/22.
//

import SwiftUI

struct ConnectSiteModal {
    @ObservedObject private var viewModel = ProfilePictureNFTsModal.ViewModel.shared
    @AppStorage(ASSettings.ProfilePicture.connected.key)
    private var connectWallet = ASSettings.ProfilePicture.connected.defaultValue
}

extension ConnectSiteModal: View {
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Image("timelessIcon")
                    .padding(.bottom, 15)
                VStack(spacing: 7) {
                    HStack(spacing: 5) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.white87)
                        Text("1wallet.crazy.one")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.white87)
                    }
                    HStack(spacing: 5) {
                        Text("·")
                            .foregroundColor(Color(hexString: "3CC29E"))
                            .font(.system(size: 20, weight: .regular))
                        Text("Harmony")
                            .foregroundColor(Color.white60)
                            .font(.system(size: 12, weight: .regular))
                    }
                }
                .padding(.bottom, 24)
                Text("Connect to this site?")
                    .foregroundColor(Color.white87)
                    .font(.system(size: 18, weight: .bold))
                    .padding(.bottom, 14)
                Text("By clicking connect, you allow this dapp to view your public address. This is an important security step to protect your data from potential phishing risks.")
                    .foregroundColor(Color.white60)
                    .font(.system(size: 14, weight: .regular))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 42)
                    .padding(.bottom, 30)
                HStack {
                    WalletAvatar(wallet: WalletInfo.shared.currentWallet, frame: CGSize(width: 43, height: 43))
                    VStack(alignment: .leading, spacing: 3) {
                        WalletAddressView(address: WalletInfo.shared.currentWallet.address, trimCount: 10)
                            .font(.system(size: 15))
                            .foregroundColor(Color.white87)
                            .lineLimit(1)
                        // swiftlint:disable line_length
                        Text("Balance: $\(Utils.formatCurrency(WalletInfo.shared.currentWallet.detailViewModel.overviewModel.totalUSDAmount)) (\(Utils.formatBalance(WalletInfo.shared.currentWallet.detailViewModel.overviewModel.totalONEAmount)) ONE)")
                            .font(.system(size: 12))
                            .foregroundColor(Color.white60)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.keyboardAccessoryBG)
                .cornerRadius(10)
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
                HStack(spacing: 0) {
                    Button {
                        hideConfirmationSheet()
                    } label: {
                        Text("Cancel")
                            .foregroundColor(Color.white)
                            .font(.system(size: 17, weight: .regular))
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.4, maxHeight: 41)
                            .background(Color.reviewButtonBackground)
                            .cornerRadius(20.5)
                    }
                    Spacer()
                    Button {
                        hideConfirmationSheet()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            Lock.shared.requireAuthetication { bool in
                                if bool {
                                    withAnimation {
                                        connectWallet = true
                                    }
                                }
                            }
                        }
                    } label: {
                        Text("Connect")
                            .foregroundColor(Color.white)
                            .font(.system(size: 17, weight: .regular))
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.4, maxHeight: 41)
                            .background(Color.timelessBlue)
                            .cornerRadius(20.5)
                    }
                }
                .padding(.horizontal, 32)
            }
            .padding(.top, 24)
        }
        .frame(height: 465, alignment: .top)
    }
}
