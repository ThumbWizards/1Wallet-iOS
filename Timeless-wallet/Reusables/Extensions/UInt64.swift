//
//  UInt64.swift
//  Timeless-wallet
//
//  Created by Zien on 10/29/21.
//

import Foundation

extension UInt64 {
    mutating func byteArray() -> [UInt8] {
        let uint64Size = MemoryLayout<UInt64>.size
        let bytePtr = withUnsafePointer(to: &self) {
            $0.withMemoryRebound(to: UInt8.self, capacity: uint64Size) {
                UnsafeBufferPointer(start: $0, count: uint64Size)
            }
        }
        return Array(bytePtr)
    }
}
