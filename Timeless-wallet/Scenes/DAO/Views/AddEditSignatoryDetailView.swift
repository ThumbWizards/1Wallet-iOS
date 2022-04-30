//
//  AddEditSignatoryDetailView.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 01/02/22.
//

import SwiftUI
import SwiftUIX
import web3swift

struct AddEditSignatoryDetailView {
    // MARK: - Variables
    @State private var textFieldwalletAlias: UITextField?
    @State private var textFieldWalletAddress: UITextField?
    @StateObject var viewModel: ViewModel
    var signersDetail: ((SignerWallet) -> Void)?

    enum EditSignatoryType {
        case alias
        case address
    }
}

extension AddEditSignatoryDetailView: View {
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color.primaryBackground
                    .edgesIgnoringSafeArea(.all)
                VStack(alignment: .center, spacing: 0) {
                    titleView
                        .padding(.vertical, 17)
                        .padding(.horizontal, 16)
                    ScrollView {
                        signatoryInputField(.alias)
                        signatoryInputField(.address)
                        saveButton
                    }
                }
            }
            .hideNavigationBar()
            .loadingOverlay(isShowing: viewModel.isLoading)
        }
    }
}

// MARK: - Functions
extension AddEditSignatoryDetailView {
    private func onTapBack() {
        dismiss()
        pop()
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

    private func onTapContact() {
        UIApplication.shared.endEditing()
        present(ContactModalView(viewModel: .init(screenType: .addSigner), addSignerDetail: { signer in
            viewModel.walletAddress = signer.walletAddress?.address ?? ""
            viewModel.walletAlias = signer.walletName ?? ""
            viewModel.avatar = signer.walletAvatar
        }), presentationStyle: .automatic)
    }

    private func onTapQRScan() {
        let view = QRCodeReaderView()
        view.screenType = .addSigners
        if let topVc = UIApplication.shared.getTopViewController() {
            view.modalPresentationStyle = .fullScreen
            view.onScanSuccess = { qrString in
                onQRCodeScanSuccess(strScanned: qrString)
            }
            UIApplication.shared.endEditing()
            topVc.present(view, animated: true)
        }
    }

    private func onQRCodeScanSuccess(strScanned: String) {
        if let url = URL(string: strScanned), UIApplication.shared.canOpenURL(url) {
            let lastComponent = url.lastPathComponent
            if lastComponent.isOneWalletAddress,
               EthereumAddress(lastComponent.convertBech32ToEthereum()) != nil {
                viewModel.walletAddress = lastComponent
            }
        } else if strScanned.isOneWalletAddress,
                  EthereumAddress(strScanned.convertBech32ToEthereum()) != nil {
            viewModel.walletAddress = strScanned
        }
    }

    private func onTapSave() {
        viewModel.checkAndAddSigner { success in
            guard success else {
                return
            }
            guard viewModel.walletAddress.isOneWalletAddress == true,
                  let address = EthereumAddress(viewModel.walletAddress.convertBech32ToEthereum()) else {
                return
            }
            signersDetail?(.init(
                walletAddress: address,
                walletName: viewModel.walletAlias,
                walletAvatar: viewModel.avatar ?? "contactAvatar2"))
            onTapBack()
        }
    }
}

// MARK: - Subviews
extension AddEditSignatoryDetailView {
    private var titleView: some View {
        ZStack {
            HStack {
                Button(action: {onTapBack()}) {
                    Image.backSheet
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 30)
                }
                Spacer()
            }
            VStack(spacing: 3.5) {
                Text("Multisig")
                    .tracking(0)
                    .foregroundColor(Color.white87)
                    .font(.system(size: 18, weight: .semibold))
                Text(viewModel.headerSubTitle)
                    .tracking(-0.2)
                    .foregroundColor(Color.subtitleSheet)
                    .font(.system(size: 14, weight: .medium))
            }
        }
    }

    private func signatoryInputField(_ type: EditSignatoryType) -> some View {
        VStack(alignment: .leading, spacing: type == .alias ? 8 : 0) {
            Text(type == .alias ? "\(Image.scribble) Wallet Alias (only visible to you)" :
                                  "\(Image.walletPass) Wallet address")
                .tracking(-0.34)
                .font(.sfProTextSemibold(size: 14))
                .multilineTextAlignment(.leading)
                .foregroundColor(.white.opacity(0.6))
                .padding(.bottom, 8)
                .padding(.leading, 23)
                .padding(.top, type == .alias ? 25 : 10)
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.reviewButtonBackground)
                    .frame(height: 41)
                    .overlay(
                        HStack(spacing: 16) {
                            ZStack(alignment: .leading) {
                                Text("Wallet \(type == .alias ? "Alias" : "Address")")
                                    .tracking(0.5)
                                    .font(.sfProText(size: 16))
                                    .foregroundColor(Color.white60)
                                    .opacity(type == .alias ? (viewModel.walletAlias.isEmpty ? 1 : 0) :
                                                              (viewModel.walletAddress.isEmpty ? 1 : 0))
                                    .padding(.leading, 23)
                                TextField("", text: type == .alias ? $viewModel.walletAlias : $viewModel.walletAddress)
                                    .font(.sfProText(size: 16))
                                    .foregroundColor(Color.white)
                                    .disableAutocorrection(true)
                                    .keyboardType(.alphabet)
                                    .accentColor(Color.timelessBlue)
                                    .padding(.leading, 23)
                                    .introspectTextField { textField in
                                        if type == .alias {
                                            if textFieldwalletAlias == nil {
                                                textFieldwalletAlias = textField
                                                setupAccessoryView(onTextField: textField)
                                                textFieldwalletAlias?.becomeFirstResponder()
                                            }
                                        } else {
                                            if textFieldWalletAddress == nil {
                                                textFieldWalletAddress = textField
                                                setupAccessoryView(onTextField: textField)
                                            }
                                        }
                                    }
                            }
                            .background(
                                Color.almostClear
                                    .padding(.leading, 4)
                                    .padding(.vertical, -10)
                                    .onTapGesture {
                                        if type == .alias {
                                            textFieldwalletAlias?.becomeFirstResponder()
                                        } else {
                                            textFieldWalletAddress?.becomeFirstResponder()
                                        }
                                    }
                            )
                            if type == .address {
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
                        }
                    )
                    .padding(.horizontal, 15)
            }
            .padding(.bottom, type == .alias ? 11 : 71)
        }
    }

    private var saveButton: some View {
        Button(action: { onTapSave() }) {
            RoundedRectangle(cornerRadius: .infinity)
                .foregroundColor(viewModel.isEnableSave ? Color.timelessBlue : Color.textfieldEmailBG)
                .frame(height: 41)
                .padding(.horizontal, 42)
                .overlay(
                    Text("Save")
                        .foregroundColor(viewModel.isEnableSave ? Color.white : Color.textfieldEmailText)
                        .font(.system(size: 17))
                )
        }
        .disabled(!viewModel.isEnableSave)
    }

}
