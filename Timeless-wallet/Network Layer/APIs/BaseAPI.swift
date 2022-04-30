//
//  BaseAPI.swift
//  Timeless-wallet
//
//  Created by Ajay ghodadra on 23/10/21.
//

import Foundation

struct API {
    enum APIError: Error, Equatable {
        case unableToCreateURL
        case noInternet
        case unauthorized
        case requestError
        case notFound
    }
}
