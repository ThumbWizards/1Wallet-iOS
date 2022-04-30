//
//  TransactionConfirmModal.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/17/21.
//

import SwiftUI

struct TransactionConfirmModal {
    @ObservedObject var swapViewModel: SwapView.ViewModel
    @State private var renderUI = false
}

extension TransactionConfirmModal: View {
    var body: some View {
        Group {
            switch swapViewModel.transactionState {
            case .successful:
                confirmedView
            default: waitingView
            }
        }
        .height(501)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            renderUI.toggle()
        }
        .onAppear {
            switch swapViewModel.transactionState {
            case .none:
                if swapViewModel.selectedGot?.token != nil {
                    swapViewModel.swapONEToToken()
                } else if swapViewModel.selectedPay?.token != nil {
                    swapViewModel.swapTokenToONE()
                }
            default: break
            }
        }
    }
}

extension TransactionConfirmModal {
    private var waitingView: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button {
                    hideConfirmationSheet()
                } label: {
                    Image.closeBackup
                        .resizable()
                        .frame(width: 25, height: 25)
                }
            }
            .padding(.trailing, 26)
            .padding(.bottom, 16)
            Text("Waiting for Confirmation")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.white)
                .padding(.bottom, 10)
            Text("Swapping \(swapViewModel.payText) \(swapViewModel.selectedPay?.symbol ?? "") with \(swapViewModel.gotText) \(swapViewModel.selectedGot?.symbol ?? "")")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white87)
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .padding(.bottom, 60)
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
            Spacer()
            // swiftlint:disable line_length
            Text("Confirm this transaction in your wallet.\n For your safety and convenience, we notify all transactions via account email.")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color.white87)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 22)
            Button {
                hideConfirmationSheet()
            } label: {
                HStack {
                    Text("OK")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color.white)
                }
                .frame(width: UIScreen.main.bounds.width - 38, height: 48)
                .background(Color.timelessBlue.cornerRadius(15))
            }
        }
        .padding(.top, 26)
        .padding(.bottom, 45)
    }

    private var loadingView: some View {
        LottieView(name: "circle-loading", loopMode: .constant(.loop), isAnimating: .constant(true))
            .scaledToFill()
            .frame(width: 98, height: 86)
    }

    private var confirmedView: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button {
                    hideConfirmationSheet()
                } label: {
                    Image.closeBackup
                        .resizable()
                        .frame(width: 25, height: 25)
                }
            }
            .padding(.trailing, 26)
            .padding(.bottom, 16)
            Text("Transaction Confirmed")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.white)
                .padding(.bottom, 10)
            Text("Sucessfully swapped \(swapViewModel.payText) \(swapViewModel.selectedPay?.symbol ?? "") with \(swapViewModel.gotText) \(swapViewModel.selectedGot?.symbol ?? "")")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white87)
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .padding(.bottom, 60)
                .padding(.horizontal, 53.5)
            HStack(spacing: 0) {
                Spacer()
                if renderUI {
                    successView
                } else {
                    successView
                }
                Spacer()
            }
            Spacer()
            Text("View Transaction in Block Explorer")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color.white87)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 22)
            Button {
                hideConfirmationSheet()
            } label: {
                HStack {
                    Text("OK")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color.white)
                }
                .frame(width: UIScreen.main.bounds.width - 38, height: 48)
                .background(Color.timelessBlue.cornerRadius(15))
            }
        }
        .padding(.top, 26)
        .padding(.bottom, 45)
    }

    private var successView: some View {
        LottieView(name: "success", loopMode: .constant(.loop), isAnimating: .constant(true))
            .scaledToFill()
            .frame(width: 102, height: 99)
    }
}
