//
//  DateFormatterExtensions.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 23/10/21.
//

import Foundation

extension DateFormatter {
    convenience init(_ format: String) {
        self.init()
        dateFormat = format
    }
}
