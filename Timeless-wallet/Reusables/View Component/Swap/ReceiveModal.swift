//
//  ReceiveModal.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/17/21.
//

import SwiftUI

struct ReceiveModal {
    @ObservedObject var swapViewModel: SwapView.ViewModel
    @State private var searchString = ""
}

extension ReceiveModal {
    private var listWalletReceive: [TokenModel] {
        return searchString.isEmpty ? swapViewModel.model :
        swapViewModel.model.filter({ $0.symbol?.lowercased().contains(searchString.lowercased()) ?? false })
    }
}

extension ReceiveModal: View {
    var body: some View {
        ZStack(alignment: .top) {
            Color.confirmationBG
            VStack(spacing: 0) {
                headerView
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
                        ForEach(listWalletReceive, id: \.self) { model in
                            Button {
                                guard swapViewModel.selectedGot != model else {
                                    dismiss()
                                    return
                                }
                                if model.key == nil {
                                    swapViewModel.selectedPay = swapViewModel.model.first(where: { $0.key != nil })
                                } else {
                                    swapViewModel.selectedPay = swapViewModel.selectedGot
                                }
                                swapViewModel.selectedGot = model
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
                                        if let name = model.name {
                                            Text(name)
                                                .font(.system(size: 18, weight: .regular))
                                                .foregroundColor(Color.white60)
                                        }
                                        if let symbol = model.symbol {
                                            Text(symbol)
                                                .font(.system(size: 14, weight: .regular))
                                                .foregroundColor(Color.white60)
                                        }
                                    }
                                    Spacer()
                                    Image.checkmark
                                        .foregroundColor(Color.timelessBlue)
                                        .opacity(swapViewModel.selectedGot == model ? 1 : 0)
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

extension ReceiveModal {
    private var headerView: some View {
        ZStack {
            Text("You Get")
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
    }
}

extension ReceiveModal {
    private var hideKeyBoardGesture: some Gesture {
        DragGesture()
            .onChanged({ (_) in
                UIApplication.shared.endEditing()
            })
    }
}
