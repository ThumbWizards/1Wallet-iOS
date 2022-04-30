//
//  TimeZoneModel.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/18/21.
//

import Foundation

struct TimeZoneModel: Hashable, Equatable {
    var timeZoneId: String
    var timeZoneName: String
    var city: String
    var country: String
    var abbreviation: String
    var secondsFromGMT: Int

    private(set) var timeZone: TimeZone
    private(set) var regionInfo: CityAndTimeZoneModel?

    init(timeZoneId: String, timeZone: TimeZone, regionInfo: CityAndTimeZoneModel? = nil) {
        // TODO: Code has been refactored to make it super clear that timeZoneId passed in doesn't do anything - remove it!
        let abbreviation = timeZone.abbreviation() ?? ""
        let seconds = timeZone.secondsFromGMT()
        let timeZoneComponents = timeZone.identifier.components(separatedBy: "/")
        let zone = timeZoneComponents.first ?? ""
        var city = timeZoneComponents.last ?? ""
        city = city.replacingOccurrences(of: "_", with: " ")

        self.timeZone = timeZone
        self.regionInfo = regionInfo

        self.timeZoneId = timeZone.identifier
        self.timeZoneName = zone
        self.city = city
        self.country = zone
        self.abbreviation = abbreviation
        self.secondsFromGMT = seconds

        if let region = regionInfo {
            self.city = region.city
            self.country = region.country
        }
    }
}

extension TimeZoneModel: Codable {
    enum CodingKeys: String, CodingKey {
        case timeZoneId
        case regionInfo
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self),
            timeZoneId = try values.decode(String.self, forKey: CodingKeys.timeZoneId),
            regionInfo = try values.decode(CityAndTimeZoneModel?.self, forKey: CodingKeys.regionInfo)
        self = TimeZoneService.getTimeZone(withIdentifier: timeZoneId, in: regionInfo)!
    }

    init?() {
        return nil
    }
}
