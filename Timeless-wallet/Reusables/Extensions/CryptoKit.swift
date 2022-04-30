//
//  CryptoKit.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 04/11/2021.
//

import Foundation
import CryptoKit

extension DataProtocol {
    var sha256Digest: SHA256Digest { SHA256.hash(data: self) }
    var sha256Data: Data { .init(sha256Digest) }
    var sha256Hexa: String { sha256Digest.map { String(format: "%02x", $0) }.joined() }
}
