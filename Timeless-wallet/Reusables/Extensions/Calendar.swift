//
//  Calendar.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 1/20/22.
//

import Foundation

extension Calendar {
    func isDayInCurrentWeek(date: Date) -> Bool? {
        let currentComponents = Calendar.current.dateComponents([.weekOfYear], from: Date())
        let dateComponents = Calendar.current.dateComponents([.weekOfYear], from: date)
        guard let currentWeekOfYear = currentComponents.weekOfYear,
                let dateWeekOfYear = dateComponents.weekOfYear else { return nil }
        return currentWeekOfYear == dateWeekOfYear
    }

    func isDayInCurrentMonth(date: Date) -> Bool? {
        let currentComponents = Calendar.current.dateComponents([.month], from: Date())
        let dateComponents = Calendar.current.dateComponents([.month], from: date)
        guard let currentWeekOfYear = currentComponents.month, let dateWeekOfYear = dateComponents.month else { return nil }
        return currentWeekOfYear == dateWeekOfYear
    }

    func isDateLastMonth(date: Date) -> Bool {
        guard let lastMonth = self.date(byAdding: DateComponents(month: -1), to: Date()) else {
            return false
        }
        return isDate(date, equalTo: lastMonth, toGranularity: .month)
    }
}
