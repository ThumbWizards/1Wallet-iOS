//
//  ReqQuoteSimplex.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 1/12/22.
//

import SwiftUI

class ReqQuoteSimplex {

    var sourceAmount: Double?
    var uid: String?

    func toDictionary() -> [String: Any] {
        var dictOut = [String: Any]()
        dictOut["source_amount"] = sourceAmount
        dictOut["source_currency"] = "USD"
        dictOut["target_currency"] = "ONE"
        dictOut["uid"] = uid
        dictOut["abTests"] = [String: String]()
        dictOut["hostname"] = "https://www.harmony.one/"

        return dictOut
    }
}
