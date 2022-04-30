//
//  ReqPrivateGroup.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 22/04/22.
//

import Foundation

class ReqPrivateGroup {

    var password: String?
    var lon: Float?
    var lat: Float?

    init(password: String, lon: Float, lat: Float) {
        self.password = password
        self.lon = lon
        self.lat = lat
    }

    init(password: String) {
        self.password = password
        self.lon = nil
        self.lat = nil
    }

    func toDictionary() -> [String: Any] {
        var dictOut = [String: Any]()
        dictOut["password"] = password
        dictOut["lon"] = lon
        dictOut["lat"] = lat
        return dictOut
    }
}
