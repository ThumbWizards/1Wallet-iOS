//
//  BackupICloudPasswordView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 05/11/2021.
//

import SwiftUI
import Combine
import StreamChatUI
import web3swift
import StreamChat

struct SendView: View {
    // MARK: - Properties
    @State var recipientAddress = ""
    @State var recipientName = ""
    @State var recipientImageUrl: URL?
    @State private var textFieldAddress: UITextField?
    @State private var textFieldCurrency: UITextField?
    @State private var isCheckAddContact = false
    @State private var isOwn = true // TEMP
    @State private var dismissCancellable: AnyCancellable?
    @State private var keyboardHeight = CGFloat.zero
    @State private var focusTextFieldType = FocusTextFieldSend.none
    @State private var addressEditing = false
    @State private var focusStateAmount = SwapView.ViewModel.FocusState.none
    @State private var tokenToggle = true
    @State private var disableUseMax = false

    @StateObject private var viewModel = ViewModel()
    @StateObject private var walletInfo = WalletInfo.shared
    @AppStorage(ASSettings.Settings.firstDeposit.key)
    private var firstDeposit = ASSettings.Settings.firstDeposit.defaultValue

    private var isEnableReview: Bool {
        recipientAddress.isOneWalletAddress && reviewButtonEnable
    }
    private var isValidAddress: Bool {
        recipientAddress.isOneWalletAddress
    }
    private var reviewButtonEnable: Bool {
        viewModel.payValue > 0
    }

    enum FocusTextFieldSend: CaseIterable {
        case address
        case amount
        case none
    }
}

// MARK: - Body view
extension SendView {
    var body: some View {
        ZStack(alignment: .top) {
            Color.sheetBG
            VStack(spacing: 0) {
                header
                recipient
                asset
                reviewButton
            }
        }
        .keyboardAppear(keyboardHeight: $keyboardHeight)
        .edgesIgnoringSafeArea(.bottom)
        .loadingOverlay(isShowing: viewModel.selectedToken == nil)
        .onTapGesture { onTapOut() }
        .onAppear {
            switch focusTextFieldType {
            case .address:
                textFieldAddress?.becomeFirstResponder()
                focusTextFieldType = .none
            case .amount:
                focusStateAmount = .pay
                focusTextFieldType = .none
            case .none: break
            }
            disableUseMax = viewModel.selectedToken?.balance == 0
            if viewModel.listToken.isEmpty {
                viewModel.getWalletData()
            }
        }
        .onChange(of: walletInfo.currentWallet.detailViewModel.overviewModel.totalONEAmount) { value in
            disableUseMax = value == 0
        }
        .onChange(of: tokenToggle) { value in
            viewModel.payText = ""
            if viewModel.getMaxUSDLoading { viewModel.stopCancellable() }
            if value {
                viewModel.sendAmountType = .token
            } else {
                viewModel.sendAmountType = .usd
            }
        }
        .onChange(of: walletInfo.currentWallet) { _ in
            viewModel.stopCancellable()
            viewModel.resetInitialData()
            viewModel.listToken = []
            viewModel.getWalletData()
        }
    }
}

// MARK: - Subview
extension SendView {
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
                .offset(y: -1)
                Spacer()
            }
            VStack(spacing: 3.5) {
                Text("Send")
                    .tracking(0)
                    .foregroundColor(Color.white87)
                    .font(.system(size: 18, weight: .semibold))
                Text("Easy send")
                    .tracking(-0.2)
                    .foregroundColor(Color.subtitleSheet)
                    .font(.system(size: 14, weight: .medium))
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
        }
        .padding(.top, 26.5)
        .padding(.bottom, UIView.hasNotch ? 35 : 5)
    }

    private var recipient: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Recipient")
                .tracking(-0.5)
                .padding(.horizontal, 15)
                .foregroundColor(Color.white60)
                .font(.system(size: 18))
                .padding(.bottom, 12)
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.sendTextFieldBG)
                    .frame(height: 51)
                    .overlay(
                        HStack(spacing: 16) {
                            ZStack(alignment: .leading) {
                                Text("HNS or Address")
                                    .tracking(0.5)
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.white60)
                                    .opacity(recipientAddress.isEmpty ? 1 : 0)
                                    .padding(.leading, 23)
                                TextField("", text: $recipientAddress, isEditing: $addressEditing)
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.white)
                                    .disableAutocorrection(true)
                                    .keyboardType(.alphabet)
                                    .accentColor(Color.timelessBlue)
                                    .padding(.leading, 23)
                                    .introspectTextField { textField in
                                        if self.textFieldAddress == nil {
                                            self.textFieldAddress = textField
                                            setupAccessoryView(onTextField: textField)
                                            self.textFieldAddress?.becomeFirstResponder()
                                        }
                                    }
                                    .onTapGesture {
                                        // AVOID KEYBOARD CLOSE
                                    }
                            }
                            .background(
                                Color.almostClear
                                    .padding(.leading, 4)
                                    .padding(.vertical, -10)
                                    .onTapGesture {
                                        textFieldAddress?.becomeFirstResponder()
                                    }
                            )
                            Button(action: { onTapQRScan() }) {
                                Image.qrcodeViewFinder
                                    .resizable()
                                    .foregroundColor(Color.sendQRCodeIcon)
                                    .frame(width: 21, height: 21)
                                    .padding(.trailing, 17)
                                    .overlay(
                                        Color.almostClear
                                            .padding(.leading, -16)
                                            .padding(.trailing, 4)
                                            .padding(.vertical, -10)
                                    )
                            }
                        }
                    )
                    .padding(.horizontal, 15)
            }
            .padding(.bottom, 11)
            ZStack(alignment: .leading) {
                Button(action: { onTapAdd() }) {
                    HStack(spacing: 10) {
                        Image(systemName: isCheckAddContact ? "checkmark.square.fill" : "square")
                            .resizable()
                            .foregroundColor(Color.sendCheckMark)
                            .frame(width: 13, height: 13)
                        Text("Add as contact")
                            .tracking(0.3)
                            .font(.system(size: 12))
                            .foregroundColor(Color.sendCheckMark)
                    }
                    .padding(.leading, 19)
                    .offset(y: -5)
                }
                .opacity(recipientAddress.isEmpty ? 1 : 0)
                .padding(.horizontal, 16)
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
                .opacity(!isValidAddress && !recipientAddress.isEmpty ? 1 : 0)
                .padding(.horizontal, 16)
            }
        }
        .padding(.bottom, UIView.hasNotch ? 27 : 12)
    }

    private var asset: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Asset")
                .tracking(-0.5)
                .padding(.horizontal, 15)
                .foregroundColor(Color.white60)
                .font(.system(size: 18))
                .padding(.bottom, 6)
            HStack(spacing: 0) {
                Button(action: { onTapCombobox() }) {
                    HStack(spacing: 0) {
                        ZStack {
                            if viewModel.selectedToken?.key != nil {
                                Image.oneIcon
                                    .resizable()
                                    .frame(width: 43, height: 43)
                                    .padding(.trailing, 6)
                            } else if let icon = viewModel.selectedToken?.icon,
                               let url = URL(string: icon) {
                                MediaResourceView(
                                    for: MediaResource(
                                        for: MediaResourceWebImage(
                                            url: url,
                                            isAnimated: true,
                                            targetSize: TargetSize(
                                                width: 43,
                                                height: 43))),
                                       placeholder: ProgressView()
                                        .progressViewStyle(.circular)
                                        .eraseToAnyView(),
                                       isPlaying: .constant(true))
                            }
                        }
                        .frame(width: 43, height: 43)
                        .cornerRadius(.infinity)
                        .padding(.trailing, 6)
                        if let symbol = viewModel.selectedToken?.symbol {
                            Text(symbol)
                                .tracking(0.7)
                                .font(.system(size: 22))
                                .foregroundColor(Color.white60)
                                .padding(.trailing, 10)
                        }
                        Image.chevronDown
                            .resizable()
                            .foregroundColor(Color.white)
                            .frame(width: 15, height: 8)
                    }
                }
                .padding(.leading, 15)
                Spacer()
                CurrencyTextField(
                    focusState: $focusStateAmount,
                    text: $viewModel.payText,
                    amountState: $viewModel.sendAmountType,
                    textFieldType: .pay,
                    placeholder: viewModel.sendAmountType == .usd ? "$0" : "0") { formattedCurrency in
                        if viewModel.getMaxUSDLoading {
                            viewModel.stopCancellable()
                        }
                        viewModel.payValue = formattedCurrency
                    }
                    .opacity(viewModel.getMaxUSDLoading ? 0.0001 : 1)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(.circular)
                            .padding(.trailing, 10)
                            .opacity(viewModel.getMaxUSDLoading ? 1 : 0), alignment: .trailing
                    )
                    .padding(.trailing, 24)
                    .introspectTextField { textField in
                        if self.textFieldCurrency == nil {
                            self.textFieldCurrency = textField
                            setupAccessoryAmountView(onTextField: textField)
                        }
                    }
            }
            .frame(height: 43)
            .padding(.bottom, 3)
            HStack(spacing: 6) {
                DisplayCurrencyView(
                    value: Utils.formatBalance(viewModel.selectedToken?.balance),
                    type: "Balance:",
                    isSpacing: true,
                    valueAfterType: true,
                    font: .system(size: 14),
                    color: Color.white.opacity(0.6)
                )
                Spacer()
                Text(viewModel.rateCurrency)
                    .tracking(0.3)
                    .lineLimit(1)
                    .font(.system(size: 14))
                    .foregroundColor(Color.white60)
                    .opacity(viewModel.getMaxUSDLoading ? 0 : 1)
            }
            .padding(.leading, 16)
            .padding(.trailing, 24)
        }
    }

    private var reviewButton: some View {
        VStack(spacing: 0) {
            Button(action: { onTapReview() }) {
                RoundedRectangle(cornerRadius: .infinity)
                    .foregroundColor(isEnableReview ? Color.timelessBlue : Color.textfieldEmailBG)
                    .frame(height: 41)
                    .padding(.horizontal, 42)
                    .overlay(
                        Text("Review")
                            .foregroundColor(isEnableReview ? Color.white : Color.textfieldEmailText)
                            .font(.system(size: 17))
                    )
            }
            .disabled(!isEnableReview)
            .padding(.bottom, 8)
            Text("You’ll be able to review before confirming the transaction")
                .tracking(-0.6)
                .font(.system(size: 12))
                .foregroundColor(Color.updateViaSettingText)
                .padding(.horizontal, 15)
            Spacer()
        }
        .padding(.top, 16)
    }
}

// MARK: - Methods
extension SendView {
    private func onTapOut() {
        UIApplication.shared.endEditing()
    }

    private func onTapAdd() {
        isCheckAddContact = true
        present(AddContactView(viewModel: .init(),
                               contactViewModel: .init(screenType: .contact),
                               onClose: onCloseConfirmationSheet,
                               onSave: { name in recipientAddress = name }),
                presentationStyle: .automatic)
    }

    private func onTapCombobox() {
        UIApplication.shared.endEditing()
        viewModel.stopCancellable()
        present(SendModal(viewModel: viewModel))
    }

    private func onTapContact() {
        present(ContactModalView(viewModel: .init(screenType: .send), onContactSelect: { contact in
            recipientAddress = contact.walletAddress
            recipientName = contact.name
            recipientImageUrl = URL(string: contact.displayAvatar)
        }), presentationStyle: .automatic)
    }

    private func onTapQRScan() {
        if keyboardHeight > 0 {
            focusTextFieldType = addressEditing ? .address : .amount
        }
        let view = QRCodeReaderView()
        view.screenType = .moneyORAddToContact
        if let topVc = UIApplication.shared.getTopViewController() {
            view.modalPresentationStyle = .fullScreen
            view.onScanSuccess = { qrString in
                if let url = URL(string: qrString) {
                    recipientAddress = url.lastPathComponent
                } else {
                    recipientAddress = qrString
                }
            }
            UIApplication.shared.endEditing()
            topVc.present(view, animated: true)
        }
    }

    private func onTapClose() {
        dismiss()
    }

    private func verifyData() -> Bool {
        let payValue = viewModel.sendAmountType == .token ?
        viewModel.payValue : viewModel.rateONEPay
        if viewModel.selectedToken?.balance ?? 0 < payValue {
            showSnackBar(.insufficientBalance(name: viewModel.selectedToken?.symbol ?? ""))
            UIApplication.shared.endEditing()
            present(NavigationView { DepositView(firstDeposit: firstDeposit).hideNavigationBar() }, presentationStyle: .automatic)
            if firstDeposit {
                firstDeposit = false
            }
            return false
        }
        return true
    }

    private func onTapReview() {
        guard verifyData() else {
            return
        }
        let payValue = viewModel.sendAmountType == .token ?
        viewModel.payValue : viewModel.rateONEPay
        let param = [EthereumAddress(recipientAddress.convertBech32ToEthereum()),
                     Web3Service.shared.amountToWeiUnit(amount: payValue, weiUnit: viewModel.selectedToken?.token?.weiUnit ?? 0)] as [AnyObject]
        var sendOneWallet = SendOneWallet()
        sendOneWallet.myName = walletInfo.currentWallet.name
        sendOneWallet.myWalletAddress = walletInfo.currentWallet.address
        sendOneWallet.recipientName = recipientName
        sendOneWallet.recipientAddress = recipientAddress
        sendOneWallet.recipientImageUrl = recipientImageUrl
        sendOneWallet.myImageUrl = ChatClient.shared.currentUserController().currentUser?.imageURL
        sendOneWallet.transferAmount = Float(payValue)
        if viewModel.sendAmountType == .token {
            sendOneWallet.strFormattedAmount = viewModel.payText
        } else {
            sendOneWallet.strFormattedAmount = Utils.formatBalance(payValue)
        }
        sendOneWallet.fractionDigits = Decimal(string: "\(payValue)")?.significantFractionalDecimalDigits ?? 0
        dismissCancellable = dismiss()?.sink(receiveValue: { _ in
            showConfirmation(.sendOneConfirmation(walletData: sendOneWallet,
                                                  screenType: .send,
                                                  channel: nil,
                                                  token: viewModel.selectedToken?.token,
                                                  param: param),
                             interactiveHide: false)
        })
    }

    private func onCloseConfirmationSheet() {
        isCheckAddContact = false
    }

    private func setupAccessoryView(onTextField textField: UITextField) {
        var accessoryView: SendAccessoryView?
        let keyboardToolbarView = SendKeyboardToolbar(
            onTapContact: onTapContact,
            onTapQRScan: onTapQRScan)
        let hostingController = UIHostingController(rootView: keyboardToolbarView, ignoreSafeArea: true)
        accessoryView = SendAccessoryView(
            frame: hostingController.view.frame,
            hostingPermissionViewController: hostingController
        )
        textField.inputAccessoryView = accessoryView
    }

    private func setupAccessoryAmountView(onTextField textField: UITextField) {
        var accessoryView: SendAccessoryAmountView?
        let keyboardToolbarView = SendAmountToolbar(
            viewModel: viewModel,
            onTapUseMax: onTapUseMax,
            tokenToggle: $tokenToggle,
            disableUseMax: $disableUseMax
        )
        let hostingController = UIHostingController(rootView: keyboardToolbarView, ignoreSafeArea: true)
        accessoryView = SendAccessoryAmountView(
            frame: hostingController.view.frame,
            hostingPermissionViewController: hostingController
        )
        textField.inputAccessoryView = accessoryView
    }

    private func onTapUseMax() {
        if viewModel.sendAmountType == .token {
            viewModel.payText = Utils.formatBalance(viewModel.selectedToken?.balance)
        } else {
            guard !viewModel.getMaxUSDLoading else { return }
            withAnimation { viewModel.getMaxUSDLoading = true }
            if let token = viewModel.selectedToken?.token {
                viewModel.getMaxUSDfromToken(value: viewModel.selectedToken?.balance ?? 0,
                                         token: token,
                                         getMaxUSDComplete: { usdAmount in setMaxUSD(usdAmount) })
            } else {
                viewModel.getMaxUSDfromONE(value: viewModel.selectedToken?.balance ?? 0,
                                       getMaxUSDComplete: { usdAmount in setMaxUSD(usdAmount) })
            }
        }
    }

    private func setMaxUSD(_ value: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                if viewModel.getMaxUSDLoading {
                    viewModel.payText = Utils.formatBalance(value)
                    viewModel.getMaxUSDLoading = false
                }
            }
        }
    }
}
