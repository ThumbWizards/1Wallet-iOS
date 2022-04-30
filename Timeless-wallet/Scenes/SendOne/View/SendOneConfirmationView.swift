//
//  PaymentConfirmationView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 26/11/21.
//

import SwiftUI
import StreamChatUI

struct SendOneConfirmationView {
    // MARK: - Input Parameters
    @StateObject var viewModel: ViewModel

    // MARK: - Properties
    @State private var renderUI = false
    @State private var enableTap = true
    @State private var showDestinationAvatar = false

    // MARK: - Computed Variables
    var cancelBGColor: Color {
        if viewModel.isTransactionInProgress {
            return viewModel.canCancelTransaction ? Color.timelessBlue : Color.reviewButtonBackground
        } else {
            return Color.reviewButtonBackground
        }
    }
    var isCancelDisable: Bool {
        if viewModel.isTransactionInProgress {
            return viewModel.canCancelTransaction ? false : true
        } else {
            return false
        }
    }
}


// MARK: - Body view
extension SendOneConfirmationView: View {
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if viewModel.isTransactionInProgress {
                    Text("Sending \(viewModel.strFormattedAmount ?? "0") \(viewModel.token?.symbol ?? "ONE")")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color.white)
                } else {
                    Text("Send \(viewModel.strFormattedAmount ?? "0") \(viewModel.token?.symbol ?? "ONE")")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color.white)
                }
            }
            .padding(.top, 47.5)
            .padding(.bottom, 35)
            VStack(spacing: 7) {
                if viewModel.isTransactionInProgress {
                    processView
                } else {
                    detailView
                }
                Spacer(minLength: 0)
                VStack(spacing: 12) {
                    Text("You’ll be notified when the transaction completes")
                        .foregroundColor(Color.white.opacity(0.6))
                        .font(.system(size: 12))
                        .opacity(viewModel.isTransactionInProgress ? 1 : 0)
                    HStack(spacing: 0) {
                        cancelButton
                        confirmButton
                    }
                    .disabled(!enableTap)
                    .padding(.horizontal, 11)
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 30)
            .padding(.bottom, UIView.safeAreaBottom + 19)
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.isTransactionInProgress)
        .height(473)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            renderUI.toggle()
        }
        .onAppear {
            if viewModel.isDirectSend {
                viewModel.showDestinationAvatar = !(viewModel.transferOne?.recipientName ?? "").isEmpty
            } else {
                if (viewModel.sendOneWalletData.recipientName ?? "").isEmpty {
                    viewModel.checkTLUser()
                } else {
                    viewModel.showDestinationAvatar = true
                }
            }
        }
    }
}

// MARK: - Subview
extension SendOneConfirmationView {
    private var processView: some View {
        VStack(spacing: 15) {
            Text("Communicating with chain")
                .tracking(0.2)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.white.opacity(0.7))
            ZStack {
                HStack(spacing: 0) {
                    WalletAvatar(wallet: WalletInfo.shared.currentWallet, frame: CGSize(width: 58, height: 58))
                    Spacer(minLength: 0)
                    WalletAvatar(wallet: Wallet(address: viewModel.destinationAddressStr ?? ""),
                                 frame: CGSize(width: 58, height: 58))
                }
                .padding(.horizontal, 19)
                if renderUI {
                    loadingView
                } else {
                    loadingView
                }
            }
        }
        .padding(.top, 9)
    }

    private var detailView: some View {
        VStack(alignment: .leading, spacing: 34.5) {
            sendFromView
            sendToView
        }
        .padding(.horizontal, 1)
    }

    private var sendFromView: some View {
        HStack(spacing: 0) {
            Text("FROM")
                .font(.system(size: 14, weight: .medium))
                .frame(width: 50)
                .foregroundColor(Color.paymentTitleFont.opacity(0.8))
                .padding(.trailing, 6)
            WalletAvatar(wallet: WalletInfo.shared.currentWallet, frame: CGSize(width: 58, height: 58))
                .padding(.trailing, 15)
            VStack(alignment: .leading, spacing: 5) {
                Text(viewModel.sendFromName ?? "-")
                    .lineLimit(1)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.87))
                WalletAddressView(address:viewModel.sendFromAddress ?? "-", trimCount: 10)
                    .lineLimit(1)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.8))
            }
            Spacer(minLength: 0)
        }
    }

    private var sendToView: some View {
        ZStack {
            if viewModel.loadRecipientName {
                VStack(alignment: .leading, spacing: 5) {
                    PlaceHolderBalanceView(font: .system(size: 14, weight: .medium), cornerRadius: 5, placeholderText: "TO")
                        .frame(width: 50)
                    PlaceHolderDestinationWallet(cornerRadius: 8)
                        .frame(height: 41)
                }
            } else {
                if viewModel.showDestinationAvatar {
                    HStack(spacing: 0) {
                        Text("TO")
                            .font(.system(size: 14, weight: .medium))
                            .frame(width: 50)
                            .foregroundColor(Color.paymentTitleFont.opacity(0.8))
                            .padding(.trailing, 6)
                        WalletAvatar(wallet: Wallet(address: viewModel.destinationAddressStr ?? ""),
                                     frame: CGSize(width: 58, height: 58))
                            .padding(.trailing, 15)
                        VStack(alignment: .leading, spacing: 5) {
                            Text(viewModel.isDirectSend ? (viewModel.transferOne?.recipientName ?? "-") :
                                                          (viewModel.sendOneWalletData.recipientName ?? "-"))
                                .lineLimit(1)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.white.opacity(0.87))
                            WalletAddressView(address: viewModel.destinationAddressStr ?? "-", trimCount: 10)
                                .lineLimit(1)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.8))
                        }
                        Spacer(minLength: 0)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("TO")
                            .font(.system(size: 14, weight: .medium))
                            .padding(.leading, 5)
                            .foregroundColor(Color.paymentTitleFont.opacity(0.8))
                        addressView
                    }
                }
            }
        }
    }

    private var addressView: some View {
        RoundedRectangle(cornerRadius: 8)
            .foregroundColor(Color.paymentWalletConfirmBG)
            .frame(height: 41)
            .overlay(
                Text((viewModel.destinationAddressStr ?? "").convertToWalletAddress().trimStringByCount(count: 10))
                    .font(.system(size: 16))
                    .foregroundColor(Color.white.opacity(0.87))
                    .padding(.leading, 21)
                    .offset(y: 1), alignment: .leading
            )
            .padding(.horizontal, 5)
    }

    private var loadingView: some View {
        LottieView(name: "confirmation-loading", loopMode: .constant(.loop), isAnimating: .constant(true))
            .scaledToFill()
            .frame(height: 40)
            .scaleEffect(0.75)
            .offset(x: 5, y: 4)
    }

    private var cancelButton: some View {
        Button(action: { onTapCancel() }) {
            RoundedRectangle(cornerRadius: .infinity)
                .foregroundColor(cancelBGColor)
                .frame(width: !viewModel.isTransactionInProgress ? 89 : nil, height: 41)
                .overlay(
                    Text("Cancel")
                        .font(.system(size: 17))
                        .foregroundColor(Color.white.opacity(0.87))
                )
        }
        .disabled(isCancelDisable)
        .opacity(isCancelDisable ? 0.7 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isCancelDisable)
        .padding(.trailing, viewModel.isTransactionInProgress ? 0 : 8)
    }

    private var confirmButton: some View {
        Button(action: { onTapConfirm() }) {
            RoundedRectangle(cornerRadius: .infinity)
                .foregroundColor(Color.timelessBlue)
                .frame(width: viewModel.isTransactionInProgress ? 0 : nil, height: 41)
                .overlay(
                    Text("Confirm Send")
                        .font(.system(size: 17))
                        .foregroundColor(Color.white.opacity(0.87))
                )
        }
        .disabled(viewModel.isTransactionInProgress)
        .opacity(viewModel.isTransactionInProgress ? 0 : 1)
    }

    struct PlaceHolderDestinationWallet: View {
        @State private var isShowed = false
        var cornerRadius: CGFloat = 10

        var body: some View {
            Color.white.opacity(0.05)
                .overlay(LoadingShimmerView(isShowed: isShowed, color: Color.placeHolderBalanceBG.opacity(0.9)))
                .cornerRadius(cornerRadius)
                .onAppear {
                    withAnimation(Animation.default.speed(0.15).delay(0).repeatForever(autoreverses: false)) {
                        isShowed.toggle()
                    }
                }
        }
    }
}

// MARK: - Methods
extension SendOneConfirmationView {
    private func onTapCancel() {
        if viewModel.isTransactionInProgress {
            disableTap()
            viewModel.cancelTransaction()
        } else {
            hideConfirmationSheet()
        }
    }

    private func onTapConfirm() {
        Lock.shared.requireAuthetication { isAuthenticated in
            if isAuthenticated {
                disableTap()
                viewModel.sendOne()
            }
        }
    }

    private func disableTap() {
        enableTap = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            enableTap = true
        }
    }
}
