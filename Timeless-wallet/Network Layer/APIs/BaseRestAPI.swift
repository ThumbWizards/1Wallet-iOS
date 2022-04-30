//
//  APIProtocol.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 23/10/21.
//

import Foundation
import Combine
import FilesProvider

class BaseRestAPI<T: EndPointType>: NSObject {
    typealias RequestModifier = ((URLRequest) -> URLRequest)
    var urlSession: URLSession { URLSession.shared }

    func call(type: T, params: [String: Any]?, requestModifier: @escaping RequestModifier = { $0 }) -> URLSession.ErasedDataTaskPublisher {
        guard NetworkHelper.shared.reachability?.connection != Reachability.Connection.none else {
            return Fail<URLSession.DataTaskPublisher.Output, Error>(error: API.APIError.noInternet).eraseToAnyPublisher()
        }
        var request = URLRequest(url: type.url)
        request.httpMethod = type.httpMethod.rawValue
        request.httpBody = params?.data()
        request.allHTTPHeaderFields = type.headers
        return createPublisher(for: request, type: type, requestModifier: requestModifier)
    }

    func callByFormType(type: T, params: String?, requestModifier: @escaping RequestModifier = { $0 }) -> URLSession.ErasedDataTaskPublisher {
        guard NetworkHelper.shared.reachability?.connection != Reachability.Connection.none else {
            return Fail<URLSession.DataTaskPublisher.Output, Error>(error: API.APIError.noInternet).eraseToAnyPublisher()
        }
        var request = URLRequest(url: type.url)
        request.httpMethod = type.httpMethod.rawValue
        request.httpBody = params?.data(using: .utf8)
        request.allHTTPHeaderFields = type.headers
        return createPublisher(for: request, type: type, requestModifier: requestModifier)
    }

    func createPublisher(
        for request: URLRequest,
        type: T,
        requestModifier:@escaping RequestModifier) -> URLSession.ErasedDataTaskPublisher {
            return Just(request)
                .setFailureType(to: Error.self)
                .flatMap { [self] in
                    urlSession.erasedDataTaskPublisher(for: requestModifier($0))
                }
                .eraseToAnyPublisher()
        }
}
