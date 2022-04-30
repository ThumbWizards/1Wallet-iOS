//
//  Date+ComparisonUtils.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 10/29/21.
//

import Foundation

extension Date {
    func isDateInToday(_ calendar: Calendar = .current) -> Bool {
        return calendar.isDateInToday(self)
    }

    func timeComponentIsSameAsOrAfter(component: DateComponents, using calendar: Calendar = .current) -> Bool {
        let compareDate = calendar.date(
            bySettingHour: component.hour ?? 0,
            minute: component.minute ?? 0,
            second: component.second ?? 0,
            of: self)!
        return self >= compareDate
    }
}
