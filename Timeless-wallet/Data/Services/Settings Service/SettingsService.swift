//
//  SettingsService.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/16/21.
//

import Foundation
import MapKit

class SettingsService {
    @UserDefault(
        key: ASSettings.Settings.titleLocation.key,
        defaultValue: ASSettings.Settings.titleLocation.defaultValue
    )
    var titleLocation: String
    // swiftlint:disable line_length
    var location: [String: NSNumber] {
        get {
            if let object = UserDefaults.standard.object(forKey: "general-settings-selected-location-weather") as? [String: NSNumber] {
                return object
            }
            return [:]
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "general-settings-selected-location-weather")
        }
    }
}

extension SettingsService {
    func locationSet(location: CLLocationCoordinate2D?, title: String?) {
        if let location = location, let title = title {
            let latitude = NSNumber(value: location.latitude)
            let longitude = NSNumber(value: location.longitude)
            let locationDict = ["latitude": latitude, "longitude": longitude]

            self.location = locationDict
            self.titleLocation = title
        } else {
            self.location = [:]
            self.titleLocation = ASSettings.Settings.titleLocation.defaultValue
        }
    }
}

extension SettingsService {
    static let shared = SettingsService()
}
