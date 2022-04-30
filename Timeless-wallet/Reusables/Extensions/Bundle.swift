//
//  Bundle.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 14/04/22.
//

import Foundation

extension Bundle {
    public var appVersionShort: String { getInfo("CFBundleShortVersionString") }
    public var bundleVersion: String { getInfo("CFBundleVersion") }
    private func getInfo(_ str: String) -> String { infoDictionary?[str] as? String ?? "" }
    public var buildInfo: String {
        return "\(appVersionShort)(\(bundleVersion))"
    }
}
