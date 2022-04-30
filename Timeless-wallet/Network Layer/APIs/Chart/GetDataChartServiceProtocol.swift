//
//  GetDataChartServiceProtocol.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 1/18/22.
//

import Foundation
import Combine

protocol GetDataChartServiceProtocol {
    func getDataChart(fromTime: Int, toTime: Int) -> AnyPublisher<Swift.Result<ChartData, Error>, Never>
}
