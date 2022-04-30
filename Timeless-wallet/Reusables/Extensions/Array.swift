//
//  Array.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 27/10/2021.
//

import Foundation
import CommonCrypto

extension Array where Element == UInt8 {
    func fastSHA256() -> [UInt8] {
        var digestBytes = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(self, CC_LONG(self.count), &digestBytes)
        return digestBytes
    }
}

extension Array {
    //swiftlint:disable empty_count
    var middle: Element? {
        guard count != 0 else { return nil }
        let middleIndex = (count > 1 ? count - 1 : count) / 2
        return self[middleIndex]
    }
}

extension Array {
    func sliced(by dateComponents: Set<Calendar.Component>, for key: KeyPath<Element, Date>) -> [[Element]] {
        let initial: [String: [Element]] = [:]
        let groupedByDateComponents = reduce(into: initial) { acc, cur in
            let components = Calendar.current.dateComponents(dateComponents, from: cur[keyPath: key])
            let date = Calendar.current.date(from: components)!
            let existing = acc[Formatters.Date.MMMdyyyy.string(from: date)] ?? []
            acc[Formatters.Date.MMMdyyyy.string(from: date)] = existing + [cur]
        }
        let array = groupedByDateComponents.map { key, value in
            return value
        }
        return array
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
