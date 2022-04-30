//
//  Date+ComparisonUtils.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 10/29/21.
//

import Foundation
import StreamChatUI

extension Date {
    static var todaysDayText: String {
        Formatters.Date.weekday.string(from: Date())
    }

    func isDateInToday(_ calendar: Calendar = .current) -> Bool {
        return calendar.isDateInToday(self)
    }

    func isDateInWeek(_ calendar: Calendar = .current) -> Bool {
        return calendar.isDayInCurrentWeek(date: self) ?? false
    }

    func isDateInMonth(_ calendar: Calendar = .current) -> Bool {
        return calendar.isDayInCurrentMonth(date: self) ?? false
    }

    func isDateInLastMonth(_ calendar: Calendar = .current) -> Bool {
        return calendar.isDateLastMonth(date: self)
    }

    func timeComponentIsSameAsOrAfter(component: DateComponents, using calendar: Calendar = .current) -> Bool {
        let compareDate = calendar.date(
            bySettingHour: component.hour ?? 0,
            minute: component.minute ?? 0,
            second: component.second ?? 0,
            of: self)!
        return self >= compareDate
    }

    func toRedPacketExpireDate() -> String {
        let endTime = self + TimeInterval(StreamChatUI.Constants.redPacketExpireTime * 60)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: endTime)
    }

    var isPastDate: Bool {
        return self < Date()
    }
    
    var ticks: Double {
        return timeIntervalSince1970
    }

    func withAddedMinutes(minutes: Double) -> Date {
        addingTimeInterval(minutes * 60)
    }

    func withAddedHours(hours: Double) -> Date {
        withAddedMinutes(minutes: hours * 60)
    }
}
