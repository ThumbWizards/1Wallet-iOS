//
//  SendPaymentView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 26/11/21.
//

import SwiftUI
import Combine
import web3swift

struct SendPaymentView: View {
    // MARK: - Input
    @StateObject var viewModel: ViewModel
    var recipientName = ""

    // MARK: - Properties
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @AppStorage(ASSettings.Setting.requireForTransaction.key)
    private var requireForTransaction = ASSettings.Setting.requireForTransaction.defaultValue
    @AppStorage(ASSettings.Settings.lockMethod.key)
    private var lockMethod = ASSettings.Settings.lockMethod.defaultValue
    @State private var weeklyLimit: CGFloat = 1000
    @State private var shakeAnimation = CGFloat.zero
    @State private var scaleAnimation: CGFloat = 1
    @State private var currencyValue: CGFloat = 0
    @State private var currencyString = "0"
    @State private var isCurrencyAdded = false
    @State private var selectedPaymentMode = 0
    @State private var toggleWalletScanned = false

    var gridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    private let generator = UINotificationFeedbackGenerator()
    var onDismiss: (() -> Void)?
    private var fltCurrency: Float {
        return (currencyDisplay as NSString).floatValue
    }
    private var exchangeCurrency: String {
        Utils.formatBalance(viewModel.rateUSDGot)
    }
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
    private var appLockEnable: Bool {
        Lock.shared.passcode != nil && lockMethod != ASSettings.LockMethod.none.rawValue && requireForTransaction
    }
}

// MARK: - Body view
extension SendPaymentView {
    var body: some View {
        ZStack(alignment: .top) {
            Color.sheetBG
            VStack(spacing: 0) {
                contentView
                Spacer(minLength: 0)
                footerView
            }
        }
        .ignoresSafeArea()
        .onAppear {
            viewModel.recipientName = recipientName
        }
        .onChange(of: currencyString) { value in
            currencyValue = CGFloat((value as NSString).doubleValue)
            viewModel.currencyValue = currencyValue
        }
        .onReceive(NotificationCenter.default.publisher(for: .dismissSendOneViews)) { _ in
            onTapClose()
        }
        .onReceive(NotificationCenter.default.publisher(for: .dismissRedPacketViews)) { _ in
            onTapClose()
        }
    }
}

// MARK: - Subview
extension SendPaymentView {
    private var contentView: some View {
        VStack(spacing: 0) {
            header
            currency
            if viewModel.isDirectSend {
                addressView
            } else {
                selectedUser
            }
            if isCurrencyAdded {
                paymentType
            } else {
                numberPad
            }
        }
    }

    private var header: some View {
        ZStack {
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
            if !viewModel.isRedPacket {
                HStack(spacing: 4) {
                    if !viewModel.isDirectSend {
                        RemoteImage(url: viewModel.sendOneWalletData?.recipientImageUrl,
                                    loading: .avatar,
                                    failure: .avatar)
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                    }
                    Text(viewModel.isDirectSend ? "Send" : viewModel.sendOneWalletData?.recipientName ?? "-")
                        .foregroundColor(Color.white.opacity(0.87))
                        .font(.system(size: 18, weight: .bold))
                }
            }
        }
        .padding(.top, 30.5)
        .padding(.bottom, UIView.hasNotch ? 55 : 20)
    }

    private var currency: some View {
        VStack(spacing: -1) {
            Text("\(currencyDisplay)")
                .tracking(1.8)
                .lineLimit(1)
                .font(.system(size: 55, weight: .bold))
                .foregroundColor(Color.timelessBlue)
                .padding(.horizontal, 10)
                .offset(x: shakeAnimation)
            Text(currencyValue == 0 ? " " : "~\(exchangeCurrency) USD")
                .tracking(0.7)
                .lineLimit(1)
                .font(.system(size: 18))
                .foregroundColor(Color.exchangeCurrency)
        }
        .padding(.bottom, UIView.hasNotch ? 52 : 20)
    }

    private var addressView: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text("Recipient address")
                .tracking(-0.5)
                .font(.system(size: 18))
                .foregroundColor(Color.white.opacity(0.6))
                .offset(x: -1)
            RoundedRectangle(cornerRadius: 6)
                .foregroundColor(Color.scannedPaymentAddressBG)
                .overlay(
                    HStack(spacing: 0) {
                        Text(viewModel.scanAddress.trimStringByCount(count: 10))
                            .tracking(-0.1)
                            .font(.system(size: 16))
                            .foregroundColor(Color.white.opacity(0.3))
                            .padding(.leading, 20)
                            .offset(y: 0.5)
                            .id(viewModel.scanAddress)
                        Spacer(minLength: 0)
                        Button(action: { onTapQRScan() }) {
                            Color.almostClear
                                .frame(width: 46)
                                .overlay(
                                    Image.qrcode
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                        .foregroundColor(Color.white.opacity(0.87))
                                )
                        }
                    }
                )
                .frame(height: 41.5)
        }
        .padding(.top, -3)
        .padding(.horizontal, 16)
        .padding(.bottom, 33)
    }

    private var selectedUser: some View {
        VStack {
            Text(viewModel.userTitle)
                .font(.sfProDisplayRegular(size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.paymentTitleFont.opacity(0.6))
            HStack {
                if viewModel.isRedPacket {
                    WalletAvatar(wallet: WalletInfo.shared.currentWallet, frame: CGSize(width: 45, height: 45))
                        .padding(.leading, 16)
                } else {
                    RemoteImage(
                        url: viewModel.sendOneWalletData?.recipientImageUrl,
                        loading: .avatar,
                        failure: .avatar)
                        .frame(width: 45, height: 45)
                        .clipShape(Circle())
                        .padding(.leading, 16)
                }
                HStack(spacing: 0) {
                    VStack(spacing: 3) {
                        Text(viewModel.userName)
                            .font(.sfProText(size: 15))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(viewModel.walletAddress)
                            .font(.sfProText(size: 12))
                            .foregroundColor(Color.paymentTitleFont.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Image.infoCircle
                        .font(.system(size: 18, weight: .light))
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.timelessBlue)
                        .padding(.trailing, 21)
                }
            }
            .frame(height: 70)
            .frame(maxWidth: .infinity)
            .background(Color.paymentCard)
            .cornerRadius(8)
        }
        .padding(.horizontal, 17)
        .padding(.bottom, 17)
    }

    private var paymentType: some View {
        VStack {
            LazyVGrid(columns: gridItemLayout) {
                ForEach(enumerating: viewModel.paymentTypes, id: \.self) { index, type  in
                    ZStack(alignment: .topLeading) {
                        if index == selectedPaymentMode {
                            Color.timelessBlue.opacity(0.2)
                        } else {
                            Color.white.opacity(0.2)
                        }
                        VStack {
                            Text(type)
                                .font(.sfProText(size: 14))
                                .foregroundColor(Color.white)
                                .padding(.top, 10)
                                .padding(.leading, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Image.redPacket
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .opacity(index == 4 ? 1 : 0)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.bottom, 10)
                                .padding(.trailing, 10)
                        }
                    }
                    .onTapGesture {
                        selectedPaymentMode = index
                    }
                    .cornerRadius(4)
                    .frame(width: UIView.hasNotch ? 105 : 80, height: UIView.hasNotch ? 105 : 80)
                    .padding(5)
                }
            }
        }
        .padding(17)
    }

    private var numberPad: some View {
        VStack(spacing: 0) {
            horizontalNumberPad("1", "2", "3")
            horizontalNumberPad("4", "5", "6")
            horizontalNumberPad("7", "8", "9")
            horizontalNumberPad(".", "0", "Del")
            Spacer()
        }
        .padding(.horizontal, 17)
    }

    private var footerView: some View {
        VStack {
            Button(action: { onTapNext() }) {
                Text(isCurrencyAdded || viewModel.isDirectSend ? "Review" : "Next")
                    .font(.system(size: 17))
                    .foregroundColor(Color.white.opacity(0.87))
                    .frame(maxWidth: .infinity)
                    .frame(height: viewModel.isDirectSend ? 41 : 40)
                    .background(currencyValue == 0 ? Color.confirmationSheetCancelBG : Color.timelessBlue)
                    .clipShape(Capsule())
                    .contentShape(Rectangle())
            }
            .opacity(currencyValue == 0 ? 0.3 : 1)
            .disabled(currencyValue == 0)
            .padding(.horizontal, viewModel.isDirectSend ? 43 : 30)

            Text("You’ll be able to review before confirming the transaction")
                .font(.system(size: 12))
                .foregroundColor(Color.paymentTitleFont.opacity(0.4))
                .opacity(isCurrencyAdded ? 1 : 0)
        }
        .padding(.bottom, UIView.hasNotch ? UIView.safeAreaBottom + (viewModel.isDirectSend ? 4.5 : 0): 35)
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
            .frame(height: UIView.hasNotch ? 63 : 43)
            .overlay(
                ZStack {
                    if value == "Del" {
                        Image.deleteBackward
                            .resizable()
                            .font(.system(size: 21))
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
}

// MARK: - Methods
extension SendPaymentView {
    private func onTapClose() {
        presentationMode.wrappedValue.dismiss()
        onDismiss?()
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
        default : break
        }
    }

    private func appendValue(_ value: String) {
        var tempCurrency = currencyString
        tempCurrency.append(value)
        checkCurrencyLimit(tempCurrency)
    }

    private func checkCurrencyLimit(_ value: String) {
        if CGFloat((value as NSString).doubleValue) > weeklyLimit {
            showExceedsLimit()
        } else {
            currencyString = value
            playHapticEvent()
        }
    }

    private func showExceedsLimit() {
        withAnimation(Animation.spring(response: 0.15, dampingFraction: 0.15, blendDuration: 0.15)) {
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

    private func onTapQRScan() {
        Utils.scanWallet { strScanned in
            changeScannedWallet(strScanned)
        }
    }

    private func changeScannedWallet(_ strScanned: String) {
        if strScanned != viewModel.scanAddress {
            viewModel.recipientAddress = EthereumAddress(strScanned.convertBech32ToEthereum())
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.scanAddress = strScanned
            }
        }
    }

    private func onTapNext() {
        guard currencyValue != 0, viewModel.checkInputAmount(amount: Double(currencyValue)) else { return }
        let fractionDigits = Decimal(string: "\(currencyValue)")?.significantFractionalDecimalDigits ?? 0
        withAnimation(.linear) {
            if viewModel.isDirectSend {
                let transferAmount = Float(currencyValue)
                let address = EthereumAddress(viewModel.recipientAddress?.address ?? "")
                onTapClose()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showConfirmation(.sendOneConfirmation(
                        transferOne: TransferOne(destinationAddress: address,
                                                 scannedAddress: viewModel.scanAddress,
                                                 transferAmount: transferAmount,
                                                 fractionDigits: fractionDigits,
                                                 strFormattedAmount: currencyDisplay,
                                                 recipientName: viewModel.recipientName),
                        screenType: .send,
                        channel: nil
                    ), interactiveHide: false)
                }
            } else if viewModel.isRedPacket {
                viewModel.redPacket?.amount = Float(currencyValue)
                viewModel.redPacket?.strFormattedAmount = currencyDisplay
                viewModel.redPacket?.fractionDigits = fractionDigits
                guard let redPacket = viewModel.redPacket else { return }
                present(RedPacketView(viewModel: .init(redPacket: redPacket)),
                        presentationStyle: .automatic)
            } else {
                viewModel.sendOneWalletData?.transferAmount = Float(currencyValue)
                viewModel.sendOneWalletData?.strFormattedAmount = currencyDisplay
                viewModel.sendOneWalletData?.fractionDigits = fractionDigits
                guard let oneWallet = viewModel.sendOneWalletData else { return }
                if isCurrencyAdded {
                    showConfirmation(.sendOneConfirmation(walletData: oneWallet, screenType: .send, channel: nil),
                                     interactiveHide: false)
                } else {
                    isCurrencyAdded.toggle()
                }
            }
        }
    }
}
