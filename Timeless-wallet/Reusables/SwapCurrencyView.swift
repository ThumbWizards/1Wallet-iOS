//
//  SwapCurrencyView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 27/01/2022.
//

import SwiftUI

struct SwapCurrencyView {
    // MARK: - Input Parameters
    var value1 = ""
    var value2 = ""
    var usdStr: String?
    var decimalUSD: String?
    var oneStr: String?
    var decimalONE: String?
    var type1: String
    var type2: String
    var isSpacing1: Bool
    var isSpacing2: Bool
    var valueAfterType: Bool
    var font: Font
    var color = Color.white
    var tracking: CGFloat = 0
    var decimalColor: Color?

    // MARK: - Properties
    @AppStorage(ASSettings.Settings.walletBalance.key)
    private var walletBalance = ASSettings.Settings.walletBalance.defaultValue
}

// MARK: - Bodyview
extension SwapCurrencyView: View {
    var body: some View {
        if walletBalance {
            DisplayCurrencyView(
                value: value1, type: type1, isSpacing: isSpacing1,
                valueAfterType: valueAfterType, font: font, color: color, decimalColor: decimalColor, tracking: tracking,
                currencyStr: usdStr, decimalCurrency: decimalUSD
            )
        } else {
            DisplayCurrencyView(
                value: value2, type: type2, isSpacing: isSpacing2,
                valueAfterType: valueAfterType, font: font, color: color, decimalColor: decimalColor, tracking: tracking,
                currencyStr: oneStr, decimalCurrency: decimalONE
            )
        }
    }
}
