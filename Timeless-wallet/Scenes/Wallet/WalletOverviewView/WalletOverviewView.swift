//
//  WalletOverviewView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 1/11/22.
//

import SwiftUI
import RHLinePlot

struct WalletOverviewView {
    // MARK: - Input Parameters
    @ObservedObject var viewModel: ViewModel

    // MARK: - Properties
    @AppStorage(ASSettings.Settings.firstDeposit.key)
    private var firstDeposit = ASSettings.Settings.firstDeposit.defaultValue
    @AppStorage(ASSettings.Settings.showCurrencyWallet.key)
    private var showCurrencyWallet = ASSettings.Settings.showCurrencyWallet.defaultValue
    @AppStorage(ASSettings.Settings.walletBalance.key)
    private var walletBalance = ASSettings.Settings.walletBalance.defaultValue
    @State private var currentIndex: Int?
    @State private var tempIndex: Int?
    @State private var timeDisplayMode: TimeDisplayOption = .hourly
    @State private var colorUnit = Color.negativeColor
    @State private var renderUI = false

    // MARK: - Computed variables
    private var showPlaceHolder: Bool {
        viewModel.chartData.isEmpty || viewModel.loadingChartData
    }

    private var isEmptyWallet: Bool {
        viewModel.totalUSDAmount == 0
    }
}

// MARK: - Body view
extension WalletOverviewView: View {
    var body: some View {
        ZStack(alignment: .top) {
            if !viewModel.chartData.isEmpty || viewModel.loadingChartData {
                ScrollView(showsIndicators: false) {
                    if isEmptyWallet {
                        emptyView
                    } else {
                        VStack(spacing: 38.5) {
                            chartInfoView
                            assetInfoView
                        }
                        .padding(.bottom, UIView.safeAreaBottom)
                    }
                }
                .padding(.top, 15)
            }
        }
        .ignoresSafeArea()
        .loadingOverlay(isShowing: viewModel.chartData.isEmpty || viewModel.loadingChartData)
    }
}

// MARK: - Subview
// swiftlint:disable line_length
// swiftlint:disable function_body_length
extension WalletOverviewView {
    private var chartInfoView: some View {
        VStack(spacing: 10) {
            priceLabel()
                .padding(.top, 20)
            if viewModel.chartData.isEmpty || viewModel.loadingChartData {
                ZStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.2)
                }
                .frame(height: 220)
            } else {
                plotBody()
            }
            HStack(spacing: 12) {
                Spacer()
                ForEach(TimeDisplayOption.allCases, id: \.self) { option in
                    Button {
                        playHapticEvent()
                        viewModel.timeDisplayOption = option
                        viewModel.getChartData()
                    } label: {
                        ZStack {
                            Color.timelessBlue
                                .frame(width: 30, height: 30)
                                .cornerRadius(10)
                                .opacity(viewModel.timeDisplayOption == option ? 0.3 : 0)
                                .animation(.linear(duration: 0.2), value: viewModel.timeDisplayOption)
                            Text(option.title)
                                .foregroundColor(Color.timelessBlue)
                        }
                    }
                    Spacer()
                }
            }
            .font(.system(size: 14, weight: .medium))
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
        }
        .frame(width: UIScreen.main.bounds.width - 32)
        .background(Color.sendTextFieldBG.cornerRadius(10))
        .padding(.top, 20)
    }

    private var assetInfoView: some View {
        VStack(spacing: 10.5) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: .infinity)
                    .foregroundColor(Color.timelessBlue)
                    .frame(width: 2, height: 20)
                Text("Assets")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color.white)
                Spacer()
                Button(action: { showConfirmation(.assets) }) {
                    Image.sliderHorizontal
                        .resizable()
                        .frame(width: 21.5, height: 19)
                        .foregroundColor(Color.white)
                }
                .offset(y: 0.5)
            }
            .padding(.leading, 23.5)
            .padding(.trailing, 20.5)
            if let walletAsset = viewModel.walletAsset {
                AssetsItemView(walletAsset: walletAsset, viewModel: viewModel)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.2)
            }
        }
    }

    var emptyView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
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
                    font: .system(size: 34, weight: .medium),
                    color: Color.white.opacity(0.80)
                )
                    .padding(.horizontal, 10)
                Text("Empty wallet")
                    .tracking(0.4)
                    .lineLimit(1)
                    .font(.system(size: 15))
                    .foregroundColor(Color.white.opacity(0.4))
                    .padding(.top, 1)
                    .padding(.bottom, 32)
                if renderUI {
                    loadingOverView
                } else {
                    loadingOverView
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 72)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(Color.sendTextFieldBG)
                    .frame(width: UIScreen.main.bounds.width - 38)
            )
            .padding(.bottom, 20)
            VStack(spacing: 10) {
                Button(action: { onTapBuyCrypto() }) {
                    emptyStateButton(title: "Buy Crypto",
                                     subtitle: "Purchase with debit card",
                                     image: Image.dollarSignCircle,
                                     imageSize: CGSize(width: 20, height: 20))
                }
                Button(action: { onTapReceiveFreeONE() }) {
                    emptyStateButton(title: "Receive free ONE!",
                                     subtitle: "Chat with us",
                                     image: Image.starBubble,
                                     imageSize: CGSize(width: 20, height: 21))
                }
                Button(action: { onTapReceive() }) {
                    emptyStateButton(title: "Receive",
                                     subtitle: "Deposit tokens to the wallet",
                                     image: Image.qrcode,
                                     imageSize: CGSize(width: 19, height: 19))
                }
            }
            .padding(.horizontal, 19)
        }
        .padding(.top, 15)
        .padding(.bottom, UIView.hasNotch ? UIView.safeAreaBottom : 35)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            renderUI.toggle()
        }
    }

    private func emptyStateButton(title: String, subtitle: String, image: Image, imageSize: CGSize) -> some View {
        return Rectangle()
            .foregroundColor(Color.walletDetailBottomBtn)
            .frame(height: 70)
            .overlay(
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: .infinity)
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color.xmarkBackground)
                        .overlay(
                            image
                                .resizable()
                                .foregroundColor(Color.white)
                                .frame(width: imageSize.width, height: imageSize.height)
                        )
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 17))
                            .foregroundColor(Color.white)
                        Text(subtitle)
                            .font(.system(size: 15))
                            .foregroundColor(Color.walletDetailDeposit)
                    }
                }
                    .padding(.leading, 10), alignment: .leading
            )
            .cornerRadius(12)
    }

    private var loadingOverView: some View {
        LottieView(name: "overViewLottie", loopMode: .constant(.loop), isAnimating: .constant(true))
            .scaledToFill()
            .aspectRatio(255 / 236, contentMode: .fit)
            .padding(.horizontal, 108)
            .offset(x: 2.5)
    }

    private func priceLabel() -> some View {
        var color = Color.positiveColor
        var totalColor = Color.positiveColor
        let values = viewModel.chartData.map { CGFloat($0.price) }
        let currentIndex = self.currentIndex ?? (values.count - 1)
        var dateString = ""
        var comparePercent = ""
        var comparePrice = ""
        var totalPercent = ""
        var totalPrice = ""
        var usdString = ""
        var decimalUSDStr = ""

        if !viewModel.chartData.isEmpty && !viewModel.loadingChartData {
            let lastTotalPrice = viewModel.chartData[viewModel.chartData.count - 1].price
            let selectPrice = viewModel.chartData[currentIndex].price
            let firstTotalPrice = viewModel.chartData[0].price

            totalPercent = Utils.formatCurrency((lastTotalPrice - firstTotalPrice) * 100 / firstTotalPrice)
            comparePercent = Utils.formatCurrency((selectPrice - firstTotalPrice) * 100 / firstTotalPrice)
            totalColor = lastTotalPrice - firstTotalPrice < 0 ? Color.negativeColor : Color.positiveColor
            color = selectPrice - firstTotalPrice < 0 ? Color.negativeColor : Color.positiveColor
            totalPrice = getMinusResult(
                stringValue: Utils.formatCurrency(lastTotalPrice - firstTotalPrice),
                firstValue: Utils.formatCurrency(lastTotalPrice),
                secondValue: Utils.formatCurrency(firstTotalPrice)
            )
            comparePrice = getMinusResult(
                stringValue: Utils.formatCurrency(selectPrice - firstTotalPrice),
                firstValue: Utils.formatCurrency(selectPrice),
                secondValue: Utils.formatCurrency(firstTotalPrice)
            )
            dateString = viewModel.timeDisplayOption.dateForrmatter().string(from: viewModel.chartData[currentIndex].time)

            if let oneUSD = formatAndSplitCurrency(
                viewModel.chartData[currentIndex != -1 ? currentIndex : viewModel.chartData.count - 1].price
            ).first { usdString = oneUSD } else { usdString = "0" }
            if formatAndSplitCurrency(
                viewModel.chartData[currentIndex != -1 ? currentIndex : viewModel.chartData.count - 1].price
            ).count > 1 {
                if let decimalSeparator = Locale.current.decimalSeparator {
                    decimalUSDStr = "\(decimalSeparator)\(formatAndSplitCurrency(viewModel.chartData[currentIndex != -1 ? currentIndex : viewModel.chartData.count - 1].price)[1])"
                } else {
                    decimalUSDStr = ".\(formatAndSplitCurrency(viewModel.chartData[currentIndex != -1 ? currentIndex : viewModel.chartData.count - 1].price)[1])"
                }
            } else {
                if let decimalSeparator = Locale.current.decimalSeparator {
                    decimalUSDStr = "\(decimalSeparator)00"
                } else {
                    decimalUSDStr = ".00"
                }
            }
        }

        return VStack(spacing: 3) {
            if showPlaceHolder {
                PlaceHolderBalanceView(font: .system(size: 34, weight: .medium))
                PlaceHolderBalanceView(font: .system(size: 14))
            } else {
                HStack(spacing: 0) {
                    Text("$\(usdString)") + Text(decimalUSDStr).foregroundColor(Color.white.opacity(0.87).opacity(0.6))
                }
                .font(.system(size: 34, weight: .medium))
                .lineLimit(1)
                .foregroundColor(Color.white.opacity(0.87))
                if tempIndex == nil {
                    Text("\(totalPercent)% ($\(totalPrice)) \(viewModel.compareUnit)")
                        .font(.system(size: 14))
                        .foregroundColor(totalColor.opacity(0.8))
                } else {
                    Text("\(comparePercent)% ($\(comparePrice)) \(dateString)")
                        .font(.system(size: 14))
                        .foregroundColor(color.opacity(0.8))
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showPlaceHolder)
    }

    private func plotBody() -> some View {
        let values = viewModel.chartData.map { CGFloat($0.price) }
        let currentIndex = self.currentIndex ?? (values.count - 1)
        // For value stick
        var dateString = viewModel.timeDisplayOption.dateForrmatter().string(from: viewModel.chartData[currentIndex].time)
        dateString = "$\(Utils.formatCurrency(viewModel.chartData[currentIndex].price)) - \(dateString)"
        DispatchQueue.main.async {
            colorUnit = values.first! < values.last! ? Color.positiveColor : Color.negativeColor
        }

        let config = RHLinePlotConfig.default.custom { cfg in
            cfg.valueStickColor = .gray
            cfg.minimumPressDurationToActivateInteraction = 0
        }

        return RHInteractiveLinePlot(
                values: values,
                occupyingRelativeWidth: 1,
                segmentSearchStrategy: .binarySearch,
                didSelectValueAtIndex: { ind in
                    self.currentIndex = ind
                    if self.tempIndex == nil && self.currentIndex != nil {
                        self.tempIndex = self.currentIndex
                        playHapticEvent()
                    } else if self.currentIndex == nil {
                        self.tempIndex = nil
                    }
                },
                valueStickLabel: { _ in
                    Text("\(dateString)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .padding(.leading, 5)
                })
                .environment(\.rhLinePlotConfig, config)
                .frame(height: 220)
                .foregroundColor(colorUnit)
    }
}

// MARK: - Methods
extension WalletOverviewView {
    private func getMinusResult(stringValue: String, firstValue: String, secondValue: String) -> String {
        if stringValue.contains("-") && firstValue == secondValue {
            return stringValue.replacingOccurrences(of: "-", with: "")
        }
        return stringValue
    }

    private func playHapticEvent() {
        try? HapticsGenerator.shared.playTransientEvent(
            withIntensity: 1.0,
            sharpness: 1.0
        )
    }

    private func formatCurrency(_ number: Double?) -> String {
        if let number = number {
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            if let formattedBalance = formatter.string(from: number as NSNumber) {
                return formattedBalance
            }
        }
        return "0.00"
    }

    private func formatAndSplitCurrency(_ number: Double?) -> [String] {
        if let number = number {
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            formatter.roundingMode = .down
            if let formattedCurrency = formatter.string(from: number as NSNumber) {
                let strings = formattedCurrency.components(separatedBy: Locale.current.decimalSeparator ?? "")
                return strings
            }
        }
        return []
    }

    private func onTapBuyCrypto() {
        present(NavigationView {
            DepositView(firstDeposit: firstDeposit).hideNavigationBar()
        }, presentationStyle: .automatic)
        if firstDeposit {
            firstDeposit = false
        }
    }

    private func onTapReceiveFreeONE() {

    }

    private func onTapReceive() {
        present(ProfileModal(wallet: WalletInfo.shared.currentWallet),
                presentationStyle: .fullScreen)
    }
}
