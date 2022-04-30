//
//  Decimal.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 10/01/22.
//

import Foundation

extension Decimal {
    var significantFractionalDecimalDigits: Int {
        return max(-exponent, 0)
    }
}
