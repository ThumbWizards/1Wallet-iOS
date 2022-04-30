//
//  JsonHelper.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 24/11/21.
//

import UIKit

enum JsonFiles: String {
    case iOneWallet = "IONEWallet"
    case token = "Token"
}

class JsonHelper: NSObject {
    static var tokens: [String: AnyObject] = {
        guard let path = Bundle.main.path(forResource: JsonFiles.token.rawValue, ofType: "json") else {
            return [String: AnyObject]()
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            return jsonResult as? [String: AnyObject] ?? [String: AnyObject]()
        } catch {
            return [String: AnyObject]()
        }
    }()
}
