//
//  ReqRefreshToken.swift
//  Timeless-wallet
//
//  Created by Ajay ghodadra on 24/10/21.
//

import Foundation

class ReqRefreshToken {

    // MARK: - Variables
    var refreshToken = ""

    // MARK: - Functions
    func toDictionary() -> [String: Any] {
        var dictOut = [String: Any]()
        dictOut["refreshToken"] = AppConstant.refreshToken
        return dictOut
    }
}
