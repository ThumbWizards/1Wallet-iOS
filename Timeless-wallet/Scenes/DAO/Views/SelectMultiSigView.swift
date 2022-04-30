//
//  SelectMultiSigView.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 31/01/22.
//

import SwiftUI
import web3swift

struct SelectMultiSigView {
    // MARK: - Variables
    @StateObject var viewModel: ViewModel
    @FocusState private var focusedField: Bool
    @State var isShowingActionSheet = false
    @State private var shakeAnimation = CGFloat.zero
    @State private var keyboardHeight = CGFloat.zero
    @State private var paddingKeyboard = CGFloat.zero
    private let generator = UINotificationFeedbackGenerator()
}

extension SelectMultiSigView: View {
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Color.primaryBackground
                    .edgesIgnoringSafeArea(.all)
                VStack(alignment: .center, spacing: 0) {
                    titleView
                        .padding(.vertical, 17)
                        .padding(.horizontal, 16)
                    safetyDesc
                        .padding(.leading, 6)
                        .padding(.trailing, 16)
                    Spacer()
                        .frame(height: 12)
                    ScrollView {
                        VStack(spacing: 12) {
                            walletListView
                                .frame(width: UIScreen.main.bounds.width - 22)
                                .padding(.leading, 6)
                                .padding(.trailing, 16)
                            addAnotherSigner
                                .frame(width: UIScreen.main.bounds.width - 22)
                                .padding(.leading, 6)
                                .padding(.trailing, 16)
                            if viewModel.signers.count >= 2 {
                                bottomView
                                    .padding(.top, 30)
                            }
                        }
                        .offset(y: -paddingKeyboard)
                    }
                    .ignoresSafeArea(.keyboard)
                }
                if viewModel.signers.count <= 1 {
                    importantDesc
                }
            }
            .keyboardAppear(keyboardHeight: $keyboardHeight)
            .onChange(of: keyboardHeight) { value in getPaddingKeyboard(value) }
            .onChange(of: viewModel.thresholdCount, perform: { value in
                if (Int(value) ?? 0) > viewModel.signers.count {
                    shakeAnimate()
                    viewModel.thresholdCount = "\(viewModel.signers.count)"
                }
            })
            .hideNavigationBar()
            .loadingOverlay(isShowing: viewModel.isLoading)
        }
    }
}

// MARK: - Functions
extension SelectMultiSigView {
    private func onTapBack() {
        dismiss()
        pop()
    }

    private func onTapQRScan() {
        let view = QRCodeReaderView()
        view.screenType = .addSigners
        if let topVc = UIApplication.shared.getTopViewController() {
            view.modalPresentationStyle = .fullScreen
            view.onScanSuccess = { qrString in
                self.onQRCodeScanSuccess(strScanned: qrString)
            }
            UIApplication.shared.endEditing()
            topVc.present(view, animated: true)
        }
    }

    private func onQRCodeScanSuccess(strScanned: String) {
        if let url = URL(string: strScanned), UIApplication.shared.canOpenURL(url) {
            let lastComponent = url.lastPathComponent
            if lastComponent.isOneWalletAddress {
                viewModel.checkAndAddSigner(address: lastComponent)
            }
        } else if strScanned.isOneWalletAddress {
            viewModel.checkAndAddSigner(address: strScanned)
        } else {
            showSnackBar(.message(text: "Invalid wallet address"))
        }
    }

    private func deleteSigner() {
        guard let deleteIndex = viewModel.deleteIndex else {
            return
        }
        viewModel.deleteSigner(at: deleteIndex)
        viewModel.deleteIndex = nil
    }

    private func presentShareView() {
        viewModel.bindDaoData()
        present(DaoCreateAndShareView(viewModel: .init(viewModel.daoModel)),
                presentationStyle: .fullScreen)
    }

    private func getWalletName(_ signer: SignerWallet) -> String? {
        if signer.walletAddress?.address == Wallet.currentWallet?.address {
            return "\(signer.walletName ?? "") (You)"
        } else {
            return signer.walletName
        }
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
}

// MARK: - Subviews
extension SelectMultiSigView {
    private var titleView: some View {
        ZStack {
            HStack {
                Button(action: {onTapBack()}) {
                    Image.closeBackup
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
                Text("Select Signers")
                    .tracking(-0.2)
                    .foregroundColor(Color.subtitleSheet)
                    .font(.system(size: 14, weight: .medium))
            }
        }
    }

    private var safetyDesc: some View {
        HStack {
            Text("For safety minimum 2 of 3 required")
                .font(.sfProText(size: 14))
                .multilineTextAlignment(.leading)
                .foregroundColor(.sectionContactText)
                .padding(.leading, 15)
            Spacer()
        }
        .frame(height: 28)
        .background(.searchBackground)
        .cornerRadius(8)
    }

    private var walletListView: some View {
        ForEach(viewModel.signers.indices, id: \.self) { index in
            let indexData = viewModel.signers[index]
            MultisigWalletView(
                walletAddress: indexData.walletAddress?.address,
                walletName: getWalletName(indexData),
                walletAvatar: indexData.walletAvatar,
                type: index != 0 ? .editAndDelete : .edit,
                deleteTapped: {
                    viewModel.deleteIndex = index
                    isShowingActionSheet = true
                },
                editTapped: {
                    present(AddEditSignatoryDetailView(
                        viewModel: .init(
                            screenType: .edit,
                            signersDetail: indexData),
                        signersDetail: { signerWallet in
                        viewModel.replaceSigner(at: index, signerWallet)
                    }))
                })
            .actionSheet(isPresented: $isShowingActionSheet) {
                ActionSheet(title: Text("Are you sure you want to remove?"), buttons: [
                    .default(Text("No - Keep"), action: {
                    }),
                    .destructive(Text("Yes - Remove"), action: {
                        deleteSigner()
                    }),
                    .cancel()
                ])
            }
        }
    }

    private var addAnotherSigner: some View {
        HStack {
            Button(action: {
                present(AddEditSignatoryDetailView(viewModel: .init(screenType: .add), signersDetail: { signerWallet in
                    viewModel.addSigner(signerWallet)
                }))
            }) {
                Image.plusCircleIcon
                    .frame(height: 21)
                    .padding(.leading, 15)
                Text("Add another signer")
                    .foregroundColor(.sectionContactText)
            }.tint(.white)
            Spacer()
            Button(action: {
                onTapQRScan()
            }) {
                Image.qrcode
                    .tint(.white)
                    .frame(width: 28, height: 28)
            }
            .padding(.trailing, 22)
        }
        .frame(height: 44)
        .background(.searchBackground)
        .cornerRadius(12.5)
    }

    //swiftlint:disable line_length
    private var importantDesc: some View {
        Text("This step is important as these are the addresses that have permission to submit and approve transactions (you can later still remove or replace these addresses). Your wallet is already added as the first signer, but you can change it as well. Add as many signers as you want using their HNS or wallet address.")
            .multilineTextAlignment(.leading)
            .font(.sfProText(size: 12))
            .foregroundColor(.white.opacity(0.4))
            .padding(.horizontal, 16)
    }

    private var bottomView: some View {
        HStack {
            HStack {
                TextField("", text: $viewModel.thresholdCount) {
                    print("on commit")
                }
                .offset(x: shakeAnimation)
                .toolbar(content: {
                    ToolbarItemGroup(placement: .keyboard) {
                        HStack {
                            Spacer()
                            Button(action: {
                                focusedField = false
                            }) {
                                Text("Done")
                                    .foregroundColor(.timelessBlue)
                            }
                        }
                    }
                })
                .focused($focusedField)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .disableAutocorrection(true)
                .accentColor(Color.timelessBlue)
                .frame(width: 47, height: 37)
                .background(.white.opacity(0.05))
                .cornerRadius(18.5)
                Text("of \(viewModel.signers.count) required")
                    .font(.sfProText(size: 13))
                    .foregroundColor(.white.opacity(0.4))
            }
            Spacer()
            HStack {
                Text("Review")
                    .font(.sfProTextSemibold(size: 17))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 4)
                Button(action: {
                    focusedField = false
                    if viewModel.isValidate() {
                        presentShareView()
                    }
                }) {
                    Image.nextCircle
                        .resizable()
                        .frame(width: 45, height: 45)
                }
            }
        }
        .padding(.horizontal, 26)
    }
}

// MARK: - Methods
extension SelectMultiSigView {
    private func getPaddingKeyboard(_ value: CGFloat) {
        let keyboardTop = UIScreen.main.bounds.height - value
        let focusedTextInputBottom = (UIResponder.currentFirstResponder?.globalFrame?.maxY ?? 0) + 18 + paddingKeyboard
        withAnimation(.easeInOut(duration: 0.2)) {
            if focusedTextInputBottom > keyboardTop {
                paddingKeyboard = focusedTextInputBottom - keyboardTop + 13
            } else {
                paddingKeyboard = 0
            }
        }
    }
}
