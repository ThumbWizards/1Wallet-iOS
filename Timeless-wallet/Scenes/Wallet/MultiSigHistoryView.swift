//
//  MultiSigHistoryView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 28/01/2022.
//

import SwiftUI

struct MultiSigHistoryView {
    // MARK: - Input Parameters
    let data: [[TransactionCustomType]]?

    // MARK: - Properties
}

// MARK: - Bodyview
extension MultiSigHistoryView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 37.5) {
                if data != nil {
                    ForEach(data ?? [], id: \.self) { list in
                        if let transactionData = list.first { $0.info.time.isDateInToday() } {
                            ExpandCollapseView(
                                title: "Today",
                                subTitle: Formatters.Date.MMMd.string(from: transactionData.info.time)) {
                                    historyList(list)
                                }
                        } else if let transactionData = list.first { $0.info.time.isDateInWeek() } {
                            ExpandCollapseView(
                                title: "This week",
                                subTitle: Formatters.Date.MMMd.string(from: transactionData.info.time)) {
                                    historyList(list)
                                }
                        } else if let transactionData = list.first { $0.info.time.isDateInMonth() } {
                            ExpandCollapseView(
                                title: "This month",
                                subTitle: Formatters.Date.MMMM.string(from: transactionData.info.time)) {
                                    historyList(list)
                                }
                        } else if let transactionData = list.first { $0.info.time.isDateInLastMonth() } {
                            ExpandCollapseView(
                                title: "Last month",
                                subTitle: Formatters.Date.MMMMyyyy.string(from: transactionData.info.time)) {
                                    historyList(list)
                                }
                        } else if let transactionData = list.first {
                            ExpandCollapseView(
                                title: Formatters.Date.MMMMyyyy.string(from: transactionData.info.time),
                                subTitle: "") {
                                    historyList(list)
                                }
                        }
                    }
                }
            }
            .padding(.top, 17)
            .padding(.bottom, UIView.hasNotch ? UIView.safeAreaBottom : 35)
        }
        .loadingOverlay(isShowing: data == nil)
    }
}

// MARK: - Subview
extension MultiSigHistoryView {
    private func historyList(_ list: [TransactionCustomType]) -> some View {
        VStack(spacing: 10) {
            ForEach(list, id: \.self) { item in
                TransactionCustomView(item: item)
                    .padding(.top, 16)
                    .padding(.bottom, 13)
                    .padding(.leading, 10)
                    .padding(.trailing, 20)
                    .background(Color.sendTextFieldBG)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 15)
    }
}
