//
//  SendModal.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 2/22/22.
//

import SwiftUI

struct SendModal {
    @ObservedObject var viewModel: SendView.ViewModel
    @State private var searchString = ""
}

extension SendModal {
    private var listWalletPay: [TokenModel] {
        return searchString.isEmpty ? viewModel.listToken :
        viewModel.listToken.filter({ $0.symbol?.lowercased().contains(searchString.lowercased()) ?? false })
    }
}

extension SendModal: View {
    var body: some View {
        ZStack(alignment: .top) {
            Color.confirmationBG
            VStack(spacing: 0) {
            ZStack {
                Text("You Send")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.white)
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image.closeBackup
                            .foregroundColor(Color.white)
                            .frame(width: 30, height: 30)
                    }
                    Spacer()
                }
                .padding(.leading, 20)
            }
            .padding(.bottom, 35)
            HStack(spacing: 0) {
                Image.search
                    .resizable()
                    .frame(width: 14, height: 14)
                    .foregroundColor(Color.white87)
                    .padding(.leading, 11)
                ZStack(alignment: .leading) {
                    TextField("", text: $searchString)
                        .font(.system(size: 16))
                        .padding(.leading, 10)
                        .foregroundColor(Color.white)
                        .accentColor(Color.timelessBlue)
                        .zIndex(1)
                    Text("Search")
                        .foregroundColor(Color.white60)
                        .font(.system(size: 16))
                        .padding(.leading, 10)
                        .opacity(searchString.isBlank ? 1 : 0)
                }
                .height(44)
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width - 32, height: 36)
            .background(Color.textFieldHNS
                            .cornerRadius(10))
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(listWalletPay, id: \.self) { token in
                        Button {
                            viewModel.selectedToken = token
                            viewModel.resetInitialData()
                            dismiss()
                        } label: {
                            HStack {
                                iconView(token)
                                VStack(alignment: .leading, spacing: 5) {
                                    if let symbol = token.symbol {
                                        Text(symbol)
                                            .font(.system(size: 18, weight: .regular))
                                            .foregroundColor(Color.white60)
                                    }
                                    DisplayCurrencyView(
                                        value: Utils.formatBalance(token.balance),
                                        type: "Balance:",
                                        isSpacing: true,
                                        valueAfterType: true,
                                        font: .system(size: 14),
                                        color: Color.white.opacity(0.6)
                                    )
                                }
                                Spacer()
                                Image.checkmark
                                    .foregroundColor(Color.timelessBlue)
                                    .opacity(viewModel.selectedToken == token ? 1 : 0)
                            }
                            .padding(.leading, 25)
                            .padding(.trailing, 22)
                        }
                    }
                }
                .padding(.top, 35)
                .padding(.bottom, UIView.safeAreaBottom + 15)
            }
            .simultaneousGesture(hideKeyBoardGesture)
            }
            .padding(.top, 15)
        }
        .ignoresSafeArea()
    }
}

extension SendModal {
    private func iconView(_ token: TokenModel) -> some View {
        Group {
            if token.key != nil {
                Image.oneIcon
                    .resizable()
                    .frame(width: 36, height: 36)
            } else if let icon = token.icon,
               let url = URL(string: icon) {
                MediaResourceView(
                    for: MediaResource(
                        for: MediaResourceWebImage(
                            url: url,
                            isAnimated: true,
                            targetSize: TargetSize(
                                width: 36,
                                height: 36))),
                       placeholder: ProgressView()
                        .progressViewStyle(.circular)
                        .eraseToAnyView(),
                       isPlaying: .constant(true))
                    .frame(width: 36, height: 36)
                    .cornerRadius(.infinity)
            }
        }
    }
}

extension SendModal {
    private var hideKeyBoardGesture: some Gesture {
        DragGesture()
            .onChanged({ (_) in
                UIApplication.shared.endEditing()
            })
    }
}
