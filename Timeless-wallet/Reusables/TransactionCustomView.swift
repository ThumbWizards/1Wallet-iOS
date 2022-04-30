//
//  TransactionCustomView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 28/01/2022.
//

import SwiftUI

struct TransactionCustomView {
    // MARK: - Input Parameters
    var item: TransactionCustomType
    var isQueue = false
    var spacingHorizontal: CGFloat = 12
    var pigSize: CGFloat = 40

    // MARK: - Computed Variables
    private var textStatus: String {
        if let statusDisplay = item.status {
            switch statusDisplay {
            case .success: return "Success"
            case .failed: return "Failed"
            }
        }
        return ""
    }

    private var address: String {
        if item.info.type == .received {
            return item.info.from.address.trimStringByFirstLastCount(firstCount: 5, lastCount: 6)
        } else {
            return (item.info.to?.address ?? item.info.from.address).trimStringByFirstLastCount(firstCount: 5, lastCount: 6)
        }
    }
}

// MARK: - Body view
extension TransactionCustomView: View {
    var body: some View {
        HStack(alignment: item.status != nil ? .top : .center, spacing: spacingHorizontal) {
            Image.transactionPig
                .resizable()
                .renderingMode(.original)
                .scaledToFill()
                .frame(width: pigSize, height: pigSize)
                .cornerRadius(.infinity)
            VStack(alignment: .leading, spacing: 0) {
                firstLineView
                secondLineView
                if let statusDisplay = item.status {
                    thirdLineView(statusDisplay)
                }
            }
        }
    }
}

// MARK: - Subview
extension TransactionCustomView {
    private var firstLineView: some View {
        HStack(spacing: 0) {
            titleView
            Spacer(minLength: 5)
            if let amountString = item.info.amountString {
                DisplayCurrencyView(
                    value: amountString.components(separatedBy: " ")[0],
                    type: amountString.components(separatedBy: " ")[1],
                    isSpacing: true,
                    valueAfterType: false,
                    font: .system(size: 15),
                    color: Color.white.opacity(0.4),
                    tracking: 0.2
                )
            }
        }
        .padding(.bottom, 1)
    }

    private var secondLineView: some View {
        HStack(spacing: 0) {
            if item.info.type == .swap {
                DisplayCurrencyView(
                    value: "-\(item.info.amountStringShort.components(separatedBy: " ")[0])",
                    type: item.info.amountStringShort.components(separatedBy: " ")[1],
                    isSpacing: true,
                    valueAfterType: false,
                    font: .system(size: 15),
                    color: Color.white.opacity(0.4),
                    tracking: 0.2
                )
                .minimumScaleFactor(0.5)
            } else {
                Text(address)
                    .font(.system(size: 15))
                    .foregroundColor(Color.white.opacity(0.4))
            }
            Spacer(minLength: 5)
            if item.info.type != .contract {
                DisplayCurrencyView(
                    value: "1",
                    type: "$",
                    isSpacing: false,
                    valueAfterType: true,
                    font: .system(size: 15),
                    color: Color.white.opacity(0.4),
                    tracking: 0.2
                )
            }
        }
        .padding(.bottom, 4)
    }

    private func thirdLineView(_ statusDisplay: TransactionStatus) -> some View {
        return HStack(spacing: 0) {
            Text(Formatters.Date.ddMMyyyyHHmmssz.string(from: item.info.time))
                .lineLimit(1)
                .font(.system(size: 13))
                .foregroundColor(Color.white.opacity(0.4))
            Spacer(minLength: 5)
            Text(textStatus)
                .font(.system(size: 13))
                .foregroundColor(statusDisplay == .success ? Color.positiveColor : Color.confirmationNo)
                .opacity(0.8)
        }
    }

    private var titleView: some View {
        var text = item.info.type.title
        if isQueue {
            switch item.info.type {
            case .received: text = "Receive"
            case .send: text = "Send"
            case .contract: text = "Contract Execution"
            case .swap: text = "Swap"
            }
        }

        return Text("\(item.info.type.icon) \(text)")
            .tracking(0.2)
            .font(.system(size: 15))
            .foregroundColor(Color.white.opacity(0.87))
    }
}

enum TransactionStatus {
    case success
    case failed
}
