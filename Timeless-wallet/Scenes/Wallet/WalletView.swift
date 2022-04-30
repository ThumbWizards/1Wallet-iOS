//
//  WalletView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 26/10/21.
//

import SwiftUI
import UIKit
import TimelessWeather
import CollectionViewPagingLayout

struct WalletView {
    @ObservedObject private var tabbarViewModel = TabBarView.ViewModel.shared
    @ObservedObject private var viewModel = ViewModel.shared
    @ObservedObject private var walletInfo = WalletInfo.shared
    @State private var isShow = true
    @State private var currentWeather: CurrentWeatherOnlyForecast?
    @State private var forceRefresh = false
    @State private var activeCard: CarouselItem.ID? = 0
    @State private var now = Date()
    @State private var isShowingActionSheet = false
    @State private var walletPreview = Wallet.currentWallet
    @State private var indexAnimation = 3
    @AppStorage(ASSettings.Settings.selectedWeatherType.key)
    private var selectedWeather = ASSettings.Settings.selectedWeatherType.defaultValue
    @AppStorage(ASSettings.Settings.isShowingWeather.key)
    private var isShowingWeather = ASSettings.Settings.isShowingWeather.defaultValue
    @AppStorage(ASSettings.Settings.firstDeposit.key)
    private var firstDeposit = ASSettings.Settings.firstDeposit.defaultValue
    @AppStorage(ASSettings.Settings.showCurrencyWallet.key)
    private var showCurrencyWallet = ASSettings.Settings.showCurrencyWallet.defaultValue
    @AppStorage(ASSettings.Settings.walletBalance.key)
    private var walletBalance = ASSettings.Settings.walletBalance.defaultValue

    var timeLine: String {
        if hour >= 0 && hour < 12 {
            return "Good morning"
        } else if hour >= 12 && hour < 18 {
            return "Good afternoon"
        } else {
            return "Good evening"
        }
    }

    var options: ScaleTransformViewOptions {
        return ScaleTransformViewOptions(
            minScale: 0.9,
            maxScale: 1,
            translationRatio: CGPoint(x: 0.95, y: 0.8),
            maxTranslationRatio: CGPoint(x: 2, y: 0),
            scaleCurve: .linear,
            translationCurve: .linear
        )
    }

    let hour = Calendar.current.component(.hour, from: Date())
    @StateObject var UIState = UIStateModel(cardWidth: UIScreen.main.bounds.width - 65,
                                            cardHeight: UIScreen.main.bounds.height * 0.49 + 5,
                                            firstSpacing: 16,
                                            spacing: 20,
                                            hiddenCardScale: 0.9)

    let generator = UINotificationFeedbackGenerator()
}

extension WalletView {
    private var oneUSD: String {
        if let oneUSD = viewModel.formatAndSplitCurrency(walletInfo.totalOneUSD).first {
            return oneUSD
        }
        return "0"
    }

    private var decimalUSD: String {
        guard let decimalSeparator = Locale.current.decimalSeparator else {
            if viewModel.formatAndSplitCurrency(walletInfo.totalOneUSD).count > 1 {
                return ".\(viewModel.formatAndSplitCurrency(walletInfo.totalOneUSD).last ?? "")"
            }
            return ".00"
        }
        if viewModel.formatAndSplitCurrency(walletInfo.totalOneUSD).count > 1 {
            return "\(decimalSeparator)\(viewModel.formatAndSplitCurrency(walletInfo.totalOneUSD).last ?? "")"
        }
        return "\(decimalSeparator)00"
    }

    private var carouselWallets: [CarouselItem] {
        return walletInfo.allWallets.enumerated().compactMap {
            CarouselItem(id: $0, wallet: $1)
        } + [CarouselItem(id: -1, wallet: Wallet(address: "invalid"))]
    }

    private var date: String {
        ", \(Formatters.Date.MMMd.string(from: Date()))"
    }

    // swiftlint:disable line_length
    private var showPlaceHolder: Bool {
        for item in walletInfo.allWallets where (item.detailViewModel.overviewModel.totalUSDAmount == nil || item.detailViewModel.overviewModel.totalONEAmount == nil) {
            return true
        }
        return false
    }
}

extension WalletView: View {
    var body: some View {
        ZStack(alignment: .top) {
            Color.primaryBackground
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 0) {
                        headerView
                        infoWalletView
                    }
                    HStack {
                        Spacer()
                        WalletSelectorView()
                    }
                    .padding(.trailing, 28)
                    .padding(.top, 6)
                }
                .padding(.bottom, 18)
                buttonView
                    .padding(.bottom, 25)
                let carouselWallets = carouselWallets
                ScalePageView(carouselWallets, selection: $activeCard) { item in
                    SnapCarouselItem(id: item.id) {
                        if item.id == -1 {
                            gotAWalletCardView
                        } else {
                            WalletCardView(item: item, overviewModel: item.wallet.detailViewModel.overviewModel)
                            // swiftlint:disable line_length
                                .previewContextMenu(preview: WalletPreviewMenu(wallet: item.wallet,
                                                                               overviewModel: item.wallet.detailViewModel.overviewModel),
                                                    actions: [.copy, .showQRCode, .editAvatar, .disconnect], // .rename
                                                    onActionBlock: { actionType in
                                    switch actionType {
                                    case .copy:
                                        showSnackBar(.coppiedAddress)
                                        UIPasteboard.general.string = item.wallet.address.convertToWalletAddress()
                                    case .showQRCode:
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            present(ProfileModal(wallet: item.wallet),
                                                    presentationStyle: .fullScreen)
                                        }
//                                    case .rename:
//                                        showSnackBar(.errorMsg(text: "Not available on alpha release"))
                                    case .editAvatar:
                                        isShowingActionSheet = true
                                        walletPreview = item.wallet
                                    case .disconnect:
                                        showSnackBar(.errorMsg(text: "Not available on alpha release"))
                                        // TODO:- Disable for demo
                                        /*showConfirmation(.disconnectAndRemove(wallet: item.wallet))*/
                                    default: break
                                    }
                                },
                                                    detailAction: {
                                    present(WalletDetailView(wallet: item.wallet),
                                            presentationStyle: .automatic)
                                })
                                                    .id(item.wallet.uniqueKey)
                        }
                    }
                    .environmentObject(self.UIState)
                }
                .collectionView(\.contentInset, UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0))
                .options(options)
                .pagePadding(
                    horizontal: .absolute(30)
                )
                .scrollToSelectedPage(false)
                .frame(height: UIState.cardHeight)
                .padding(.bottom, 10)
                .opacity(tabbarViewModel.changeAvatarTransition ? 0 : 1)
                HStack {
                    Spacer()
                    ForEach(carouselWallets.indices, id: \.self) { index in
                        Rectangle()
                            .frame(width: activeCard == index ? 18 : 6, height: 6)
                            .cornerRadius(.infinity)
                            .foregroundColor(activeCard == index ? Color.carouselRectangle : Color.carouselCircle)
                            .animation(.easeInOut(duration: 0.2), value: activeCard)
                    }
                    Spacer()
                }
            }
            .padding(.top, UIView.safeAreaTop + 11)
        }
        .modifier(EditAvatarModifier(
            isShowingActionSheet: $isShowingActionSheet,
            wallet: walletPreview ?? Wallet(address: walletPreview?.address ?? ""),
            isQRScreen: false
        ))
        .onChange(of: self.activeCard, perform: { _ in
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
        })
        .onReceive(walletInfo.$didChangedCurrentWallet, perform: { _ in
            activeCard = 0
        })
        .onChange(of: walletInfo.isShowingAnimation) { value in
            if value {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    indexAnimation = 0
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    indexAnimation = 1
                }
            }
        }
        .onChange(of: indexAnimation) { value in
            if value > 0 && value < 3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    indexAnimation += 1
                }
            }
        }
        .overlay(forceRefresh ? EmptyView() : EmptyView())
        .onReceive(UserInfoService.shared.location.$state, perform: { _ in
            UserWeatherService.shared.fetchCurrentForecast(location: viewModel.userWeatherLocation) {
                forceRefresh.toggle()
            }
        })
        .onChange(of: isShowingWeather) { value in
            if value {
                UserInfoService.shared.fetchCurrentLocation {
                    viewModel.fetchCurrentWeatherForecast {
                        forceRefresh.toggle()
                    }
                }
            }
        }
        .nowTimer(resolution: 20.0, now: $now)
        .onChange(of: now) { _ in
            walletInfo.refreshWalletData()
        }
        .onAppear {
            walletInfo.refreshWalletData()
            TokenInfo.shared.getListToken()
            if isShowingWeather {
                UserInfoService.shared.fetchCurrentLocation {
                    viewModel.fetchCurrentWeatherForecast {
                        forceRefresh.toggle()
                    }
                }
            }
            walletInfo.generateWalletQRCode()
        }
    }
}

extension WalletView {
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    Text(Date.todaysDayText.uppercased())
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.white)
                    if isShowingWeather {
                        ZStack(alignment: .leading) {
                            if selectedWeather == WeatherType.Celsius.rawValue {
                                WeatherIndicatorView(weatherService: .init(temperatureUnit: selectedWeather,
                                                                           currentWeatherForecast: viewModel.userWeatherService
                                                                            .latestCurrentForecast))
                            } else {
                                WeatherIndicatorView(weatherService: .init(temperatureUnit: selectedWeather,
                                                                           currentWeatherForecast: viewModel.userWeatherService
                                                                            .latestCurrentForecast))
                            }
                        }
                        .padding(.leading, 5)
                    } else {
                        Text(date.uppercased())
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.white)
                    }
                }
                .height(24)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            .background(.almostClear)
            .onTapGesture {
                if isShowingWeather {
                    withAnimation {
                        Utils.playHapticEvent()
                        if selectedWeather == WeatherType.Celsius.rawValue {
                            selectedWeather = WeatherType.Fahrenheit.rawValue
                        } else {
                            selectedWeather = WeatherType.Celsius.rawValue
                        }
                    }
                }
            }
            Spacer()
        }
    }

    private var infoWalletView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                if showPlaceHolder {
                    PlaceHolderBalanceView()
                } else {
                    SwapCurrencyView(
                        usdStr: viewModel.getStrBeforeDecimal(walletInfo.totalOneUSD),
                        decimalUSD: viewModel.getStrAfterDecimal(walletInfo.totalOneUSD),
                        oneStr: viewModel.getStrBeforeDecimal(walletInfo.totalOne),
                        decimalONE: viewModel.getStrAfterDecimal(walletInfo.totalOne, isThreeDigit: true),
                        type1: "$",
                        type2: "ONE",
                        isSpacing1: false,
                        isSpacing2: true,
                        valueAfterType: true,
                        font: .system(size: 32)
                    )
                }
            }
            .animation(.easeInOut(duration: 0.2), value: showPlaceHolder)
            .padding(.top, 7)
            .padding(.horizontal, 16)
            .padding(.bottom, 3)
            .background(Color.almostClear)
            .onTapGesture {
                withAnimation {
                    let generator = UISelectionFeedbackGenerator()
                    generator.selectionChanged()
                    walletBalance.toggle()
                }
            }
            HStack(spacing: 4) {
                Text("PORTFOLIO BALANCE").tracking(0.6).opacity(0.6)
                if showCurrencyWallet {
                    Image.eyeFill
                } else {
                    Image.eyeSlashFill
                }
            }
            .foregroundColor(Color.white)
            .font(.system(size: 14, weight: .regular))
            .padding(.top, 3)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .background(Color.almostClear)
            .onTapGesture {
                withAnimation {
                    Utils.playHapticEvent()
                    showCurrencyWallet.toggle()
                }
            }
        }
        .disabled(showPlaceHolder)
    }

    private var buttonView: some View {
        ZStack {
            HStack(spacing: 0) {
                Button {
                    present(NavigationView {
                        DepositView(firstDeposit: firstDeposit).hideNavigationBar()
                    }, presentationStyle: .automatic)
                    if firstDeposit {
                        firstDeposit = false
                    }
                } label: {
                    VStack {
                        Image.creditcard
                            .foregroundColor(Color.white)
                            .frame(width: 36, height: 36)
                            .background(Color.xmarkBackground.cornerRadius(.infinity))
                        Text("Buy")
                            .tracking(0.4)
                            .fixedSize(horizontal: true, vertical: false)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.white)
                    }
                }
                .padding(.leading, 18)
                .opacity(indexAnimation >= 1 ? 1 : 0)
                .offset(x: indexAnimation >= 1 ? 0 : -8)
                Spacer()
                Button {
                    Utils.scanWallet { strScanned in
                        showConfirmation(.qrOptions(result: strScanned))
                    }
                } label: {
                    VStack {
                        Image.qrcodeViewFinder
                            .foregroundColor(Color.white)
                            .frame(width: 36, height: 36)
                            .background(Color.xmarkBackground.cornerRadius(.infinity))
                        Text("Scan QR")
                            .tracking(0.4)
                            .fixedSize(horizontal: true, vertical: false)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.white)
                    }
                }
                .opacity(indexAnimation >= 2 ? 1 : 0)
                .offset(x: indexAnimation >= 2 ? 6 : -2)
                Spacer()
                Button {
                    showConfirmation(.exchange)
                } label: {
                    VStack {
                        Image.arrowTriangleSwap
                            .foregroundColor(Color.white)
                            .frame(width: 36, height: 36)
                            .background(Color.xmarkBackground.cornerRadius(.infinity))
                        Text("Exchange")
                            .tracking(0.4)
                            .fixedSize(horizontal: true, vertical: false)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.white)
                    }
                }
                .padding(.trailing, 16)
                .opacity(indexAnimation >= 3 ? 1 : 0)
                .offset(x: indexAnimation >= 3 ? 0 : -8)
            }
            .animation(.easeInOut(duration: 0.5), value: indexAnimation)
        }
        .frame(width: UIState.cardWidth)
        .padding(.leading, UIState.firstSpacing)
    }

    private var gotAWalletCardView: some View {
        ZStack {
            Color.searchBackground
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        showConfirmation(.addNewWallet)
                    }, label: {
                        Image.plusCircleFillIcon
                            .resizable()
                            .frame(width: 28, height: 28)
                            .padding(.bottom, 18)
                            .foregroundColor(Color.white)
                    })
                    Text("Got a wallet?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color.white)
                        .padding(.bottom, 11)
                    Text("Track or import Harmony Wallets")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color.white60)
                }
                .padding(.leading, 26)
                Spacer()
                HStack {
                    Spacer()
                    Image.scanIcon
                        .padding(12)
                        .background(Color.almostClear)
                        .onTapGesture {
                            let view = QRCodeReaderView()
                            view.screenType = .moneyORAddToContact
                            if let topVc = UIApplication.shared.getTopViewController() {
                                view.modalPresentationStyle = .fullScreen
                                view.onScanSuccess = { qrString in
                                    onScanSuccess(strScanned: qrString)
                                }
                                topVc.present(view, animated: true)
                            }
                        }
                    Spacer()
                }
                Spacer()
                HStack {
                    Image.eyeSquareFill
                    Text("Follow any wallet")
                        .font(.system(size: 16, weight: .regular))
                    Spacer()
                    Image.chevronForward
                }
                .foregroundColor(Color.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 10)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white40, lineWidth: 1))
                .background(Color.almostClear)
                .padding(.horizontal, 13)
                .opacity(0.2)
                .onTapGesture {
                    showSnackBar(.errorMsg(text: "Not available on alpha release"))
                }
            }
            .padding(.bottom, 22)
            .padding(.top, 23)
            .opacity(tabbarViewModel.changeAvatarTransition ? 0 : 1)
        }
    }
}

// MARK: - Methods
extension WalletView {
    private func onScanSuccess(strScanned: String) {
        if let url = URL(string: strScanned), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

struct PlaceHolderBalanceView: View {
    @State private var isShowed = false
    var font = Font.system(size: 32)
    var cornerRadius: CGFloat = 10
    var placeholderText = "ONE 00"

    var body: some View {
        Text(placeholderText)
            .foregroundColor(Color.clear)
            .font(font)
            .background(
                Color.white.opacity(0.05)
                    .overlay(LoadingShimmerView(isShowed: isShowed, color: Color.placeHolderBalanceBG.opacity(0.9)))
                    .cornerRadius(cornerRadius)
            )
            .onAppear {
                withAnimation(Animation.default.speed(0.15).delay(0).repeatForever(autoreverses: false)) {
                    isShowed.toggle()
                }
            }
    }
}

struct LoadingShimmerView: View {
    var isShowed: Bool
    var color = Color.placeHolderBalanceBG.opacity(0.3)
    var cornerRadius: CGFloat = 17
    private let originX = UIScreen.main.bounds.height - 80

    var body: some View {
        color
            .frame(
                width: UIScreen.main.bounds.height * 1.5,
                height: UIScreen.main.bounds.height
            )
            .cornerRadius(cornerRadius)
            .mask(
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: .init(colors: [.clear, color, .clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .rotationEffect(.init(degrees: 110))
                    .offset(x: self.isShowed ? originX : -originX)
            )
    }
}
