//
//  ReviewOrderView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/17/21.
//

import SwiftUI
import Combine

struct ReviewOrderView {
    @ObservedObject var swapViewModel: SwapView.ViewModel
    var rateUSD: String
    var rate: String
    @StateObject private var walletInfo = WalletInfo.shared
    @State private var dismissCancellable: AnyCancellable?
}

extension ReviewOrderView: View {
    var body: some View {
        ZStack {
            Color.primaryBackground
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                headerView
                ScrollView {
                    contentView
                }
                .padding(.top, 18)
            }
            .padding(.top, 13)
        }
    }
}

extension ReviewOrderView {
    private var minimumReceived: String {
        return Utils.formatBalance(swapViewModel.gotValue * (1 - SwapTransaction.slippage))
    }

    private var liquidityProviderFee: String {
        // swiftlint:disable line_length
        return "\(Utils.formatBalance(swapViewModel.payValue * swapViewModel.providerFee)) \(swapViewModel.selectedPay?.symbol ?? "")"
    }
}

extension ReviewOrderView {
    private var headerView: some View {
        ZStack {
            HStack {
                Button(action: { pop() }) {
                    Image.chevronLeft
                        .resizable()
                        .frame(width: 11, height: 20)
                        .foregroundColor(Color.timelessBlue)
                }
                .offset(x: -5)
                Spacer()
            }
            .padding(.horizontal, 16)
            Text("Review Order")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color.white)
            HStack {
                Spacer()
                WalletAvatar(wallet: walletInfo.currentWallet, frame: CGSize(width: 30, height: 30))
                    .padding(.trailing, 24)
            }
        }
    }

    private var contentView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 18) {
                VStack(spacing: 0) {
                    HStack {
                        Text("You Pay")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.white60)
                        Spacer()
                    }
                    .padding(.bottom, 17)
                    HStack {
                        if let icon = swapViewModel.selectedPay?.icon,
                           let url = URL(string: icon) {
                            MediaResourceView(for: MediaResource(for: MediaResourceWebImage(url: url,
                                                                                            isAnimated: true,
                                                                                            targetSize: TargetSize(width: 43,
                                                                                                                   height: 43))),
                                                 placeholder: swapViewModel.loadingIconView,
                                                 isPlaying: .constant(true))
                                .scaledToFill()
                                .frame(width: 43, height: 43)
                                .cornerRadius(.infinity)

                        }
                        Text("\(swapViewModel.payText) \(swapViewModel.selectedPay?.symbol ?? "")")
                            .lineLimit(1)
                            .font(.system(size: 22, weight: .regular))
                            .foregroundColor(Color.white60)
                        Spacer()
                        Text(rateUSD)
                            .lineLimit(1)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.white60)
                    }
                }
                .padding(.vertical, 15)
                .padding(.leading, 20)
                .padding(.trailing, 17)
                .background(Color.autoLockBG)
                .cornerRadius(10)
                HStack(spacing: 10) {
                    line
                    Image.arrowTriangleSwap
                        .resizable()
                        .frame(width: 20, height: 18)
                        .foregroundColor(Color.timelessBlue)
                    line
                }
                VStack {
                    HStack {
                        Text("You Get (estimated)")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.white60)
                        Spacer()
                    }
                    HStack {
                        if let icon = swapViewModel.selectedGot?.icon,
                           let url = URL(string: icon) {
                            MediaResourceView(for: MediaResource(for: MediaResourceWebImage(url: url,
                                                                                            isAnimated: true,
                                                                                            targetSize: TargetSize(width: 43,
                                                                                                                   height: 43))),
                                                 placeholder: swapViewModel.loadingIconView,
                                                 isPlaying: .constant(true))
                                .scaledToFill()
                                .frame(width: 43, height: 43)
                                .cornerRadius(.infinity)
                        }
                        VStack(alignment: .leading) {
                            Text("\(swapViewModel.gotText) \(swapViewModel.selectedGot?.symbol ?? "")")
                                .lineLimit(1)
                                .font(.system(size: 22, weight: .regular))
                                .foregroundColor(Color.white60)
                        }
                        Spacer()
                    }
                }
                .padding(.vertical, 16)
                .padding(.leading, 20)
                .padding(.trailing, 17)
                .background(Color.autoLockBG)
                .cornerRadius(10)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 29)

            VStack(spacing: 0) {
                HStack {
                    Text("Transaction Details")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.white60)
                    Spacer()
                }
                .padding(.bottom, 14)
                VStack(spacing: 13) {
                    HStack {
                        Text("Rate")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.white60.opacity(0.6))
                        Spacer()
                        Text(rate)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.white60)
                    }
                    HStack {
                        Text("Minimum received")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.white60.opacity(0.6))
                        Spacer()
                        Text("\(minimumReceived) \(swapViewModel.selectedGot?.symbol ?? "")")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.white60)
                    }
                    HStack {
                        Text("Allowed Slippage")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.white60.opacity(0.6))
                        Spacer()
                        Text("0.50%")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.white60)
                    }
                    HStack {
                        Text("Liquidity Provider Fee")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.white60.opacity(0.6))
                        Spacer()
                        Text(liquidityProviderFee)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.white60)
                    }
                }
                .padding(.leading, 5)
            }
            .padding(.vertical, 18)
            .padding(.leading, 17)
            .padding(.trailing, 19)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white40, lineWidth: 1))
            .padding(.bottom, 46)
            .padding(.horizontal, 16)
            Button {
                Lock.shared.requireAuthetication { bool in
                    if bool {
                        dismissCancellable = dismiss()?.sink(receiveValue: { _ in
                            showConfirmation(.transaction(swapViewModel: swapViewModel))
                        })

                    }
                }
            } label: {
                Text("Confirm Swap")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(Color.white)
                    .frame(width: UIScreen.main.bounds.width - 84, height: 41)
                    .background(Color.timelessBlue.cornerRadius(20.5))
                    .padding(.bottom, 8)
            }
            .padding(.bottom, 8)
            // swiftlint:disable line_length
            Text("Output is estimated. You will receive at least \(minimumReceived) \(swapViewModel.selectedGot?.symbol ?? "") or the transaction will revert.")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color.white40.opacity(0.6))
                .kerning(-0.5)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
        }
    }

    private var line: some View {
        VStack {
            Divider()
        }
    }
}
