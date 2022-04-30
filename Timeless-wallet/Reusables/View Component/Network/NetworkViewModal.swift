//
//  NetworkViewModal.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 1/14/22.
//

import SwiftUI

struct NetworkViewModal {
    @State private var selectedWallet: (avatar: Image, name: String, amount: Double?) =
    (avatar: Image("nikola710_avatar"), name: "All Network", amount: 200.44)
    @State private var isFirst = false
    @AppStorage(ASSettings.Network.network.key)
    private var networkName = ASSettings.Network.network.defaultValue
    var totalAmount: Double?
}

extension NetworkViewModal: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                headerView
                listNetwork
            }
            .height(486)
            buttonClose
        }
    }
}

extension NetworkViewModal {
    private var listTemp: [(avatar: Image, name: String, amount: Double?)]? {
        var list = [(avatar: Image, name: String, amount: Double?)]()
        list.append((avatar: Image("nikola710_avatar"), name: "All Network", amount: totalAmount))
        list.append((avatar: Image("nghiavo_avatar"),
                          name: "Harmony ONE",
                          amount: totalAmount))
        list.append((avatar: Image("vinhdang_avatar"),
                          name: "BSC",
                          amount: 0))
        list.append((avatar: Image("vinhdang_avatar"),
                          name: "Solana",
                          amount: 0))
        if !isFirst {
            DispatchQueue.main.async {
                if networkName.isEmpty {
                    selectedWallet = list.first!
                } else {
                    if let select = list.first(where: { $0.name == networkName }) {
                        selectedWallet = select
                    }
                }
                isFirst.toggle()
            }
        }
        return list
    }
}

extension NetworkViewModal {
    private var headerView: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Choose Network")
                    .tracking(-0.3)
                    .font(.system(size: 20))
                    .foregroundColor(Color.white)
                Text("@\(Wallet.currentWallet?.name ?? "")")
                    .font(.system(size: 15))
                    .foregroundColor(Color.white60)
                    .padding(.trailing, 68)
            }
            Spacer()
        }
        .padding(.top, 38)
        .padding(.leading, 26)
        .padding(.bottom, 15)
    }

    private var listNetwork: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 9.5) {
                if let list = listTemp {
                    ForEach(list.indices) { index in
                        Button(action: {
                            self.selectedWallet = list[index]
                            networkName = list[index].name
                            onTapClose()
                        }) {
                            HStack {
                                list[index].avatar
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 45, height: 45)
                                    .cornerRadius(.infinity)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(list[index].name)
                                        .font(.system(size: 15))
                                        .foregroundColor(Color.white87)
                                        .lineLimit(1)
                                    DisplayCurrencyView(
                                        value: "\(formatCurrency(list[index].amount))",
                                        type: "$",
                                        isSpacing: false,
                                        valueAfterType: true,
                                        font: .system(size: 12),
                                        color: Color.white.opacity(0.6)
                                    )
                                }
                                Spacer()
                                Image.checkmark
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.checkMarkAccount)
                                    .opacity(self.selectedWallet == list[index] ? 1 : 0)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.keyboardAccessoryBG)
                            .cornerRadius(10)
                            .overlay(self.selectedWallet == list[index] ?
                                     RoundedRectangle(cornerRadius: 8).stroke(Color.checkMarkAccount,
                                                                              lineWidth: 1)
                                        .eraseToAnyView() :
                                        EmptyView().eraseToAnyView())
                            .opacity((index == 2 || index == 3) ? 0.3 : 1)
                            .padding(.horizontal, 16)
                        }
                        .disabled((index == 2 || index == 3))
                    }
                }
            }
            .padding(.top, 15)
        }
    }

    private var buttonClose: some View {
        Button(action: { onTapClose() }) {
            Image.closeSmall
                .resizable()
                .frame(width: 25, height: 25)
        }
        .padding(.top, 36)
        .padding(.trailing, 31)
    }
}

extension NetworkViewModal {
    private func onTapClose() {
        hideConfirmationSheet()
    }

    private func formatCurrency(_ number: Double?) -> String {
        if let number = number {
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            if let formattedBalance = formatter.string(from: number as NSNumber) {
                return formattedBalance
            }
        }
        return "0.00"
    }
}
