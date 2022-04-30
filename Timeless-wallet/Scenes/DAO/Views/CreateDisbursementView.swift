//
//  CreateDisbursementView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 02/02/22.
//

import SwiftUI
import Combine
import web3swift

struct CreateDisbursementView: View {
    // MARK: - Properties
    @State private var isSliderUpdate = false
    @State private var textFieldCurrency: UITextField?
    @State private var textViewPurpose: UITextView?
    @State private var textFieldAddress: UITextField?
    @State private var shakeAnimation = CGFloat.zero
    @State private var keyboardHeight = CGFloat.zero
    @State private var paddingKeyboard = CGFloat.zero
    @State private var reviewBtnPaddingBottom: CGFloat = 50
    let generator = UINotificationFeedbackGenerator()
    var currencyLimit: CGFloat = 100_000_000
    private var isValidAddress: Bool {
        viewModel.recipientWalletAddress.isOneWalletAddress &&
        EthereumAddress(viewModel.recipientWalletAddress.convertBech32ToEthereum()) != nil
    }
    @StateObject var viewModel: ViewModel
    private var exchangeCurrency: String {
        Utils.formatBalance(viewModel.rateUSDGot)
    }

    enum scrollType {
        case walletAddress
        case purpose
        case none
    }
}

// MARK: - Body view
extension CreateDisbursementView {
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.sheetBG
            VStack(spacing: 7) {
                header
                    .padding(.top, 20)
                BaseScrollView(
                    header: { EmptyView() },
                    content: {
                        VStack(spacing: 7) {
                            currencyView
                            selectedUser
                            toWalletAddressView
                        }
                        .offset(y: -paddingKeyboard)
                    },
                    isShowEndText: .constant(false),
                    scrolledToLoadMore: { },
                    onOffsetChanged: { _ in
                        UIApplication.shared.endEditing()
                    }
                )
                .ignoresSafeArea(.keyboard)
                footerView
            }
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onChange(of: keyboardHeight) { value in
            if value > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        reviewBtnPaddingBottom = keyboardHeight + 10
                    }
                }
            } else {
                withAnimation(.easeInOut(duration: 0.2)) {
                    reviewBtnPaddingBottom = 50
                }
            }
            getPaddingKeyboard(value)
        }
        .keyboardAppear(keyboardHeight: $keyboardHeight)
        .ignoresSafeArea()
        .onAppear(perform: {
            textFieldCurrency?.becomeFirstResponder()
            viewModel.hideKeyboard = {
                if let amount = Double(viewModel.currency), amount > viewModel.maxAmount {
                    showSnackBar(.insufficientBalance(name: ""))
                    viewModel.currency = String(format: "%.1f", viewModel.maxAmount)
                    viewModel.currencyValue = viewModel.maxAmount
                    viewModel.oneValue = viewModel.maxAmount
                }
                self.textFieldCurrency?.resignFirstResponder()
                self.textFieldAddress?.resignFirstResponder()
                self.textViewPurpose?.resignFirstResponder()
            }
        })
        .onReceive(viewModel.$currencyValue, perform: { value in
            guard !viewModel.isCurrencyUpdate else { return }
            if isSliderUpdate {
                viewModel.oneValue = value.rounded()
                viewModel.currency = "\(Int(value))"
            } else {
                viewModel.oneValue = value
            }
        })
    }
}

// MARK: - Subview
extension CreateDisbursementView {
    private var header: some View {
        ZStack {
            HStack {
                Button(action: { onTapClose() }) {
                    Image.closeBackup
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 30)
                }
                .padding(.leading, 24)
                .offset(y: 2)
                Spacer()
            }
            Text("Initiate Disbursement")
                .tracking(0.5)
                .foregroundColor(Color.white)
                .font(.system(size: 18, weight: .bold))
        }
    }

    private var currencyView: some View {
        VStack(spacing: 0) {
            CurrencyTextField(focusState: .constant(.none),
                              text: $viewModel.currency,
                              amountState: $viewModel.amountState,
                              textFieldType: .pay,
                              placeholder: "0",
                              formatedCurrency: { amount in
                guard !viewModel.isCurrencyUpdate else { return }
                viewModel.currencyValue = amount
                viewModel.oneValue = amount
            })
                .foregroundColor(Color.timelessBlue)
                .padding(.horizontal, 10)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .keyboardType(.decimalPad)
                .introspectTextField { textField in
                    if self.textFieldCurrency == nil {
                        self.textFieldCurrency = textField
                        self.textFieldCurrency?.font = .systemFont(ofSize: 55, weight: .bold)
                        self.textFieldCurrency?.textColor = .timelessBlue
                        self.textFieldCurrency?.textAlignment = .center
                        self.setupToolbar(textField)
                        self.textFieldCurrency?.adjustsFontSizeToFitWidth = true
                        self.textFieldCurrency?.becomeFirstResponder()
                    }
                }
                .offset(x: shakeAnimation)
                .onTapGesture {
                    // AVOID KEYBOARD CLOSE
                }
                .background(
                    Color.almostClear
                        .padding(.leading, 4)
                        .padding(.vertical, -10)
                        .onTapGesture {
                            textFieldCurrency?.becomeFirstResponder()
                        }
                )
            Text(viewModel.currencyValue == 0 ? "" : "~\(exchangeCurrency) USD")
                .tracking(0.7)
                .lineLimit(1)
                .font(.system(size: 18))
                .foregroundColor(Color.exchangeCurrency)
                .frame(minHeight: 25)
            ZStack(alignment: .topTrailing) {
                Slider(value: $viewModel.currencyValue, in: 0...viewModel.maxAmount, onEditingChanged: { isEditing in
                    isSliderUpdate = isEditing
                })
                    .padding(.horizontal, 15)
                    .padding(.top, 35)
                Text("max")
                    .font(.sfProText(size: 18))
                    .foregroundColor(Color.white60)
                    .padding(.trailing, 15)
                    .offset(y: 5)
                    .background(Color.almostClear)
                    .onTapGesture {
                        viewModel.isCurrencyUpdate = true
                        viewModel.amountState = .maxAmount
                        viewModel.currency = "\(viewModel.maxAmount)"
                        textFieldCurrency?.text = "\(viewModel.maxAmount)"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            viewModel.amountState = .none
                            viewModel.currencyValue = viewModel.maxAmount
                            viewModel.oneValue = viewModel.maxAmount
                        }
                    }
            }
        }
        .padding(.top, UIView.hasNotch ? 30 : 15)
        .padding(.bottom, UIView.hasNotch ? 10 : 10)
    }

    private var selectedUser: some View {
        VStack {
            Text("From multisig wallet")
                .font(.sfProDisplayRegular(size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.paymentTitleFont.opacity(0.6))
            HStack {
                Image.avatarNikola
                    .resizable()
                    .frame(width: 45, height: 45)
                    .clipShape(Circle())
                    .padding(.leading, 16)
                HStack(spacing: 0) {
                    VStack(spacing: 3) {
                        WalletAddressView(address: viewModel.walletAddress, trimCount: 10)
                            .font(.sfProText(size: 15))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Balance: \(Utils.formatONE(Double(viewModel.totalOneBalance))) ONE")
                            .font(.sfProText(size: 12))
                            .foregroundColor(Color.paymentTitleFont.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .frame(height: 70)
            .frame(maxWidth: .infinity)
            .background(Color.paymentCard)
            .cornerRadius(8)
        }
        .padding(.horizontal, 17)
        .padding(.bottom, 15)
    }

    private var toWalletAddressView: some View {
        VStack {
            Text("To wallet address")
                .font(.sfProDisplayRegular(size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.paymentTitleFont.opacity(0.6))
                .padding(.horizontal, 17)
            HStack {
                charityImage(.init(width: 45, height: 45),
                             path: viewModel.disbursementModel?.charityThumb ?? "")
                    .clipShape(Circle())
                    .padding(.leading, 16)
                HStack(spacing: 0) {
                    VStack(spacing: 3) {
                        WalletAddressView(address: viewModel.recipientWalletAddress)
                            .font(.sfProText(size: 15))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Balance: \(Utils.formatONE(Double(viewModel.recipientBalance))) ONE")
                            .font(.sfProText(size: 12))
                            .foregroundColor(Color.paymentTitleFont.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .frame(height: 70)
            .frame(maxWidth: .infinity)
            .background(Color.paymentCard)
            .cornerRadius(8)
            .padding(.horizontal, 17)
            .frame(height: 60)
            .padding(.top, UIView.hasNotch ? 10 : 10)
        }
    }

    /*
    private var toWalletAddressView: some View {
        VStack(spacing: 5) {
            Text("To wallet address")
                .font(.sfProDisplayRegular(size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.paymentTitleFont.opacity(0.6))
            HStack(spacing: 0) {
                ZStack(alignment: .leading) {
                    TextField("", text: $viewModel.recipientWalletAddress, onCommit: {
                        withAnimation {
                            scrollPosition = .none
                        }
                    })
                        .submitLabel(.done)
                        .font(.system(size: 16))
                        .padding(.leading, 10)
                        .foregroundColor(Color.white)
                        .accentColor(Color.timelessBlue)
                        .zIndex(1)
                        .introspectTextField { textField in
                            if self.textFieldAddress == nil {
                                self.textFieldAddress = textField
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                self.textFieldAddress?.becomeFirstResponder()
                                scrollPosition = .walletAddress
                            }
                        }
                    Text("0x12345…")
                        .foregroundColor(Color.white60)
                        .font(.system(size: 16))
                        .padding(.leading, 10)
                        .opacity(viewModel.recipientWalletAddress.isBlank ? 1 : 0)
                }
                .height(41)
                Button(action: {
                    let view = QRCodeReaderView()
                    view.screenType = .moneyORAddToContact
                    if let topVc = UIApplication.shared.getTopViewController() {
                        view.modalPresentationStyle = .fullScreen
                        view.onScanSuccess = { qrString in
                            viewModel.onQRCodeScanSuccess(strScanned: qrString)
                        }
                        topVc.present(view, animated: true)
                    }
                }) {
                    ZStack {
                        Image.qrcodeViewFinder
                            .resizable()
                            .frame(width: 27, height: 27)
                            .foregroundColor(Color.white87)
                    }
                    .height(44)
                    .width(44)
                    .overlay(
                        Color.almostClear
                            .padding(.trailing, 4)
                    )
                }
            }
            .background(Color.reviewButtonBackground)
            .cornerRadius(6)
            .frame(width: UIScreen.main.bounds.width - 32, height: 41)
            HStack(spacing: 6) {
                Image.exclamationMarkCircle
                    .resizable()
                    .foregroundColor(Color.timelessRed)
                    .frame(width: 13, height: 13)
                Text("Not a valid address - pls double check")
                    .tracking(0.3)
                    .font(.system(size: 14))
                    .foregroundColor(Color.timelessRed)
            }
            .opacity(!isValidAddress && !viewModel.recipientWalletAddress.isEmpty ? 1 : 0)
            .padding(.top, 3)
            .frame(maxWidth: .infinity, alignment: .leading)
            ZStack(alignment: .top) {
                if scrollPosition != .purpose || viewModel.stringPurpose.isEmpty {
                    Text("Purpose (e.g., full disbursement of fund to charity x as per polling result)")
                        .font(.sfProText(size: 15))
                        .foregroundColor(Color.white40)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
                TextEditor(text: $viewModel.stringPurpose)
                    .opacity(viewModel.stringPurpose.isEmpty ? 0.01 : 1)
                    .introspectTextView { textViewPurpose in
                        if self.textViewPurpose == nil {
                            self.textViewPurpose = textViewPurpose
                            self.setupToolbar(textViewPurpose)
                        }
                    }
                    .onTapGesture {
                        // AVOID KEYBOARD CLOSE
                        withAnimation {
                            textViewPurpose?.becomeFirstResponder()
                            scrollPosition = .purpose
                        }
                    }
            }
            .frame(height: 60)
            .padding(.top, UIView.hasNotch ? 10 : 10)
            Color.separatorColor
                .frame(height: 1)
                .padding(.top, 5)
        }
        .padding(.horizontal, 17)
        .padding(.bottom, 17)
    }
     */

    private var footerView: some View {
        VStack {
            Text("Review")
                .font(.sfProText(size: 17))
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.timelessBlue)
                .clipShape(Capsule())
                .contentShape(Rectangle())
                .padding(.horizontal, 30)
                .onTapGesture {
                    guard viewModel.currencyValue != 0 else {
                        showSnackBar(.errorMsg(text: "Entered amount cannot be zero"))
                        return
                    }
                    guard viewModel.isValidInputAmount(amount: viewModel.currencyValue) else {
                        showSnackBar(.insufficientBalance(name: ""))
                        return
                    }
                    guard isValidAddress else {
                        showSnackBar(.errorMsg(text: "Not a valid address - pls double check"))
                        return
                    }
                    viewModel.submitReview(recipientWalletAddress: viewModel.recipientWalletAddress)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                        present(NavigationView {
                            DisbursementReviewView(viewModel: .init(model: viewModel.disbursementModel ?? .init(with: [:])))
                                .hideNavigationBar()
                        }, presentationStyle: .fullScreen)
                    }
                }
        }
        .padding(.bottom, reviewBtnPaddingBottom)
    }

}

// MARK: - Methods
extension CreateDisbursementView {
    private func onTapClose() {
        dismiss()
        pop()
    }

    private func setupToolbar(_ textField: UITextField) {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: textField.frame.size.width, height: 44))
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: viewModel,
            action: #selector(viewModel.doneButtonTapped)
        )
        doneButton.tintColor = UIColor.timelessBlue
        toolBar.items = [flexButton, doneButton]
        toolBar.setItems([flexButton, doneButton], animated: false)
        textField.inputAccessoryView = toolBar
    }

    private func setupToolbar(_ textView: UITextView) {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: textView.frame.size.width, height: 44))
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: viewModel,
            action: #selector(viewModel.doneButtonTapped)
        )
        doneButton.tintColor = UIColor.timelessBlue
        toolBar.items = [flexButton, doneButton]
        toolBar.setItems([flexButton, doneButton], animated: false)
        textView.inputAccessoryView = toolBar
    }

    private func charityImage(_ size: CGSize, path: String) -> AnyView {
        let image = MediaResourceModel(path: path,
                                       altText: nil,
                                       pathPrefix: nil,
                                       mediaType: nil,
                                       thumbnail: nil)
        return MediaResourceView(for: MediaResource(for: image,
                                                       targetSize: TargetSize(width: Int(size.width),
                                                                              height: Int(size.height))),
                                    placeholder: ProgressView()
                                        .progressViewStyle(.circular)
                                        .eraseToAnyView(),
                                    isPlaying: .constant(true))
            .scaledToFill()
            .frame(size)
            .eraseToAnyView()
    }

    private func showExceedsLimit() {
        for indexShake in 0 ..< 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.07 * Double(indexShake)) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    shakeAnimation = 10 - (20 * (indexShake == 3 ? 0.5 : (indexShake + 3).isMultiple(of: 2) ? 1 : 0))
                }
            }
        }
        generator.notificationOccurred(.success)
    }

    private func getPaddingKeyboard(_ value: CGFloat) {
        let keyboardTop = UIScreen.main.bounds.height - value
        let focusedTextInputBottom = (UIResponder.currentFirstResponder?.globalFrame?.maxY ?? 0) + 18 + paddingKeyboard
        withAnimation(.easeInOut(duration: 0.2)) {
            if focusedTextInputBottom > keyboardTop {
                paddingKeyboard = focusedTextInputBottom - keyboardTop + 49
            } else {
                paddingKeyboard = 0
            }
        }
    }
}
