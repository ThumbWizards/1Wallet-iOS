//
//  WeatherService.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 10/28/21.
//

import SwiftUI
import Combine
import TimelessWeather

final class WeatherService: ObservableObject {
    private lazy var temperatureFormatter: MeasurementFormatter = Formatters.Temperature.makeMeasurementFormatter()

    var currentWeatherForecast: CurrentWeatherOnlyForecast?

    // MARK: - Published Outputs
    @Published var temperatureUnit: String
    @Published var displayedTemperature: TimelessWeather.Temperature?
    @Published var displayedHighTemperature: TimelessWeather.Temperature?
    @Published var displayedLowTemperature: TimelessWeather.Temperature?

    // MARK: - Init
    init(
        temperatureUnit: String,
        currentWeatherForecast: CurrentWeatherOnlyForecast? = nil
    ) {
        self.temperatureUnit = temperatureUnit
        self.currentWeatherForecast = currentWeatherForecast

        switch temperatureUnit {
        case "Fahrenheit":
            self.displayedTemperature = self.currentTemperature?.converted(to: .fahrenheit)
        case "Celsius":
            self.displayedTemperature = self.currentTemperature?.converted(to: .celsius)
        default:
            break
        }
    }
}

extension WeatherService {
    var isShowingTemperature: Bool {
        currentWeatherForecast != nil &&
        displayedTemperature != nil
    }
    var currentTemperature: TimelessWeather.Temperature? { currentWeatherForecast?.temperature }
    var userLocationWeatherCondition: TimelessWeather.WeatherCondition? {
        currentWeatherForecast?.primaryCondition
    }
    var userLocationWeatherConditionName: String? {
        currentWeatherForecast?.conditionData.first?.categoryName
    }
}
