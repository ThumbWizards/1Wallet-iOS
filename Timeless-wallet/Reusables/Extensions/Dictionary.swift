//
//  Dictionary.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 24/10/21.
//

import Foundation

extension Dictionary {
    func data() -> Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
    }
}
