//
//  TimeZoneService.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/18/21.
//

import Foundation
enum TimeZoneParseIndex: Int {
    case cityIndex = 1
}

class TimeZoneService {
    private static var regions: [CityAndTimeZoneModel]?
    private static var timeZones: [TimeZoneModel] = []

    static func getTimeZones() -> [TimeZoneModel] {
        if timeZones.isEmpty {
            let regions = readRegionData()
            for region in regions {
                if let timeZone = TimeZone(identifier: region.timeZoneName) {
                    timeZones.append(TimeZoneModel(timeZoneId: region.timeZoneName, timeZone: timeZone, regionInfo: region))
                }
            }
            timeZones = timeZones.sorted(by: { $0.city.lowercased() < $1.city.lowercased() })
        }
        return timeZones
    }

    static func readRegionData() -> [CityAndTimeZoneModel] {
        if let sRegions = regions, !sRegions.isEmpty { return sRegions }
        if let path = Bundle.main.path(forResource: "CitiesAndTimeZones", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                do {
                    let cities = try decoder.decode([CityAndTimeZoneModel].self, from: data)
                    regions = cities
                    return cities
                }
            } catch {
                return []
            }
        }
        return []
    }

    static func getCurrentTimeZone() -> TimeZoneModel {
        let timeZone = TimeZone.current
        let regions = readRegionData()
        let region = regions.first(where: { $0.timeZoneName == timeZone.identifier })
        return TimeZoneModel(timeZoneId: timeZone.identifier, timeZone: timeZone, regionInfo: region)
    }

    static func getTimeZone(_ abbreviation: String) -> TimeZoneModel? {
        let timeZones = Self.getTimeZones()
        return timeZones.first(where: { $0.abbreviation == abbreviation })
    }

    static func getTimeZone(withIdentifier identifier: String) -> TimeZoneModel? {
        var timeZone = getTimeZones().first(where: { $0.timeZoneId == identifier })
        if timeZone == nil, let tzone = TimeZone(identifier: identifier) {
            timeZone = TimeZoneModel(timeZoneId: identifier, timeZone: tzone)
        }
        return timeZone
    }

    static func getTimeZone(withIdentifier identifier: String, in region: CityAndTimeZoneModel?) -> TimeZoneModel? {
        if let region = region {
            // if region is passed in, only return exact match in time zones list
            return getTimeZones().first(where: { $0.timeZoneId == identifier && $0.regionInfo == region })
        } else {
            return getTimeZone(withIdentifier: identifier)
        }
    }
    static func getTimeZone(withIdentifier identifier: String, in city: String?) -> TimeZoneModel? {
        if let city = city {
            return getTimeZones().first(where: { $0.timeZoneId == identifier && $0.city == city })
        } else {
            return getTimeZone(withIdentifier: identifier)
        }
    }

}
