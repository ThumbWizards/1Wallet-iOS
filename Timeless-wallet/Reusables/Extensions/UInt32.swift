//
//  UInt32.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 26/10/2021.
//

import Foundation

extension UInt32 {
    mutating func byteArray() -> [UInt8] {
        let uint32Size = MemoryLayout<UInt32>.size
        let bytePtr = withUnsafePointer(to: &self) {
            $0.withMemoryRebound(to: UInt8.self, capacity: uint32Size) {
                UnsafeBufferPointer(start: $0, count: uint32Size)
            }
        }
        return Array(bytePtr)
    }
}
