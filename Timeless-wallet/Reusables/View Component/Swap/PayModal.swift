//
//  PayModal.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/16/21.
//

import SwiftUI

struct PayModal {
    @ObservedObject var swapViewModel: SwapView.ViewModel
    @State private var searchString = ""
}

extension PayModal {
    private var listWalletPay: [TokenModel] {
        return searchString.isEmpty ? swapViewModel.model :
        swapViewModel.model.filter({ $0.symbol?.lowercased().contains(searchString.lowercased()) ?? false })
    }
}

extension PayModal: View {
    var body: some View {
        ZStack(alignment: .top) {
            Color.confirmationBG
            VStack(spacing: 0) {
                ZStack {
                    Text("You Pay")
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
                        ForEach(listWalletPay, id: \.self) { model in
                            Button {
                                guard swapViewModel.selectedPay != model else {
                                    dismiss()
                                    return
                                }
                                if model.key == nil {
                                    swapViewModel.selectedGot = swapViewModel.model.first(where: { $0.key != nil })
                                } else {
                                    swapViewModel.selectedGot = swapViewModel.selectedPay
                                }
                                swapViewModel.selectedPay = model
                                swapViewModel.resetInitialData()
                                dismiss()
                            } label: {
                                HStack {
                                    if let icon = model.icon,
                                       let url = URL(string: icon) {
                                        MediaResourceView(
                                            for: MediaResource(
                                                for: MediaResourceWebImage(
                                                    url: url,
                                                    isAnimated: true,
                                                    targetSize: TargetSize(
                                                        width: 36,
                                                        height: 36))),
                                               placeholder: swapViewModel.loadingIconView,
                                               isPlaying: .constant(true))
                                            .frame(width: 36, height: 36)
                                            .cornerRadius(.infinity)
                                    }
                                    VStack(alignment: .leading, spacing: 5) {
                                        if let symbol = model.symbol {
                                            Text(symbol)
                                                .font(.system(size: 18, weight: .regular))
                                                .foregroundColor(Color.white60)
                                        }
                                        DisplayCurrencyView(
                                            value: Utils.formatBalance(model.balance),
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
                                        .opacity(swapViewModel.selectedPay == model ? 1 : 0)
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

extension PayModal {
    private var hideKeyBoardGesture: some Gesture {
        DragGesture()
            .onChanged({ (_) in
                UIApplication.shared.endEditing()
            })
    }
}
