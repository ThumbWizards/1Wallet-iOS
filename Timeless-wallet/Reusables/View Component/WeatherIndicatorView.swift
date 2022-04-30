//
//  WeatherIndicatorView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 10/29/21.
//

import SwiftUI
import TimelessWeather


struct WeatherIndicatorView {
    @ObservedObject private(set) var weatherService: WeatherService
    var temperature: Temperature {
        weatherService.displayedTemperature!
    }
    var temperatureUnit: UnitTemperature {
        weatherService.displayedTemperature!.unit
    }
    var condition: WeatherCondition {
        weatherService.userLocationWeatherCondition!
    }
}


// MARK: - Computeds
extension WeatherIndicatorView {

    var currentTemperatureText: String {
        Self.temperatureValueFormatter.string(from: temperature.converted(to: temperatureUnit))
    }
}


// MARK: - View
extension WeatherIndicatorView: View {

    var body: some View {
        if weatherService.isShowingTemperature {
            HStack(spacing: 4) {
                weatherIcon

                Text("\(currentTemperatureText)")
                    .font(.system(size: 16))
                    .foregroundColor(Color.white)
            }
        }
    }
}


// MARK: - View Variables
private extension WeatherIndicatorView {

    var weatherIcon: some View {
        Image(systemName: condition.sfSymbolName)
            .resizable()
            .frame(width: 16, height: 16)
            .foregroundColor(Color.white)
    }
}


// MARK: - Private Helpers
extension WeatherIndicatorView {

    static var temperatureValueFormatter: MeasurementFormatter {
        let formatter = MeasurementFormatter()

        // Use the unit that's native to the provided `temperature` value
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter = Formatters.Temperature.temperatureDisplayTextFormatter

        return formatter
    }
}
