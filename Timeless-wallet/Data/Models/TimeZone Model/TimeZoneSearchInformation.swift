//
//  TimeZoneSearchInformation.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/18/21.
//

import SwiftUI
import Combine

class TimeZoneSearchInformation: ObservableObject {
    @Published var searchingText: String = ""
    @Published var searchedResults = [TimeZoneModel]()
    private var searchingCancellable: AnyCancellable?
    private var listTimeZones = [TimeZoneModel]()

    init() {
        listTimeZones = TimeZoneService.getTimeZones()
        getTimeZone(text: searchingText)

        searchingCancellable = AnyCancellable(
            $searchingText
                .debounce(for: 0.3, scheduler: DispatchQueue.global())
                .removeDuplicates()
                .sink { text in self.getTimeZone(text: text) }
        )
    }

    private func getTimeZone(text: String) {
        if text.isEmpty {
            DispatchQueue.main.async {
                self.searchedResults.removeAll()
            }
        } else {
            let searchedResults = self.listTimeZones.filter({$0.timeZoneName.containsLowercasedString(text) ||
                $0.city.containsLowercasedString(text) ||
                $0.abbreviation.containsLowercasedString(text) ||
                $0.country.containsLowercasedString(text) ||
                $0.timeZoneId.containsLowercasedString(text)
            })

            DispatchQueue.main.async {
                self.searchedResults = searchedResults
            }
        }
    }

    static func getAbbreviation(for timeZoneId: String) -> String? {
        TimeZoneService.getTimeZones()
            .first(where: { $0.timeZoneId.containsLowercasedString(timeZoneId) })?
            .abbreviation
    }
}
