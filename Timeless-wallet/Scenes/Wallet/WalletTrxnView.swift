//
//  WalletTrxnView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 10/01/2022.
//

import SwiftUI

struct WalletTrxnView: View {
    @ObservedObject var viewModel: ViewModel
    // MARK: - Properties
    @State private var renderUI = false
    @State private var searchTrxnTextField: UITextField?
    @State private var currentOffset: CGPoint = .zero
    private let today = Date()
    private let formatter = DateFormatter()
}

// MARK: - Body view
extension WalletTrxnView {
    var body: some View {
        ZStack(alignment: .top) {
            if viewModel.transactionGrouped != nil {
                if viewModel.transactionGrouped?.isEmpty ?? false {
                    noTransactionView
                } else {
                    transactionList
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            renderUI.toggle()
        }
        .loadingOverlay(isShowing: viewModel.transactionGrouped == nil ||
                        viewModel.loadingState == .paging)
    }
}

// MARK: - Subview
extension WalletTrxnView {
    private var noTransactionView: some View {
        VStack(spacing: 0) {
            Text(" ")
                .font(.system(size: 55, weight: .bold))
            Text("No Transactions yet")
                .tracking(0.7)
                .lineLimit(1)
                .font(.system(size: 18))
                .foregroundColor(Color.exchangeCurrency)
                .padding(.bottom, UIView.hasNotch ? 61 : 31)
                .offset(y: 3)
            if renderUI {
                loadingTrxn
            } else {
                loadingTrxn
            }
            Button(action: { onTapBuyReceiveSendSwap() }) {
                Rectangle()
                    .foregroundColor(Color.walletDetailBottomBtn)
                    .frame(height: 70)
                    .overlay(
                        HStack(spacing: 10) {
                            RoundedRectangle(cornerRadius: .infinity)
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color.xmarkBackground)
                                .overlay(
                                    Image.arrowTriangleSwap
                                        .resizable()
                                        .foregroundColor(Color.white)
                                        .frame(width: 21, height: 18)
                                )
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Buy, Receive, Send, Swap")
                                    .font(.system(size: 17))
                                    .foregroundColor(Color.white)
                                Text("Give it a Try!")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.walletDetailDeposit)
                            }
                        }
                            .padding(.leading, 12), alignment: .leading
                    )
                    .cornerRadius(12)
            }
            .padding(.horizontal, 22)
        }
    }

    private var transactionList: some View {
        BaseScrollView(
            header: { EmptyView() },
            content: {
                VStack(spacing: 30.5) {
                    RoundedRectangle(cornerRadius: .infinity)
                        .foregroundColor(Color.searchTrxnBG)
                        .frame(height: 41)
                        .overlay(
                            ZStack(alignment: .leading) {
                                HStack(spacing: 15) {
                                    Image.sendSearchIcon
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                    Text("Search")
                                        .tracking(-0.5)
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.sectionContactText)
                                        .opacity(viewModel.searchingText.isEmpty ? 1 : 0)
                                }
                                .padding(.leading, 15)
                                TextField("", text: $viewModel.searchingText)
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.white)
                                    .disableAutocorrection(true)
                                    .keyboardType(.alphabet)
                                    .accentColor(Color.timelessBlue)
                                    .padding(.leading, 47)
                                    .padding(.trailing, 16)
                                    .introspectTextField { textField in
                                        if searchTrxnTextField == nil {
                                            searchTrxnTextField = textField
                                        }
                                    }
                                    .onTapGesture {
                                        // AVOID KEYBOARD CLOSE
                                    }
                            }
                                .frame(height: 42)
                                .background(
                                    Color.almostClear
                                        .onTapGesture {
                                            searchTrxnTextField?.becomeFirstResponder()
                                        }
                                )
                        )
                        .padding(.horizontal, 15)
                    VStack(spacing: 37.5) {
                        if viewModel.transactionGrouped != nil {
                            ForEach(viewModel.searchedResults == nil ? (viewModel.transactionGrouped ?? []) :
                                        (viewModel.searchedResults ?? []), id: \.self) { list in
                                if let transactionData = list.first { $0.time.isDateInToday() } {
                                    ExpandCollapseView(title: "Today",
                                                       subTitle: Formatters.Date.MMMd.string(from: transactionData.time)) {
                                        transactionDetailList(list)
                                    }
                                } else if let transactionData = list.first { $0.time.isDateInWeek() } {
                                    ExpandCollapseView(title: "This week",
                                                       subTitle: Formatters.Date.MMMd.string(from: transactionData.time)) {
                                        transactionDetailList(list)
                                    }
                                } else if let transactionData = list.first { $0.time.isDateInMonth() } {
                                    ExpandCollapseView(title: "This month",
                                                       subTitle: Formatters.Date.MMMM.string(from: transactionData.time)) {
                                        transactionDetailList(list)
                                    }
                                } else if let transactionData = list.first { $0.time.isDateInLastMonth() } {
                                    ExpandCollapseView(title: "Last month",
                                                       subTitle: Formatters.Date.MMMMyyyy.string(from: transactionData.time)) {
                                        transactionDetailList(list)
                                    }
                                } else if let transactionData = list.first {
                                    ExpandCollapseView(title: Formatters.Date.MMMMyyyy.string(from: transactionData.time),
                                                       subTitle: "") {
                                        transactionDetailList(list)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top, 15)
                .padding(.bottom, UIView.hasNotch ? 0 : 35)
            },
            isShowEndText: .constant(false),
            scrolledToLoadMore: {
                if viewModel.isHasNextPage {
                    DispatchQueue.global(qos: .userInitiated).async {
                        viewModel.getTransactionHistory(isFetchNextPage: true)
                    }
                }
            },
            onOffsetChanged: { offset in
                currentOffset = offset
                UIApplication.shared.endEditing()
            }
        )
            .padding(.top, 15)
    }

    private var loadingTrxn: some View {
        LottieView(name: "trxnLottie", loopMode: .constant(.loop), isAnimating: .constant(true))
            .scaledToFill()
            .aspectRatio(255 / 236, contentMode: .fit)
            .padding(.horizontal, 76)
            .padding(.bottom, UIView.hasNotch ? 81 : 61)
            .offset(x: 1)
    }

    private func transactionDetailList(_ list: [TransactionInfo]) -> some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                ForEach(0 ..< list.count) { index in
                    transactionItem(list[index])
                        .background(Color.transactionDetailBG)
                    Rectangle()
                        .foregroundColor(Color.transactionDivider)
                        .frame(height: 1)
                        .padding(.horizontal, 10)
                }
            }
            Rectangle()
                .foregroundColor(Color.transactionDetailBG)
                .frame(height: 1)
        }
        .background(Color.transactionDetailBG)
        .cornerRadius(9)
        .padding(.horizontal, 16)
    }

    private func transactionItem(_ item: TransactionInfo) -> some View {
        let address = item.type == .received ? item.from.address : item.to?.address ?? item.from.address
        return HStack(alignment: .top, spacing: 0) {
            Image.transactionPig
                .resizable()
                .renderingMode(.original)
                .scaledToFill()
                .frame(width: 40, height: 40)
                .cornerRadius(.infinity)
                .padding(.trailing, 12)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(item.type.icon) \(item.type.title)")
                    .tracking(0.2)
                    .foregroundColor(Color.white.opacity(0.87))
                    .font(.system(size: 15))
                if item.type == .swap {
                    swapCurrencyView(item)
                } else {
                    WalletAddressView(address: address, trimCount: 6, tracking: 0.2)
                        .foregroundColor(Color.white.opacity(0.4))
                        .font(.system(size: 15))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
            Spacer(minLength: 10)
            if let amountString = item.amountString {
                VStack(alignment: .trailing, spacing: 2) {
                    amountStrView(item, amountString: amountString)
                }
            }
        }
        .padding(.leading, 10)
        .padding(.trailing, 18)
        .frame(height: 67.5)
    }

    private func swapCurrencyView(_ item: TransactionInfo) -> some View {
        let value: String = item.amountStringShort.components(separatedBy: " ")[0]
        let type: String = item.amountStringShort.components(separatedBy: " ")[1]

        return DisplayCurrencyView(
            value: "-\(value)",
            type: type,
            isSpacing: true,
            valueAfterType: false,
            font: .system(size: 15),
            color: Color.white.opacity(0.4),
            tracking: 0.2
        )
        .minimumScaleFactor(0.5)
    }

    private func amountStrView(_ item: TransactionInfo, amountString: String) -> some View {
        let value: String = amountString.components(separatedBy: " ")[0]
        let type: String = amountString.components(separatedBy: " ")[1]

        return DisplayCurrencyView(
            value: value,
            type: type,
            isSpacing: true,
            valueAfterType: false,
            font: .system(size: 15),
            color: Color.white.opacity(0.4),
            tracking: 0.2
        )
    }
}

// MARK: - Methods
extension WalletTrxnView {
    private func onTapBuyReceiveSendSwap() {
        showConfirmation(.exchange)
    }

    private func getDateString(_ date: Date, format: String) -> String {
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
