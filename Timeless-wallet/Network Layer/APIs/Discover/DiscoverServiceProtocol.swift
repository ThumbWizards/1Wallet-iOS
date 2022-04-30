//
//  DiscoverServiceProtocol.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 3/10/22.
//

import Foundation
import Combine

protocol DiscoverServiceProtocol {
    func getDiscoverItems(cursor: String?) -> AnyPublisher<Swift.Result<DiscoverItemModel, Error>, Never>
    func getChildrenItems(id: String, cursor: String?) -> AnyPublisher<Swift.Result<DiscoverChildrenModel, Error>, Never>
}
