//
//  NewWalletView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 17/01/22.
//

import SwiftUI
import Introspect

struct NewWalletView {
    @ObservedObject private var viewModel = ViewModel.shared
    @State private var walletName = ""
    @State private var textField: UITextField?
    @State private var keyboardHeight = CGFloat.zero
    @AppStorage(ASSettings.General.appSetupState.key)
    private var appSetupState = ASSettings.General.appSetupState.defaultValue
    private var disableCreate: Bool {
        viewModel.errorType != .available || walletName.isEmpty || walletName.count <= 5
    }
    private var walletNameRandomPlaceholder: String {
        return ["Isleepwithmysockson",
                "JOOOHNCEENNA",
                "Cerealbeforemilk",
                "spainwithoutthes"].randomElement() ?? ""
    }
}

extension NewWalletView: View {
    var body: some View {
        ZStack(alignment: .top) {
            Color.sheetBG
            VStack(spacing: 0) {
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
                        Text("New wallet")
                            .tracking(0)
                            .foregroundColor(Color.white87)
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                .padding(.top, 26.5)
            }
            VStack(spacing: 0) {
                Text("Name your wallet")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(Color.white60)
                    .padding(15)
                    .padding(.top, 40)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 0) {
                    if !walletName.isEmpty {
                        Text("@")
                            .font(.system(size: 20))
                            .padding(.leading, 16)
                        Spacer()
                    }
                    ZStack(alignment: .trailing) {
                        TextField(walletNameRandomPlaceholder, text: $walletName)
                            .font(.system(size: 20))
                            .foregroundColor(Color.white)
                            .zIndex(1)
                            .accentColor(Color.timelessBlue)
                            .padding(.leading, walletName.isEmpty ? 21.5 : 0)
                            .disableAutocorrection(true)
                            .autocapitalization(UIKit.UITextAutocapitalizationType.none)
                            .keyboardType(.alphabet)
                            .introspectTextField { textField in
                                if self.textField == nil {
                                    self.textField = textField
                                    self.textField?.returnKeyType = .next
                                    textField.becomeFirstResponder()
                                }
                                textField.returnKeyType = .done
                            }
                    }
                    .height(44)
                    .onChange(of: walletName) { value in
                        viewModel.errorType = .none
                        walletName = value.trimmingCharacters(in: .whitespacesAndNewlines)
                        viewModel.walletName = value
                    }
                    Spacer()
// Todo
//                    Text(".crazy.one")
//                        .font(.system(size: 20, weight: .regular))
//                        .foregroundColor(Color.white40)
//                        .padding(.trailing, 24)
                }
                .frame(width: UIScreen.main.bounds.width - 30, height: 41)
                .background(
                    Color.almostClear
                        .padding(.horizontal, 4)
                        .onTapGesture {
                            textField?.becomeFirstResponder()
                        }
                )
                .background(Color.formForeground.cornerRadius(10))
                .padding(.bottom, 12)
                ZStack(alignment: .topLeading) {
                    Color.clear.frame(height: 45)
                    if viewModel.errorType != .none {
                        validateText
                    } else {
                        Text("Wallet name replaces the long alphanumerical wallet address nonsense")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.6))
                            .padding(.horizontal, 25)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: viewModel.errorType)
                Spacer()
                Button {
                    dismiss()
                    CryptoHelper.shared.newWalletName = viewModel.walletName
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showConfirmation(.createWallet, interactiveHide: false, isBlur: false)
                    }
                } label: {
                    HStack {
                        Text("Create")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color.white)
                    }
                    .frame(width: UIScreen.main.bounds.width - 48, height: 48)
                    .background((!disableCreate ? Color.timelessBlue : Color.confirmationSheetCancelBG).cornerRadius(15))
                }
                .disabled(disableCreate)
                .opacity(disableCreate ? 0.3 : 1.0)
                Spacer()
            }
            .padding(.top, 58)
            .keyboardAppear(keyboardHeight: $keyboardHeight)
        }
        .onAppear {
            viewModel.errorType = .none
            viewModel.createWallet()
        }
        .onDisappear {
            viewModel.errorType = .none
        }
    }
}

extension NewWalletView {
    private var validateText: some View {
        HStack {
            if let icon = viewModel.errorType.icon {
                icon
            }
            Text(viewModel.errorType.title)
            Spacer()
        }
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(viewModel.errorType.color)
        .padding(.leading, 38)
        .padding(.bottom, 10)
    }
}

extension NewWalletView {
    private func onTapClose() {
        dismiss()
    }
}

struct NewWalletView_Previews: PreviewProvider {
    static var previews: some View {
        NewWalletView()
    }
}
