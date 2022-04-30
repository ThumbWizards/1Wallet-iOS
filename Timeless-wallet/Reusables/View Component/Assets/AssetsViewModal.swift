//
//  AssetsViewModal.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 1/14/22.
//

import SwiftUI

struct AssetsViewModal {
    @State private var isHide = false
    @AppStorage(ASSettings.Assets.hideSmallBalances.key)
    private var hideSmallBalances = ASSettings.Assets.hideSmallBalances.defaultValue
    @AppStorage(ASSettings.Assets.assetsOrder.key)
    private var assetsOrder = ASSettings.Assets.assetsOrder.defaultValue
}

extension AssetsViewModal: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                headerView
                contentView
                Spacer()
            }
            .height(391)
            buttonClose
        }
    }
}

extension AssetsViewModal {
    private var headerView: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Assets")
                    .tracking(-0.3)
                    .font(.system(size: 20))
                    .foregroundColor(Color.white)
                Text("@\(Wallet.currentWallet?.name ?? "")")
                    .font(.system(size: 15))
                    .foregroundColor(Color.white60)
                    .padding(.trailing, 68)
            }
            Spacer()
        }
        .padding(.top, 38)
        .padding(.leading, 26)
        .padding(.bottom, 30)
    }

    private var contentView: some View {
        VStack(alignment: .leading, spacing: 40) {
            orderSegmentView
            balanceToggle
        }
        .padding(.leading, 30)
        .padding(.trailing, 13)
    }

    private var orderSegmentView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ORDER BY")
                .font(.system(size: 16))
                .foregroundColor(Color.white60)
            SegmentedPicker(items: ASSettings.AssetsOrder.allCases.map { $0.title },
                            selection: $assetsOrder)
        }
    }

    private var balanceToggle: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("BALANCE")
                .font(.system(size: 16))
                .foregroundColor(Color.white60)
            VStack {
                ZStack {
                    HStack(spacing: 0) {
                        ZStack {
                            Image.appsiPhone
                                .resizable()
                                .foregroundColor(Color.white)
                                .frame(width: 10, height: 17)
                        }
                        .frame(width: 26.5)
                        .padding(.trailing, 12)
                        Text("Hide Small Balances")
                            .font(.system(size: 17))
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .foregroundColor(Color.white)
                            .padding(.trailing, 5)
                        Spacer(minLength: 5)
                        ZStack {
                            Toggle("", isOn: $hideSmallBalances)
                                .toggleStyle(SwitchToggleStyle(tint: Color.timelessBlue))
                                .scaleEffect(0.8)
                                .offset(x: -11)
                        }
                        .frame(width: 80, height: 51, alignment: .trailing)
                        .overlay(Color.almostClear)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                hideSmallBalances.toggle()
                            }
                        }
                    }
                }
                .padding(.leading, 17)
                .frame(height: 51)
            }
            .frame(width: UIScreen.main.bounds.width - 32)
            .background(Color.formForeground)
            .cornerRadius(12)
        }
    }

    private var buttonClose: some View {
        Button(action: { onTapClose() }) {
            Image.closeSmall
                .resizable()
                .frame(width: 25, height: 25)
        }
        .padding(.top, 36)
        .padding(.trailing, 31)
    }
}

extension AssetsViewModal {
    private func onTapClose() {
        hideConfirmationSheet()
    }
}
