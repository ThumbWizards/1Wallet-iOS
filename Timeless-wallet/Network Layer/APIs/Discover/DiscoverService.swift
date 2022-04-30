//
//  DiscoverService.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 3/10/22.
//

import Foundation
import Combine

class DiscoverService: BaseRestAPI<DiscoverService.RequestType>, DiscoverServiceProtocol {
    static let shared = DiscoverService()

    func getDiscoverItems(cursor: String?) -> AnyPublisher<Result<DiscoverItemModel, Error>, Never> {
        self.call(type: .discoverDetails(cursor: cursor), params: nil)
            .unwrapResultJSONFromAPI()
            .map {
                $0.data
            }
            .decodeFromJson(DiscoverItemModel.self)
            .receive(on: DispatchQueue.main)
            .map { data in
                return .success(data)
            }
            .catch { error in
                Just(.failure((error as? API.APIError) ?? .requestError))
            }
            .eraseToAnyPublisher()
    }

    func getChildrenItems(id: String, cursor: String?) -> AnyPublisher<Result<DiscoverChildrenModel, Error>, Never> {
        self.call(type: .discoverChildren(id: id, cursor: cursor), params: nil)
            .unwrapResultJSONFromAPI()
            .map {
                $0.data
            }
            .decodeFromJson(DiscoverChildrenModel.self)
            .receive(on: DispatchQueue.main)
            .map { data in
                return .success(data)
            }
            .catch { error in
                Just(.failure((error as? API.APIError) ?? .requestError))
            }
            .eraseToAnyPublisher()
    }
}

extension DiscoverService {
    enum RequestType: EndPointType {
        case discoverDetails(cursor: String? = nil)
        case discoverChildren(id: String, cursor: String?)

        // MARK: Vars & Lets
        var baseURL: String {
            return AppConstant.serverURL
        }

        var version: String {
            return "v2/"
        }

        var path: String {
            switch self {
            case .discoverDetails:
                return "discovers/details/"
            case .discoverChildren:
                return "discovers/children/"
            }
        }

        var queryItems: [URLQueryItem] {
            switch self {
            case let .discoverDetails(cursor):
                var queryItems = [
                    URLQueryItem(name: "id", value: "/"),
                ]
                if let cursor = cursor {
                    queryItems.append(URLQueryItem(name: "cursor", value: cursor))
                }
                queryItems.append(URLQueryItem(name: "limit", value: "10"))
                return queryItems
            case let .discoverChildren(id, cursor):
                var queryItems = [
                    URLQueryItem(name: "id", value: id)
                ]
                if let cursor = cursor {
                    queryItems.append(URLQueryItem(name: "cursor", value: cursor))
                }
                queryItems.append(URLQueryItem(name: "limit", value: "10"))
                return queryItems
            }
        }

        var httpMethod: HTTPMethod {
            return .get
        }

        var headers: [String: String] {
            return NetworkHelper.httpVersionHeader
        }
    }
}
