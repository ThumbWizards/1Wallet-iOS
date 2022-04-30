//
//  DeleteAllDataView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 20/01/2022.
//

import SwiftUI

struct DeleteAllDataView {
    // MARK: - Properties
    @State private var renderUI = false
}

// MARK: - Body view
extension DeleteAllDataView: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                headerView
                VStack(spacing: 0) {
                    if renderUI {
                        lottieView
                    } else {
                        lottieView
                    }
                    Text("Are you sure you want to\ndelete all the data?")
                        .tracking(0.2)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 15))
                        .foregroundColor(Color.white.opacity(0.6))
                        .padding(.bottom, 30)
                }
                Button(action: { onTapDelete() }) {
                    RoundedRectangle(cornerRadius: .infinity)
                        .frame(height: 41)
                        .foregroundColor(Color.confirmationSheetCancelBG)
                        .padding(.horizontal, 43)
                        .overlay(
                            Text("Delete")
                                .tracking(-0.4)
                                .font(.system(size: 18))
                                .foregroundColor(Color.timelessRed.opacity(0.87))
                        )
                }
                .padding(.bottom, 11)
                Button(action: { onTapCancel() }) {
                    RoundedRectangle(cornerRadius: .infinity)
                        .frame(height: 41)
                        .foregroundColor(Color.confirmationSheetCancelBG)
                        .padding(.horizontal, 43)
                        .overlay(
                            Text("Cancel")
                                .tracking(-0.4)
                                .font(.system(size: 18))
                                .foregroundColor(Color.confirmationSheetCancelBtn)
                        )
                }
                .padding(.bottom, 45)
                Spacer(minLength: 0)
            }
            .height(485)
            closeButton
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            renderUI.toggle()
        }
    }

    private var lottieView: some View {
        HStack {
            Spacer()
            LottieView(name: "revised_red", loopMode: .constant(.loop), isAnimating: .constant(true))
                .scaledToFill()
                .frame(width: 124, height: 124)
                .scaleEffect(1.5)
                .offset(x: -4, y: -6)
                .padding(.top, 55)
                .padding(.bottom, 17)
            Spacer()
        }
    }
}

// MARK: - Subview
extension DeleteAllDataView {
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Delete All Data")
                    .tracking(-0.5)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color.white)
                Text("@\(Wallet.currentWallet?.name ?? "")")
                    .tracking(0.2)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.6))
            }
            Spacer()
        }
        .padding(.leading, 26)
        .padding(.trailing, 59)
        .padding(.top, 37)
    }

    private var closeButton: some View {
        Button(action: { onTapCancel() }) {
            Image.closeBackup
                .resizable()
                .frame(width: 25, height: 25)
                .padding(.vertical, 28)
                .padding(.horizontal, 31)
                .background(Color.almostClear)
        }
        .offset(y: 7)
    }
}

// MARK: - Methods
extension DeleteAllDataView {
    private func onTapDelete() {
        IdentityService.shared.logout()
        hideConfirmationSheet()
    }

    private func onTapCancel() {
        hideConfirmationSheet()
    }
}
