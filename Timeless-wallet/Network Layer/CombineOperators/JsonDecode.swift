//
//  JsonDecode.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 23/10/21.
//

import Foundation
import Combine

extension Publisher {
    public func decodeFromJson<Item>(_ type: Item.Type) -> Publishers.Decode<Self, Item, JSONDecoder> where Item: Decodable, Self.Output == JSONDecoder.Input {
        return decode(type: type, decoder: JSONDecoder())
    }
}
