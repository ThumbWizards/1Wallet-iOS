//
//  ProviderView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 18/11/2021.
//

import SwiftUI

struct ProviderView: View {
    // MARK: - Input parameters
    @Binding var currencyValue: Double
    var fromDeposit = false
    @Binding var selectedProvider: ProviderType
    var providerList: [ProviderType]

    // MARK: - Properties
    @ObservedObject private var viewModel = AddFundsView.ViewModel.shared
}

// MARK: - Body view
extension ProviderView {
    var body: some View {
        ZStack(alignment: .top) {
            Color.sheetBG
            VStack(spacing: 0) {
                header
                provider
            }
        }
        .hideNavigationBar()
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - Subview
extension ProviderView {
    private var header: some View {
        ZStack {
            HStack {
                Button(action: { onTapClose() }) {
                    Image.backSheet
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .padding(.leading, 18.5)
                .offset(y: -1)
                Spacer()
            }
            VStack(spacing: 4) {
                Text("Provider")
                    .tracking(0)
                    .foregroundColor(Color.white87)
                    .font(.system(size: 18, weight: .semibold))
                Text("Fiat-to-Crypto Gateway")
                    .tracking(0.2)
                    .foregroundColor(Color.addFundsSubtitle)
                    .font(.system(size: 12))
            }
        }
        .padding(.top, 26.5)
        .padding(.bottom, 55)
    }

    private var provider: some View {
        VStack(spacing: 10) {
            ForEach(providerList, id: \.self) { value in
                Button(action: { onTapProvider(value) }) {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color.providerBG)
                        .frame(height: 69)
                        .overlay(
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.providerStroke, lineWidth: 0.7)
                                value.logo
                                    .resizable()
                                    .renderingMode(.original)
                                    .frame(width: value.logoSize.width, height: value.logoSize.height)
                                    .padding(.leading, 16)
                                HStack(spacing: 0) {
                                    Spacer()
                                    providerText(value)
                                }
                            }
                        )
                        .padding(.horizontal, 16)
                }
                .disabled(value != .simplex)
            }
        }
        .padding(.bottom, 38)
    }

    private func providerText(_ value: ProviderType) -> some View {
        HStack(spacing: 0) {
            ZStack {
                if value != .simplex {
                    Text("COMING SOON")
                        .font(.system(size: 14))
                        .foregroundColor(Color.providerDescribe)
                        .padding(.trailing, 18)
                } else {
                    if viewModel.isSwaping {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .padding(.trailing, 15)
                    } else {
                        Text("~\(viewModel.rateOne) ONE")
                            .font(.system(size: 14))
                            .foregroundColor(Color.providerDescribe)
                            .padding(.trailing, 15)
                            .opacity(fromDeposit || currencyValue < 50 ? 0 : 1)
                    }
                }
            }
            if value == .simplex {
                Image.checkmark
                    .resizable()
                    .frame(width: 15, height: 15)
                    .foregroundColor(Color.providerSystemIcon)
                    .padding(.trailing, 19)
                    .opacity(selectedProvider == value ? 1 : 0)
            }
        }
    }
}

// MARK: - Methods
extension ProviderView {
    private func exchangeValue(_ value: CGFloat) -> String {
        return "\(Utils.formatBalance(Double(value))) USD"
    }

    private func onTapClose() { pop() }
    private func onTapProvider(_ value: ProviderType) {
        selectedProvider = value
        onTapClose()
    }
}
