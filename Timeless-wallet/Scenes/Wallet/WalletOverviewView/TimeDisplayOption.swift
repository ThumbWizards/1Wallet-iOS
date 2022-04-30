//
//  TimeDisplayOption.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 1/20/22.
//

import Foundation

enum TimeDisplayOption: CaseIterable {
    case hourly
    case daily
    case weekly
    case monthly
    case yearly

    func dateForrmatter() -> DateFormatter {
        switch self {
        case .hourly, .daily:
            return Formatters.Date.onlyTime
        default:
            return Formatters.Date.MMMdyyyy
        }
    }

    var title: String {
        switch self {
        case .hourly:
            return "1H"
        case .daily:
            return "1D"
        case .weekly:
            return "1W"
        case .monthly:
            return "1M"
        case .yearly:
            return "1Y"
        }
    }

    var range: (fromTime: Int, toTime: Int) {
        let calendar = Calendar(identifier: .gregorian)
        switch self {
        case .hourly:
            return (fromTime: Int(calendar.date(byAdding: .hour, value: -1, to: Date())!.timeIntervalSince1970),
                    toTime: Int(Date().timeIntervalSince1970))
        case .daily:
            return (fromTime: Int(calendar.date(byAdding: .day, value: -1, to: Date())!.timeIntervalSince1970),
                    toTime: Int(Date().timeIntervalSince1970))
        case .weekly:
            return (fromTime: Int(calendar.date(byAdding: .day, value: -7, to: Date())!.timeIntervalSince1970),
                    toTime: Int(Date().timeIntervalSince1970))
        case .monthly:
            return (fromTime: Int(calendar.date(byAdding: .month, value: -1, to: Date())!.timeIntervalSince1970),
                    toTime: Int(Date().timeIntervalSince1970))
        case .yearly:
            return (fromTime: Int(calendar.date(byAdding: .year, value: -1, to: Date())!.timeIntervalSince1970),
                    toTime: Int(Date().timeIntervalSince1970))
        }
    }
}
