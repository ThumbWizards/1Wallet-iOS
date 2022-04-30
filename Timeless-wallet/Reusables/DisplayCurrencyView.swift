//
//  ShowHideCurrencyView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 27/01/2022.
//

import SwiftUI

struct DisplayCurrencyView {
    // MARK: - Input Parameters
    var value = ""
    var type: String
    var isSpacing: Bool
    var valueAfterType: Bool
    var font: Font
    var color: Color
    var decimalColor: Color?
    var tracking: CGFloat = 0
    var currencyStr: String?
    var decimalCurrency: String?

    // MARK: - Properties
    @AppStorage(ASSettings.Settings.showCurrencyWallet.key)
    private var showCurrencyWallet = ASSettings.Settings.showCurrencyWallet.defaultValue

    // MARK: - Computed variables
    private var isDecimalOpacity: Bool {
        currencyStr != nil && decimalCurrency != nil
    }

    private var typeText: String {
        valueAfterType ? "\(type)\(isSpacing ? " " : "")" : "\(isSpacing ? " " : "")\(type)"
    }
}

// MARK: - Bodyview
extension DisplayCurrencyView: View {
    var body: some View {
        HStack(spacing: 0) {
            if valueAfterType {
                typeView
                valueView
            } else {
                valueView
                typeView
            }
        }
        .font(font)
        .lineLimit(1)
        .foregroundColor(color)
    }
}

// MARK: - Subview
extension DisplayCurrencyView {
    private var typeView: some View {
        Text(typeText).tracking(tracking)
    }

    private var valueView: some View {
        HStack(spacing: 0) {
            if showCurrencyWallet {
                if isDecimalOpacity {
                    Text(currencyStr ?? "").tracking(tracking)
                    + Text(decimalCurrency ?? "").tracking(tracking).foregroundColor(decimalColor != nil ? decimalColor : color.opacity(0.6))
                } else {
                    Text(value).tracking(tracking)
                }
            } else {
                Text("•••••").tracking(tracking).foregroundColor(color.opacity(0.6))
            }
        }
    }
}
