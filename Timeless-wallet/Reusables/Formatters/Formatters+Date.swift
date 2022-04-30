//
//  Formatters+Date.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 10/29/21.
//

import Foundation

extension Formatters {
    enum Date {
        private static let dateFormatterQueue = DispatchQueue(label: "date-formatter-helper-queue")
        private static var dateFormatters = [String: DateFormatter]()
        private static var calendar = Calendar.current
        private static func getDateFormatter(function: String = #function) -> DateFormatter {
            return dateFormatterQueue.sync {
                var formatter: DateFormatter
                if let fmt = dateFormatters[function] {
                    formatter = fmt
                } else {
                    formatter = DateFormatter()
                    formatter.amSymbol = "am"
                    formatter.pmSymbol = "pm"
                    dateFormatters[function] = formatter
                }
                // Setting timeZone is not expensive if the time zone doesn't change,
                // so it's fine to repeat this everytime we need to get the DateFormatter instance
                formatter.timeZone = .current
                return formatter
            }
        }

        /// Displays weekday text for a date (e.g: "Monday", "Tuesday")
        static var weekday: DateFormatter {
            let formatter = getDateFormatter()
            formatter.dateFormat = "EEEE"

            return formatter
        }

        static var MMMd: DateFormatter {
            let formatter = getDateFormatter()
            formatter.dateFormat = "MMM d"

            return formatter
        }

        static var onlyTime: DateFormatter {
            let formatter = getDateFormatter()
            formatter.dateFormat = "hh:mm"

            return formatter
        }

        static var MMMdyyyy: DateFormatter {
            let formatter = getDateFormatter()
            formatter.dateFormat = "MMM d, yyyy"

            return formatter
        }

        static var MMMMyyyy: DateFormatter {
            let formatter = getDateFormatter()
            formatter.dateFormat = "MMMM yyyy"

            return formatter
        }

        static var MMMM: DateFormatter {
            let formatter = getDateFormatter()
            formatter.dateFormat = "MMMM"
            return formatter
        }

        static var daoExpireDate: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy, HH:mm:ss"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            return formatter
        }

        static var ddMMyyyyHHmmssz: DateFormatter {
            let formatter = getDateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH:mm:ss z"
            return formatter
        }

        static var MMMdyyyyhhmmssaz: DateFormatter {
            let formatter = getDateFormatter()
            formatter.dateFormat = "MMM d, yyyy — hh:mm:ssa z"
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            return formatter
        }

        static var DAOCreateDate: DateFormatter {
            let formatter = getDateFormatter()
            formatter.dateFormat = "yyyy-mm-dd HH:mm:ss z"
            return formatter
        }

        static var safeCreateDate: DateFormatter {
            let formatter = getDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            return formatter
        }

        static var mediumDateFormat: DateFormatter {
            let formatter = getDateFormatter()
            formatter.timeStyle = .none
            formatter.dateStyle = .medium
            return formatter
        }

    }
}
