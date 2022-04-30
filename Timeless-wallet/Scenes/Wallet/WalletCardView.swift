//
//  WalletCardView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 24/01/2022.
//

import SwiftUI

struct WalletCardView {
    // MARK: Input Parameters
    var item: CarouselItem
    @StateObject var overviewModel: WalletOverviewView.ViewModel

    // MARK: - Properties
    @State private var renderUI = false
    @AppStorage(ASSettings.Settings.showCurrencyWallet.key)
    private var showCurrencyWallet = ASSettings.Settings.showCurrencyWallet.defaultValue
    @AppStorage(ASSettings.Settings.walletBalance.key)
    private var walletBalance = ASSettings.Settings.walletBalance.defaultValue
    @ObservedObject private var viewModel = WalletView.ViewModel.shared
    @StateObject var UIState = UIStateModel(cardWidth: UIScreen.main.bounds.width - 65,
                                            cardHeight: UIScreen.main.bounds.height * 0.49 + 5,
                                            firstSpacing: 16,
                                            spacing: 20,
                                            hiddenCardScale: 0.9)

    private var showPlaceHolder: Bool {
        overviewModel.totalUSDAmount == nil || overviewModel.totalONEAmount == nil
    }
    private let generator = UINotificationFeedbackGenerator()
}

extension WalletCardView: View {
    // MARK: - Bodyview
    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { proxy in
                WalletAvatar(wallet: item.wallet, frame: CGSize(width: proxy.size.width,
                                                                height: proxy.size.height),
                             isCircle: false)
                    .id(item.id)
                    .cornerRadius(19)
                    .onTapGesture {
                        present(WalletDetailView(wallet: item.wallet), presentationStyle: .automatic)
                    }
            }
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(item.wallet.nameFullAlias)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.white)
                        .lineLimit(1)
                        .frame(width: UIState.cardWidth - 92, alignment: .leading)
                    if showPlaceHolder {
                        PlaceHolderBalanceView(font: .system(size: 15), cornerRadius: 5)
                    } else {
                        SwapCurrencyView(
                            usdStr: viewModel.getStrBeforeDecimal(overviewModel.totalUSDAmount),
                            decimalUSD: viewModel.getStrAfterDecimal(overviewModel.totalUSDAmount),
                            oneStr: viewModel.getStrBeforeDecimal(overviewModel.totalONEAmount),
                            decimalONE: viewModel.getStrAfterDecimal(overviewModel.totalONEAmount, isThreeDigit: true),
                            type1: "$",
                            type2: "ONE",
                            isSpacing1: false,
                            isSpacing2: true,
                            valueAfterType: true,
                            font: .system(size: 15),
                            decimalColor: Color.white
                        )
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: showPlaceHolder)
                Spacer(minLength: 0)
            }
            .padding(18)
            HStack(spacing: 0) {
                Spacer()
                Button(action: {
                    showConfirmation(.moreAction(wallet: item.wallet))
                }) {
                    Color.almostClear
                        .frame(width: 74, height: 70)
                        .overlay(
                            Text("-")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color.clear)
                                .overlay(Image.ellipsis.foregroundColor(Color.white))
                                .padding(.top, 18), alignment: .top)
                }
            }
        }
        .overlay(renderUI ? EmptyView() : EmptyView())
    }
}

struct WalletPreviewMenu: View {
    // MARK: - Input Parameters
    var wallet: Wallet
    @ObservedObject var overviewModel: WalletOverviewView.ViewModel

    // MARK: - Properties
    @ObservedObject private var viewModel = WalletView.ViewModel.shared
    private var showPlaceHolder: Bool {
        wallet.detailViewModel.overviewModel.totalUSDAmount == nil || wallet.detailViewModel.overviewModel.totalONEAmount == nil
    }

    // MARK: - Body view
    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { proxy in
                WalletAvatar(wallet: wallet, frame: CGSize(width: proxy.size.width,
                                                           height: proxy.size.height),
                             isCircle: false)
                    .background(Color.primaryBackground)
            }
            HStack {
                VStack(alignment: .leading) {
                    Text(wallet.nameFullAlias)
                        .lineLimit(1)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.white)
                    if showPlaceHolder {
                        PlaceHolderBalanceView(font: .system(size: 15), cornerRadius: 5)
                    } else {
                        SwapCurrencyView(
                            usdStr: viewModel.getStrBeforeDecimal(overviewModel.totalUSDAmount),
                            decimalUSD: viewModel.getStrAfterDecimal(overviewModel.totalUSDAmount),
                            oneStr: viewModel.getStrBeforeDecimal(overviewModel.totalONEAmount),
                            decimalONE: viewModel.getStrAfterDecimal(overviewModel.totalONEAmount, isThreeDigit: true),
                            type1: "$",
                            type2: "ONE",
                            isSpacing1: false,
                            isSpacing2: true,
                            valueAfterType: true,
                            font: .system(size: 15),
                            decimalColor: Color.white
                        )
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: showPlaceHolder)
                Spacer()
            }
            .padding(.leading, 18)
            .padding(.vertical, 18)
            .padding(.trailing, 48)
        }
    }
}
