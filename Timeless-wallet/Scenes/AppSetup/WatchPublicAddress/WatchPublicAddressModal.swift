//
//  WatchPublicAddressModal.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/10/21.
//

import SwiftUI

struct WatchPublicAddressModal {
    @State private var walletAddress = ""
    @State private var textField: UITextField?
}

extension WatchPublicAddressModal {
    private var copyString: String? {
        return UIPasteboard.general.string
    }
}

extension WatchPublicAddressModal: View {
    var body: some View {
        VStack {
            Spacer()
                .maxHeight(UIView.safeAreaTop + 58)
            HStack {
                VStack(spacing: 0) {
                    Text("Watch an address")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color.white87)
                        .padding(.bottom, 20)
                    HStack {
                        Spacer()
                        // swiftlint:disable line_length
                        Text("Want to keep an eye on your address without touching your seed phrase? Curious about whale activities? Now you can monitor activity of any public addresses")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color.white87)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 38)
                            .padding(.bottom, 41)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    HStack(spacing: 0) {
                        ZStack(alignment: .leading) {
                            TextField("", text: $walletAddress)
                                .font(.system(size: 16))
                                .padding(.leading, 10)
                                .foregroundColor(Color.white)
                                .accentColor(Color.timelessBlue)
                                .zIndex(1)
                                .introspectTextField { textField in
                                    if self.textField == nil {
                                        self.textField = textField
                                    }
                                    textField.becomeFirstResponder()
                                    textField.autocapitalizationType = .none
                                }
                            Text("HNS or Address")
                                .foregroundColor(Color.white60)
                                .font(.system(size: 16))
                                .padding(.leading, 10)
                                .opacity(walletAddress.isBlank ? 1 : 0)
                        }
                        .height(44)
                        .background(
                            Color.almostClear
                                .padding(.leading, 4)
                                .onTapGesture {
                                    textField?.becomeFirstResponder()
                                }
                        )
                        Button(action: {
                            let view = QRCodeReaderView()
                            view.screenType = .moneyORAddToContact
                            if let topVc = UIApplication.shared.getTopViewController() {
                                view.modalPresentationStyle = .fullScreen
                                view.onScanSuccess = { qrString in
                                    walletAddress = qrString
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
                    .frame(width: UIScreen.main.bounds.width - 32, height: 51)
                    .background(Color.textFieldHNS
                                    .cornerRadius(10))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 23)
                    Button {
                        guard let copyString = copyString else {
                            return
                        }
                        walletAddress = copyString
                    } label: {
                        HStack {
                            Text("Paste")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(Color.white)
                        }
                        .frame(width: UIScreen.main.bounds.width - 32, height: 45)
                        .background(Color.timelessBlue.cornerRadius(10))
                    }
                    .disabled(!UIPasteboard.general.hasStrings)
                }
                .padding(.top, 34)
            }
            Spacer()
        }
        .background(Color.followWalletBG.ignoresSafeArea())
    }
}
