//
//  CityAndTimeZoneModel.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/18/21.
//

import Foundation

struct CityAndTimeZoneModel: Codable, Hashable, Equatable {
    var city: String
    var country: String
    var timeZoneName: String
}
