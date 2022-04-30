//
//  GetChartDataService.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 1/18/22.
//

import Foundation
import Combine

class GetDataChartService: BaseRestAPI<GetDataChartService.RequestType>, GetDataChartServiceProtocol {
    func getDataChart(fromTime: Int, toTime: Int) -> AnyPublisher<Result<ChartData, Error>, Never> {
        self.call(type: .getData(fromTime: fromTime, toTime: toTime), params: nil)
            .unwrapResultJSONFromAPI()
            .map {
                $0.data
            }
            .decodeFromJson(ChartData.self)
            .receive(on: DispatchQueue.main)
            .map { data in
                return .success(data)
            }
            .catch { error in
                Just(.failure(error))
            }
            .eraseToAnyPublisher()
    }

    static let shared = GetDataChartService()
}

extension GetDataChartService {
    enum RequestType: EndPointType {
        case getData(fromTime: Int, toTime: Int)
        var baseURL: String {
            return "https://api.coingecko.com/api/v3/coins/harmony/"
        }

        var path: String {
            switch self {
            case .getData(fromTime: let fromTime, toTime: let toTime):
                return "market_chart/range?vs_currency=usd&from=\(fromTime)&to=\(toTime)"
            }
        }

        var httpMethod: HTTPMethod {
            return .get
        }

        var headers: [String: String] {
            return NetworkHelper.httpTokenHeader
        }
    }
}
