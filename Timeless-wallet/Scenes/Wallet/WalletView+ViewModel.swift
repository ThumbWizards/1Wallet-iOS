//
//  WalletView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/1/21.
//

import Foundation
import TimelessWeather
import web3swift
import Combine
import BigInt
import SwiftUI

extension WalletView {
    class ViewModel: ObservableObject {
        var getOneCancellable: AnyCancellable?
        var refreshOneCancellable: AnyCancellable?
    }
}

extension WalletView.ViewModel {
    var userInfoService: UserInfoService {
        UserInfoService.shared
    }
    var userWeatherService: UserWeatherService {
        UserWeatherService.shared
    }
    var selectedLocationWeather: [String: NSNumber] { SettingsService.shared.location }
    var userWeatherLocation: WeatherLocation? {
        if !selectedLocationWeather.isEmpty {
            let latitude = selectedLocationWeather["latitude"]!.doubleValue
            let longitude = selectedLocationWeather["longitude"]!.doubleValue

            return WeatherLocation(
                latitude: latitude,
                longitude: longitude
            )
        }
        guard let latestLocation = userInfoService.latestLocation else { return nil }
        return WeatherLocation(latitude: latestLocation.latitude,
                               longitude: latestLocation.longitude)
    }
}

extension WalletView.ViewModel {
    func fetchCurrentWeatherForecast(completion: @escaping (() -> Void)) {
        if userWeatherService.latestCurrentForecast == nil ||
            (userWeatherService.latestCurrentForecast != nil &&
             userWeatherService.lastFetch! + (60 * 60) < Date()) {
            userWeatherService.fetchCurrentForecast(location: userWeatherLocation, completion: completion)
        }
    }

    func formatAndSplitCurrency(_ number: Double?, digits: Int = 2) -> [String] {
        if let number = number {
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = digits
            formatter.maximumFractionDigits = digits
            formatter.roundingMode = .down
            if let formattedCurrency = formatter.string(from: number as NSNumber) {
                let strings = formattedCurrency.components(separatedBy: Locale.current.decimalSeparator ?? "")
                return strings
            }
        }
        return []
    }

    func getStrBeforeDecimal(_ value: Double?) -> String {
        if let oneStr = formatAndSplitCurrency(value).first { return oneStr }
        return "0"
    }

    func getStrAfterDecimal(_ value: Double?, isThreeDigit: Bool = false) -> String {
        guard let decimalSeparator = Locale.current.decimalSeparator else {
            if formatAndSplitCurrency(value, digits: isThreeDigit ? 3 : 2).count > 1 {
                return ".\(formatAndSplitCurrency(value)[1])"
            }
            return isThreeDigit ? ".000" : ".00"
        }
        if formatAndSplitCurrency(value, digits: isThreeDigit ? 3 : 2).count > 1 {
            return "\(decimalSeparator)\(formatAndSplitCurrency(value, digits: isThreeDigit ? 3 : 2)[1])"
        }
        return isThreeDigit ? "\(decimalSeparator)000" : "\(decimalSeparator)00"
    }
}

extension WalletView.ViewModel {
    static let shared = WalletView.ViewModel()
}
