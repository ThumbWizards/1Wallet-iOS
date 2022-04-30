//
//  Float.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 21/12/21.
//

import Foundation

extension Float {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places: Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}
