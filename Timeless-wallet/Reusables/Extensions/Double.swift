//
//  Double.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 21/12/21.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
