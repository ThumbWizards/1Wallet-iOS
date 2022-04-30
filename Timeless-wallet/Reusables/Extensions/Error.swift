//
//  Error.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 13/01/22.
//

import Foundation

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}
