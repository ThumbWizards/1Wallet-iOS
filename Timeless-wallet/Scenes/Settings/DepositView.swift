//
//  DepositView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 04/01/2022.
//

import SwiftUI
import Combine

struct DepositView: View {
    // MARK: - Input Parameters
    var firstDeposit = false

    // MARK: - Properties
    @State private var selectedProvider = ProviderType.simplex
    @State private var dismissCancellable: AnyCancellable?
    @State private var weeklyLimit: Double = 1000
    @StateObject private var walletInfo = WalletInfo.shared

    var providerList = [ProviderType.simplex,
                        ProviderType.transak,
                        ProviderType.ramp,
                        ProviderType.wyre]
}

// MARK: - Body view
extension DepositView {
    var body: some View {
        ZStack(alignment: .top) {
            Color.sheetBG
            VStack(spacing: 0) {
                header
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        titleAndSubtitle
                        contentView
                        amountSelection
                        continueButton
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - Subview
extension DepositView {
    private var header: some View {
        ZStack {
            Text("Buy")
                .tracking(-0.1)
                .foregroundColor(Color.white87)
                .font(.system(size: 18, weight: .semibold))
                .offset(y: -1)
                .opacity(firstDeposit ? 1 : 0)
            VStack(spacing: 4) {
                Text("Add Funds")
                    .tracking(0)
                    .foregroundColor(Color.white87)
                    .font(.system(size: 18, weight: .semibold))
                Text("$\(Int(weeklyLimit)) Weekly Limit")
                    .tracking(0.2)
                    .foregroundColor(Color.addFundsSubtitle)
                    .font(.system(size: 12))
            }
            .opacity(firstDeposit ? 0 : 1)
            HStack {
                Spacer()
                WalletAvatar(wallet: walletInfo.currentWallet, frame: CGSize(width: 30, height: 30))
                .onTapGesture {
                    showConfirmation(.avatar())
                }
            }
            .padding(.trailing, 18.5)
            HStack {
                Button(action: { onTapClose() }) {
                    Image.closeBackup
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 30)
                }
                .padding(.leading, 18.5)
                Spacer()
            }
        }
        .padding(.top, 26)
    }

    private var titleAndSubtitle: some View {
        VStack(spacing: 11.5) {
            ZStack {
                Text("First Deposit")
                    .tracking(-0.2)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color.white)
                    .opacity(firstDeposit ? 1 : 0)
                Text("Cash to $ONE")
                    .tracking(-0.2)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color.white)
                    .opacity(firstDeposit ? 0 : 1)
            }
            Text("Partnering with leading service providers for the best buying experience")
                .tracking(-0.2)
                .font(.system(size: 14, weight: .medium))
                .lineSpacing(5)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.white)
                .opacity(0.8)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 50)
        }
        .padding(.top, 50)
    }

    private var contentView: some View {
        VStack(spacing: 9.5) {
            Button(action: { onTapProvider() }) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.providerBG)
                    .frame(height: 69)
                    .overlay(
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.providerStroke, lineWidth: 0.7)
                            selectedProvider.logo
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: selectedProvider.logoSize.width, height: selectedProvider.logoSize.height)
                                .padding(.leading, 16)
                            HStack(spacing: 0) {
                                Spacer()
                                Text("Third Party Provider")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.providerDescribe)
                                    .padding(.trailing, providerList.count == 1 ? 21 : 9)
                                if providerList.count != 1 {
                                    Image.chevronRight
                                        .resizable()
                                        .frame(width: 9, height: 15)
                                        .foregroundColor(Color.providerSystemIcon)
                                        .padding(.trailing, 21)
                                }
                            }
                        }
                    )
                    .padding(.horizontal, 16)
            }
            Text("Simplex will receive only the wallet address info")
                .tracking(0.1)
                .font(.system(size: 13))
                .foregroundColor(Color.white)
                .opacity(0.25)
        }
        .padding(.top, 53)
    }

    private var amountSelection: some View {
        VStack(spacing: 49) {
            HStack(spacing: 18) {
                amountCircle(50)
                amountCircle(100)
                amountCircle(200)
            }
            .padding(.horizontal, 20)
            Button(action: { onTapSpecifyAmount() }) {
                RoundedRectangle(cornerRadius: .infinity)
                    .foregroundColor(Color.confirmationSheetCancelBG)
                    .frame(width: 193, height: 41)
                    .overlay(
                        Text("Specify Amount")
                            .font(.system(size: 17))
                            .foregroundColor(Color.white)
                            .opacity(0.6)
                    )
            }
        }
        .padding(.top, 39)
    }

    private var continueButton: some View {
        VStack(spacing: 0) {
            // swiftlint:disable line_length
            AttributedTextView(attributedText: AttributedTextView.createLinkableText(
                text: "By continuing, you acknowledge that you’ve read and accept <a href=\"https://www.simplex.com/terms-of-use/payment-terms\">Simplex User Agreement</a>"
            ))
            .frame(height: 47)
            .padding(.horizontal, 33)
            Button(action: { onTapContinue() }) {
                RoundedRectangle(cornerRadius: .infinity)
                    .foregroundColor(Color.timelessBlue)
                    .frame(height: 41)
                    .overlay(
                        Text("Continue")
                            .font(.system(size: 17))
                            .foregroundColor(Color.white)
                    )
            }
            .padding(.horizontal, 43)
        }
        .padding(.top, 50)
        .padding(.bottom, 60)
    }

    private func amountCircle(_ amount: Int) -> some View {
        return Button(action: {
            dismissCancellable = dismiss()?.sink(receiveValue: { _ in
                present(NavigationView { AddFundsView(inputCurrency: Double(amount), inputProvider: .simplex).hideNavigationBar() })
            })
        }) {
            RoundedRectangle(cornerRadius: .infinity)
                .foregroundColor(Color.xmarkBackground)
                .frame(width: (UIScreen.main.bounds.width - 92) / 3, height: (UIScreen.main.bounds.width - 92) / 3)
                .overlay(
                    Text("$\(amount)")
                        .tracking(-0.3)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color.white)
                )
        }
    }
}

// MARK: - Methods
extension DepositView {
    private func onTapClose() {
        dismiss()
    }

    private func onTapQR() {
        present(ProfileModal(wallet: walletInfo.currentWallet), presentationStyle: .fullScreen)
    }

    private func onTapProvider() {
        push(ProviderView(currencyValue: .constant(0),
                          fromDeposit: true,
                          selectedProvider: $selectedProvider,
                          providerList: providerList))
    }

    private func onTapContinue() {
        onTapSpecifyAmount()
    }

    private func onTapSpecifyAmount() {
        dismissCancellable = dismiss()?.sink(receiveValue: { _ in
            present(NavigationView { AddFundsView().hideNavigationBar() })
        })
    }
}
