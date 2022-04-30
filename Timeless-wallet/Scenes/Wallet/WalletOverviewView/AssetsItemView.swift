//
//  AssetsItemView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 1/14/22.
//

import SwiftUI

struct AssetsItemView {
    // MARK: - Input Parameters
    var walletAsset: [WalletAssetInfo]
    @ObservedObject var viewModel: WalletOverviewView.ViewModel

    // MARK: - Properties
    @AppStorage(ASSettings.Assets.hideSmallBalances.key)
    private var hideSmallBalances = ASSettings.Assets.hideSmallBalances.defaultValue
    @AppStorage(ASSettings.Assets.assetsOrder.key)
    private var assetsOrder = ASSettings.Assets.assetsOrder.defaultValue
    @AppStorage(ASSettings.Settings.showCurrencyWallet.key)
    private var showCurrencyWallet = ASSettings.Settings.showCurrencyWallet.defaultValue
    @AppStorage(ASSettings.Settings.walletBalance.key)
    private var walletBalance = ASSettings.Settings.walletBalance.defaultValue
    @State private var isShowing = false
}

// MARK: - Computed variables
extension AssetsItemView {
    private var listWalletAssetOrder: [WalletAssetInfo] {
        var list = [WalletAssetInfo]()
        switch assetsOrder {
        case ASSettings.AssetsOrder.network.selection:
            list = walletAsset.sorted(by: { $0.symbol.lowercased() < $01.symbol.lowercased() })
        case ASSettings.AssetsOrder.positionSize.selection:
            list = walletAsset.sorted(by: { $0.displayAmount < $1.displayAmount })
        default:
            return []
        }
        if hideSmallBalances {
            return list.filter { $0.displayAmount > 0.0001 }
        }
        return list
    }
}

extension AssetsItemView: View {
    var body: some View {
        ZStack {
            Color.walletDetailBottomBtn
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(viewModel.wallet.nameFullAlias)
                        .font(.system(size: 15))
                        .foregroundColor(Color.white.opacity(0.6))
                        .lineLimit(1)
                        .padding(.top, 22)
                        .padding(.bottom, 10)
                    HStack(spacing: 12) {
                        SwapCurrencyView(
                            usdStr: WalletView.ViewModel.shared.getStrBeforeDecimal(viewModel.totalUSDAmount),
                            decimalUSD: WalletView.ViewModel.shared.getStrAfterDecimal(viewModel.totalUSDAmount),
                            oneStr: WalletView.ViewModel.shared.getStrBeforeDecimal(viewModel.totalONEAmount),
                            decimalONE: WalletView.ViewModel.shared.getStrAfterDecimal(viewModel.totalONEAmount, isThreeDigit: true),
                            type1: "$",
                            type2: "ONE",
                            isSpacing1: false,
                            isSpacing2: true,
                            valueAfterType: true,
                            font: .system(size: 30, weight: .medium),
                            color: Color.white.opacity(0.87),
                            tracking: -0.1
                        )
                        Spacer()
                        Button(action: {
                            withAnimation {
                                isShowing.toggle()
                            }
                        }) {
                            HStack(spacing: 12.5) {
                                Text("\(listWalletAssetOrder.count) Asset\(listWalletAssetOrder.count > 1 ? "s" : "")")
                                    .foregroundColor(Color.white.opacity(0.6))
                                    .font(.system(size: 15))
                                Image.chevronRight
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.white.opacity(0.6))
                                    .offset(y: 1)
                                    .rotation3DEffect(.degrees(isShowing ? 90 : 0), axis: .z)
                            }
                        }
                        .disabled(listWalletAssetOrder.isEmpty)
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 14.5)
                .padding(.bottom, isShowing && !listWalletAssetOrder.isEmpty ? 10.5 : 17)
                if isShowing && !listWalletAssetOrder.isEmpty {
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color.white.opacity(0.08))
                        .padding(.leading, 10)
                        .padding(.trailing, 12.5)
                    ForEach(listWalletAssetOrder, id: \.self) { data in
                        Group {
                            itemView(data)
                            if data != listWalletAssetOrder.last {
                                Rectangle()
                                    .frame(height: 0.5)
                                    .foregroundColor(Color.white.opacity(0.08))
                                    .padding(.leading, 10)
                                    .padding(.trailing, 12.5)
                            }
                        }
                        .padding(.bottom, 1.5)
                    }
                }
            }
        }
        .cornerRadius(12)
        .padding(.leading, 17)
        .padding(.trailing, 13)
    }
}

extension AssetsItemView {
    private func formatAndSplitCurrency(_ number: Double?, digits: Int = 2) -> [String] {
        if let number = number {
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = digits
            formatter.maximumFractionDigits = digits
            formatter.roundingMode = .down
            if let formattedCurrency = formatter.string(from: number as NSNumber) {
                let strings = formattedCurrency.components(separatedBy: Locale.current.decimalSeparator ?? "")
                return strings
            }
        }
        return []
    }

    private func itemView(_ walletAsset: WalletAssetInfo) -> some View {
        HStack(spacing: 12) {
            Image.oneBlackLogo
                .resizable()
                .renderingMode(.original)
                .scaledToFill()
                .frame(width: 40, height: 40)
                .cornerRadius(.infinity)
            VStack(alignment: .leading, spacing: 2) {
                Text(walletAsset.symbol)
                    .foregroundColor(Color.white.opacity(0.87))
                    .font(.system(size: 15, weight: .medium))
                    .lineLimit(1)
                Text(walletAsset.symbol == "ONE" ? "Harmony" : walletAsset.contractAddress.trimStringByCount(count: 6))
                    .tracking(0.2)
                    .foregroundColor(Color.white.opacity(0.4))
                    .font(.system(size: 15))
                    .lineLimit(1)
            }
            .padding(.top, 3)
            .padding(.bottom, 2)
            Spacer(minLength: 15)
            VStack(alignment: .trailing, spacing: 2) {
                DisplayCurrencyView(
                    value: Utils.formatBalance(walletAsset.displayAmount),
                    type: walletAsset.symbol,
                    isSpacing: true,
                    valueAfterType: false,
                    font: .system(size: 15),
                    color: Color.white.opacity(0.4),
                    tracking: 0.2
                )
                Text(showCurrencyWallet ?
                     "\(Utils.formatBalance(walletAsset.priceChangePercentage24h))% ($\(Utils.formatCurrency(walletAsset.priceChange)))" :
                        "•••••")
                    .tracking(0.2)
                    .foregroundColor(walletAsset.priceChangePercentage24h >= 0 ?
                                     Color.positiveColor : Color.assetsNegativeColor)
                    .font(.system(size: 15))
            }
            .padding(.top, 3)
            .padding(.bottom, 2)
        }
        .padding(.leading, 20)
        .padding(.trailing, 10.5)
        .padding(.vertical, 17)
    }
}
