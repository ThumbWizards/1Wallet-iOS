//
//  AddFundsView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 18/11/2021.
//

import SwiftUI

struct AddFundsView: View {
    @ObservedObject private var viewModel = ViewModel.shared
    // MARK: - Input Parameters
    var inputCurrency = 50.0
    var inputProvider = ProviderType.simplex

    // MARK: - Properties
    @State private var weeklyLimit: Double = 1000
    @State private var selectedProvider = ProviderType.simplex
    @State private var shakeAnimation = CGFloat.zero
    @State private var scaleAnimation: CGFloat = 1
    @State private var subtitleColor = Color.addFundsSubtitle
    @State private var currencyValue: Double = 50
    @State private var currencyString = "50"
    @State private var firstAppear = true
    @StateObject private var walletInfo = WalletInfo.shared

    private let generator = UINotificationFeedbackGenerator()
    private var currencyDisplay: String {
        if currencyString == "0" {
            return "0"
        } else {
            var result = currencyString
            if result.components(separatedBy: ".")[0].count == 4 {
                if Locale.current.decimalSeparator == "." {
                    result.insert(",", at: result.index(after: result.startIndex))
                } else {
                    result = result.replacingOccurrences(of: ".", with: ",")
                    result.insert(".", at: result.index(after: result.startIndex))
                }
            } else {
                if Locale.current.decimalSeparator == "," {
                    result = result.replacingOccurrences(of: ".", with: ",")
                }
            }
            return result
        }
    }
    var providerList = [ProviderType.simplex,
                        ProviderType.transak,
                        ProviderType.ramp,
                        ProviderType.wyre]
}

// MARK: - Body view
extension AddFundsView {
    var body: some View {
        ZStack(alignment: .top) {
            Color.sheetBG
            VStack(spacing: 0) {
                header
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        currency
                        provider
                        numberPad
                        applePay
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .loadingOverlay(isShowing: viewModel.isLoading)
        .onChange(of: currencyString) { value in
            currencyValue = (value as NSString).doubleValue
            viewModel.getNewQuote(amount: currencyValue, uid: viewModel.uid)
        }
        .onAppear { onAppearHandler() }
    }
}

// MARK: - Subview
extension AddFundsView {
    private var header: some View {
        ZStack {
            VStack(spacing: 4) {
                Text("Add Funds")
                    .tracking(0)
                    .foregroundColor(Color.white87)
                    .font(.system(size: 18, weight: .semibold))
                Text("$\(Int(weeklyLimit)) Weekly Limit")
                    .tracking(0.2)
                    .foregroundColor(subtitleColor)
                    .font(.system(size: 12))
                    .scaleEffect(scaleAnimation)
            }
            HStack {
                Spacer()
                WalletAvatar(wallet: walletInfo.currentWallet, frame: CGSize(width: 30, height: 30))
                .onTapGesture {
                    showConfirmation(.avatar())
                }
            }
            .padding(.trailing, 18.5)
            .offset(y: -1)
            HStack {
                Button(action: { onTapClose() }) {
                    Image.closeBackup
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 30)
                }
                .padding(.leading, 18.5)
                .offset(y: -1)
                Spacer()
            }
        }
        .padding(.top, 26.5)
        .padding(.bottom, 10)
    }

    private var currency: some View {
        VStack(spacing: 0) {
            Text("$\(currencyDisplay)")
                .tracking(1.6)
                .lineLimit(1)
                .font(.system(size: 55, weight: .bold))
                .foregroundColor(Color.timelessBlue)
                .padding(.horizontal, 10)
                .offset(x: shakeAnimation)
            ZStack {
                if viewModel.isSwaping {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    if currencyValue < 50 {
                        Text("Minimum amount is $50")
                            .tracking(0.7)
                            .lineLimit(1)
                            .font(.system(size: 12))
                            .foregroundColor(Color.timelessRed)
                    } else {
                        Text("~\(viewModel.rateOne) ONE")
                            .tracking(0.7)
                            .lineLimit(1)
                            .font(.system(size: 18))
                            .foregroundColor(Color.exchangeCurrency)
                    }
                }
            }
            .height(21)
        }
        .padding(.top, 38)
        .padding(.bottom, 51)
    }

    private var provider: some View {
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
        .disabled(providerList.count == 1)
        .padding(.bottom, 38)
    }

    private var numberPad: some View {
        VStack(spacing: 0) {
            horizontalNumberPad("1", "2", "3")
            horizontalNumberPad("4", "5", "6")
            horizontalNumberPad("7", "8", "9")
            horizontalNumberPad(".", "0", "Del")
        }
        .padding(.horizontal, 17)
    }

    private func horizontalNumberPad(_ firstBtn: String, _ secondBtn: String, _ thirdBtn: String) -> some View {
        HStack(spacing: 0) {
            padButton(firstBtn)
            padButton(secondBtn)
            padButton(thirdBtn)
        }
    }

    private func padButton(_ value: String) -> some View {
        Button(action: { onTapPadButton(value) }) {
            Rectangle()
            .foregroundColor(Color.almostClear)
            .frame(height: 63)
            .overlay(
                ZStack {
                    if value == "Del" {
                        Image.deleteBackward
                            .resizable()
                            .font(.system(size: 21, weight: .regular))
                            .foregroundColor(Color.white)
                            .frame(width: 21, height: 18)
                    } else {
                        Text(value == "." ? String(Locale.current.decimalSeparator ?? ""): value)
                            .font(.system(size: 21, weight: .semibold))
                            .foregroundColor(Color.white)
                    }
                }
            )
        }
        .buttonStyle(ButtonTapScaleUp())
    }

    private var applePay: some View {
        VStack(spacing: 0) {
            ZStack {
                if viewModel.isSwaping {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    Text("1 USD ~ \(viewModel.convertToOneONE) ONE")
                        .tracking(0.6)
                        .font(.system(size: 14))
                        .padding(.top, 2)
                        .foregroundColor(Color.white)
                        .opacity(0.6)
                }
            }
            .height(24)
            .padding(.bottom, 17)
            Button(action: { onTapApplePay() }) {
                RoundedRectangle(cornerRadius: 14)
                    .frame(height: 48)
                    .padding(.horizontal, 24)
                    .foregroundColor(Color.black)
                    .overlay(
                        Text(selectedProvider == .simplex ? "Buy" : "Pay")
                            .foregroundColor(Color.white)
                            .font(.system(size: 23, weight: .semibold))
                    )
            }
            .opacity(currencyValue < 50 ? 0.2 : 1)
            .disabled(currencyValue < 50)
            .animation(.easeInOut, value: currencyValue)
            .padding(.bottom, 10)
            HStack(spacing: 0) {
                Text("Processed by a Third Party service provider ")
                    .font(.system(size: 13))
                    .foregroundColor(Color.applePaySubtitle)
                Image.infoCircleFill
                    .resizable()
                    .frame(width: 13, height: 13)
                    .foregroundColor(Color.applePaySubtitle)
                    .font(.system(size: 13))
            }
            .opacity(currencyValue < 50 ? 0.2 : 1)
            .animation(.easeInOut, value: currencyValue)
            .padding(.bottom, 10)
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Methods
extension AddFundsView {
    private func onAppearHandler() {
        if firstAppear {
            firstAppear = false
            currencyValue = inputCurrency
            currencyString = inputCurrency > 0 ? "\(Int(currencyValue))" : "0"
            selectedProvider = inputProvider
            viewModel.uid = UUID().uuidString
            viewModel.getNewQuote(amount: currencyValue, uid: viewModel.uid)
        }
    }

    private func onTapClose() { dismiss() }

    private func onTapProvider() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            subtitleColor = Color.addFundsSubtitle
        }
        push(ProviderView(currencyValue: $currencyValue,
                          selectedProvider: $selectedProvider,
                          providerList: providerList))
    }

    private func onTapPadButton(_ value: String) {
        switch value {
        case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" :
            if currencyString != "0" {
                if currencyString.contains(".") {
                    if currencyString.components(separatedBy: ".")[1].count < 4 {
                        appendValue(value)
                    } else {
                        shakeAnimate()
                    }
                } else {
                    appendValue(value)
                }
            } else {
                if value == "0" {
                    shakeAnimate()
                } else {
                    currencyString = value
                    playHapticEvent()
                }
            }
        case ".":
            if currencyString == String(format: "%.0f", weeklyLimit) {
                showExceedsLimit()
            } else if !currencyString.contains(".") {
                currencyString.append(value)
                subtitleColor = Color.addFundsSubtitle
                playHapticEvent()
            } else {
                shakeAnimate()
            }
        case "Del":
            if currencyString == "0" {
                shakeAnimate()
            } else {
                currencyString = String(currencyString.dropLast())
                if currencyString.isEmpty {
                    currencyString = "0"
                }
                playHapticEvent()
            }
            subtitleColor = Color.addFundsSubtitle
        default : break
        }
    }

    private func appendValue(_ value: String) {
        var tempCurrency = currencyString
        tempCurrency.append(value)
        checkCurrencyLimit(tempCurrency)
    }

    private func checkCurrencyLimit(_ value: String) {
        if (value as NSString).doubleValue > weeklyLimit {
            showExceedsLimit()
        } else {
            currencyString = value
            playHapticEvent()
        }
    }

    private func showExceedsLimit() {
        withAnimation(Animation.spring(response: 0.15, dampingFraction: 0.15, blendDuration: 0.15)) {
            subtitleColor = Color.timelessRed
            scaleAnimation = 1.1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                scaleAnimation = 1
            }
        }
        shakeAnimate()
    }

    private func shakeAnimate() {
        for indexShake in 0 ..< 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.07 * Double(indexShake)) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    shakeAnimation = 10 - (20 * (indexShake == 3 ? 0.5 : (indexShake + 3).isMultiple(of: 2) ? 1 : 0))
                }
            }
        }
        generator.notificationOccurred(.success)
    }

    private func playHapticEvent() {
        try? HapticsGenerator.shared.playTransientEvent(
            withIntensity: 1.0,
            sharpness: 1.0
        )
    }

    private func onTapApplePay() {
        viewModel.checkout(amount: currencyValue) { url in
            present(CheckoutWebView(url: url)
                        .ignoresSafeArea()
            )
        }
    }
}
