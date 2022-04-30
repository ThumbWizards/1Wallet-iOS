//
//  EndPointType.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 23/10/21.
//

import Foundation

protocol EndPointType {
    // MARK: Variables
    var baseURL: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    var httpMethod: HTTPMethod { get }
    var headers: [String: String] { get }
    var url: URL { get }
    var version: String { get }
}

extension EndPointType {
    var url: URL {
        // swiftlint:disable line_length
        let urlString = self.baseURL + self.version + self.path.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        if queryItems.isEmpty {
            return URL(string: urlString)!
        } else {
            var urlComponents = URLComponents(string: urlString)!
            urlComponents.queryItems = queryItems
            urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            return urlComponents.url!
        }
    }

    var version: String {
        return ""
    }

    var queryItems: [URLQueryItem] {
        return []
    }
}
