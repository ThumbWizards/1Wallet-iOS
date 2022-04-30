//
//  Formatters+Currency.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 10/01/22.
//

import Foundation

extension Formatters {

    enum Currency {
        static var oneFractionDigitFormatter: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            formatter.usesGroupingSeparator = false
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 3
            formatter.maximumFractionDigits = 3
            formatter.roundingMode = .down
            return formatter
        }

        static var currencyFractionDigitFormatter: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            formatter.usesGroupingSeparator = false
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 4
            formatter.maximumFractionDigits = 4
            formatter.roundingMode = .down
            return formatter
        }

        static var twoFractionDigitFormatter: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            formatter.roundingMode = .down
            return formatter
        }
    }
}
