//
//  Formatters+Temperature.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 10/28/21.
//

import Foundation


extension Formatters {

    enum Temperature {
        static var temperatureDisplayTextFormatter: NumberFormatter {
             let formatter = NumberFormatter()
             formatter.numberStyle = .decimal
             formatter.maximumFractionDigits = 0
             return formatter
         }

        static func makeMeasurementFormatter() -> MeasurementFormatter {
            let formatter = MeasurementFormatter()
            formatter.locale = .current
            return formatter
        }
    }
}
