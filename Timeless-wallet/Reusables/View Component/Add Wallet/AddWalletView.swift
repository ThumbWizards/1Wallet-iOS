//
//  AddWalletView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 17/01/22.
//

import SwiftUI
import AVFoundation
import SwiftMessages

struct AddWalletView { }

// MARK: - Body view
extension AddWalletView: View {
    @ViewBuilder
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .foregroundColor(Color.white60)
                .frame(width: 40, height: 5)
                .cornerRadius(2.5)
                .padding(.top, 9)
                .padding(.bottom, 25)
            Text("Add a New Wallet")
                .tracking(-0.4)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.white)
                .padding(.bottom, 12)
            // swiftlint:disable line_length
            Text("On Timeless, wallets are used as identity for all your activities. Think \"Profile\" on Netflix — create one for every occasion!")
                .tracking(-0.1)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white87)
                .lineSpacing(5)
                .multilineTextAlignment(.center)
                .padding(.bottom, 33)
                .padding(.horizontal, 53.5)
            Spacer()
            HStack(spacing: 0) {
                Spacer()
                loadingView
                Spacer()
            }
            .padding(.bottom, 36)
            Spacer()
            Button {
                showWalletView()
            } label: {
                HStack {
                    Text("Generate new wallet")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color.white60)
                }
                .frame(width: UIScreen.main.bounds.width - 82, height: 42)
                .background(Color.confirmationSheetCancelBG.cornerRadius(.infinity))
            }
            .padding(.bottom, 11)
            // TODO: Bind Restore Wallet flow
//            Button { } label: {
//                HStack {
//                    Text("Restore wallet")
//                        .font(.system(size: 17, weight: .semibold))
//                        .foregroundColor(Color.white60)
//                }
//                .frame(width: UIScreen.main.bounds.width - 82, height: 42)
//                .background(Color.confirmationSheetCancelBG.cornerRadius(.infinity))
//            }
//            .padding(.bottom, 11)
            Button {
                hideConfirmationSheet()
                showSnackBar(.errorMsg(text: "Not available on alpha release"))
                // TODO:- Disable for demo
                /*
                hideConfirmationSheet()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    present(WatchPublicAddressModal())
                }
                 */
            } label: {
                HStack {
                    Text("Watch public address")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color.white60)
                }
                .opacity(0.2)
                .frame(width: UIScreen.main.bounds.width - 82, height: 42)
                .background(Color.confirmationSheetCancelBG.cornerRadius(.infinity))
            }
            .padding(.bottom, 30)
            Spacer(minLength: 0)
        }
        .height(541)
        .onAppear {
            CryptoHelper.shared.generateWalletPayloadSilent()
        }
    }

    private var loadingView: some View {
        LottieView(name: "circle-loading", loopMode: .constant(.loop), isAnimating: .constant(true))
            .scaledToFill()
            .frame(width: 151, height: 131)
    }
}

// MARK: - Methods
extension AddWalletView {
    private func onScanSuccess(strScanned: String) {
        if let url = URL(string: strScanned), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    private func showWalletView() {
        hideConfirmationSheet()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            present(NewWalletView())
        }
    }
}


struct AddWalletView_Previews: PreviewProvider {
    static var previews: some View {
        AddWalletView()
    }
}
