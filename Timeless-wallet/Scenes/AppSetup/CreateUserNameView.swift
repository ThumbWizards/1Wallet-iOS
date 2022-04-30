//
//  CreateUserNameView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/9/21.
//

import SwiftUI
import Introspect

struct CreateUserNameView {
    @ObservedObject private var viewModel = AppSetupView.ViewModel.shared
    @State private var walletName = ""
    @State private var textField: UITextField?
    @State private var keyboardHeight = CGFloat.zero
    @AppStorage(ASSettings.General.appSetupState.key)
    private var appSetupState = ASSettings.General.appSetupState.defaultValue
    private var disableCreate: Bool {
        viewModel.errorType != .available || walletName.isEmpty || walletName.count <= 5
    }
}

extension CreateUserNameView: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("Create that perfect user name")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 39)
                .padding(.bottom, 29)
            // swiftlint:disable line_length
            Text("This is how other users can find you and send you money - this replaces the long alphanumerical wallet address nonsense")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white87)
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 42)
            Spacer()
                .maxHeight(143)
            HStack(spacing: 0) {
                if !walletName.isEmpty {
                    Text("@")
                        .font(.system(size: 20))
                        .padding(.leading, 16)
                    Spacer()
                }
                ZStack(alignment: .trailing) {
                    TextField("", text: $walletName)
                        .font(.system(size: 20))
                        .foregroundColor(Color.white)
                        .zIndex(1)
                        .accentColor(Color.timelessBlue)
                        .padding(.leading, walletName.isEmpty ? 21.5 : 0)
                        .disableAutocorrection(true)
                        .autocapitalization(UIKit.UITextAutocapitalizationType.none)
                        .keyboardType(.alphabet)
                        .introspectTextField { textField in
                            guard appSetupState == ASSettings.AppSetupState.username.rawValue else {
                                return
                            }
                            if self.textField == nil {
                                self.textField = textField
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
//                Text(".crazy.one")
//                    .font(.system(size: 20, weight: .regular))
//                    .foregroundColor(Color.white40)
//                    .padding(.trailing, 24)
            }
            .frame(width: UIScreen.main.bounds.width - 32, height: 41)
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
                    Text("Wallet name will be made public.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.6))
                        .padding(.horizontal, 25)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.errorType)
            Spacer()
                .maxHeight(31)
            Button {
                if keyboardHeight > 0 {
                    UIApplication.shared.endEditing()
                }
                viewModel.walletName = walletName
                // HIDE FOR NOW
                // DispatchQueue.main.asyncAfter(deadline: .now() + (keyboardHeight > 0 ? 0.6 : 0)) {
                //     showConfirmation(.walletPrivacyView)
                // }
                viewModel.updateWalletTitle()
                DispatchQueue.main.async {
                    withAnimation {
                        self.appSetupState = ASSettings.AppSetupState.security.rawValue
                    }
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
        .background(Color.introduceBG.ignoresSafeArea())
        .keyboardAppear(keyboardHeight: $keyboardHeight)
        // TEMP
        .loadingOverlay(isShowing: viewModel.isLoading)
    }
}

extension CreateUserNameView {
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
    }
}
