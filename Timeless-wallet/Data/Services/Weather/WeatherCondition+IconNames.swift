//
//  WeatherCondition+IconNames.swift
//  Timeless-iOS
//
// Created by Brian Sipple on 4/21/20.
// Copyright © 2020 Timeless. All rights reserved.
//

import Foundation
import TimelessWeather


extension WeatherCondition {

    private var iconBaseName: String {
        switch self {
        case .clearDay:
            return "clear_day"
        case .clearNight:
            return "clear_night"
        case .partlyCloudyDay:
            return "partly_cloudy_day"
        case .partlyCloudyNight:
            return "partly_cloudy_night"
        case .cloudyDay,
             .cloudyNight:
            return "cloudy"
        case .dust:
            return "dust"
        case .fog:
            return "fog"
        case .rain:
            return "rain"
        case .shower:
            return "shower"
        case .snow:
            return "snow"
        case .thunderstorm:
            return "thunderstorm"
        case .tornado:
            return "tornado"
        }
    }


    var filledIconName: String {
        "weather_condition_\(iconBaseName)_icon_filled"
    }


    var sfSymbolName: String {
        switch self {
        case .clearDay:
            return "sun.max.fill"
        case .clearNight:
            return "moon.stars.fill"
        case .partlyCloudyDay:
            return "cloud.sun"
        case .partlyCloudyNight:
            return "cloud.moon"
        case .cloudyDay,
             .cloudyNight:
            return "cloud"
        case .dust:
            return "sun.dust.fill"
        case .fog:
            return "cloud.fog"
        case .rain:
            return "cloud.rain"
        case .shower:
            return "cloud.heavyrain"
        case .snow:
            return "snow"
        case .thunderstorm:
            return "cloud.bolt.rain"
        case .tornado:
            return "tornado"
        }
    }
}
