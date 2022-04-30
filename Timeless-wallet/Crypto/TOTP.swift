//
//  TOTP.swift
//  Timeless-wallet
//
//  Created by Vinh Dang on 10/29/21.
//

import Foundation
import CommonCrypto

class TOTP {
    var secret: [UInt8]

    init(secret: [UInt8]) {
        self.secret = secret
    }

    func hmacSHA1(bytes: [UInt8]) -> [UInt8] {
        var result = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1),
               &secret, secret.count,
               bytes, bytes.count,
               &result)
        return result
    }

    func generateCode(counter: UInt64) -> UInt32 {
        // HMAC message data from counter as big endian
        var counterBigendian = counter.bigEndian
        let counterBytes = counterBigendian.byteArray()

        let hmac = hmacSHA1(bytes: counterBytes)

        // Get last 4 bits of hash as offset
        let offset = Int((hmac.last ?? 0x00) & 0x0f)

        // Get 4 bytes from the hash from [offset] to [offset + 3]
        // Note: This will always produce an array of length 4 as max(offset) = 15 and hmac.count = 20
        let truncatedHMAC = Array(hmac[offset...offset + 3])

        // Convert data to UInt32
        var number = UInt32(bigEndian: truncatedHMAC.withUnsafeBytes { $0.load(as: UInt32.self) })

        // Mask most significant bit
        number &= 0x7fffffff

        // Modulo number by 10^6
        return number % 1_000_000
    }
}
