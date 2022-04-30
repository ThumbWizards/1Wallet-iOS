//
//  UserWeatherService.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 10/28/21.
//

import Foundation
import TimelessWeather
import Combine

class UserWeatherService: UserWeatherServicing {
    // MARK: - Variables
    var latestDailyForecast: DailyWeatherForecast?
    var latestWeeklyForecast: HourlyWeatherForecast?
    var latestCurrentForecast: CurrentWeatherOnlyForecast?
    var dailyForecast: DailyWeatherDataItem?
    var lastFetch: Date?
    var cancellables = [AnyCancellable]()
    static let backgroundQueue = DispatchQueue.init(label: "UserWeatherService")
    static let shared = UserWeatherService()

    init() {
        OpenWeatherAPIService.shared.apiKey = AppConstant.openWeatherApiKey
    }
}

// MARK: - Functions
extension UserWeatherService {
    private func currentForecastSet(currentWeatherOnlyForecast: CurrentWeatherOnlyForecast) {
        latestCurrentForecast = currentWeatherOnlyForecast
        lastFetch = Date()
    }

    func fetchCurrentForecast(location: WeatherLocation?, completion: @escaping (() -> Void)) {
        OpenWeatherAPIService.shared
            .fetchCurrentWeatherOnlyForecast(for: location, maxRetries: 10)
            .receive(on: Self.backgroundQueue)
            .sink(receiveCompletion: { _ in },
            receiveValue: { forecast in
                self.currentForecastSet(currentWeatherOnlyForecast: forecast)
                DispatchQueue.main.async {
                    completion()
                }
            })
            .store(in: &cancellables)
    }
}
