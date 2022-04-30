//
//  UserWeatherServiceProtocol.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 10/28/21.
//

import Foundation
import Combine
import TimelessWeather

protocol UserWeatherServicing {
    func fetchCurrentForecast(location: WeatherLocation?, completion: @escaping (() -> Void))
}
