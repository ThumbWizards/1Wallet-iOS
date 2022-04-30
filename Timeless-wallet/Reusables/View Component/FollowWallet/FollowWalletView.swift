//
//  FollowWalletView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/3/21.
//

import SwiftUI
import SwiftUIX

struct FollowWalletView {
    @ObservedObject private var tabbarViewModel = TabBarView.ViewModel.shared
    @State private var walletAddress = ""
    @SwiftUI.Environment(\.presentationMode) private var presentationMode
    @State private var textField: UITextField?
}

extension FollowWalletView {
    private var copyString: String? {
        return UIPasteboard.general.string
    }
}

extension FollowWalletView: View {
    var body: some View {
        ZStack(alignment: .top) {
            Color.primaryBackground
                .edgesIgnoringSafeArea(.top)
            VStack {
                HStack {
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            Text("Paste or scan your Harmony address to track and follow")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(Color.white87)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 38)
                                .padding(.bottom, 41)
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
                            walletAddress = copyString!
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
            .background(Color.followWalletBG)
            .edgesIgnoringSafeArea(.bottom)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Follow Wallet")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color.white)
            }
        }
    }
}
