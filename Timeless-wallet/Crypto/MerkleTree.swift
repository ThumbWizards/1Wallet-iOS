//
//  MerkleTree.swift
//  Timeless-wallet
//
//  Created by Vinh Dang on 11/18/21.
//

import Foundation

struct MerkleTree {
    typealias TreeNode = [UInt8]
    typealias TreeLayer = [TreeNode]

    let layers: [TreeLayer]

    init(_ input: TreeLayer) {
        let height = Int(log2(Double(input.count))) + 1
        var lastLayer: TreeLayer
        var layer = input.map { $0.fastSHA256() }
        var layers = [layer]
        for layerIdx in stride(from: height - 2, through: 0, by: -1) {
            lastLayer = layer
            let layerSize = 1 << layerIdx
            layer = [[UInt8]](repeating: [], count: layerSize)
            // swiftlint:disable identifier_name
            for i in 0..<layerSize {
                layer[i] = (lastLayer[i * 2] + lastLayer[i * 2 + 1]).fastSHA256()
            }
            layers.append(layer)
        }
        self.layers = layers
     }

    init(_ layers: [TreeLayer]) {
        self.layers = layers
    }

    func encode() -> Data {
        let bytes: [UInt8] = Array(layers.joined().joined())
        return Data(bytes)
    }
}

// MARK: Computed
extension MerkleTree {
    var root: TreeNode {
        if let lastElement = layers.last, !lastElement.isEmpty {
            return lastElement[0]
        } else {
            return TreeNode()
        }
    }

    var rootHex: String {
        return "0x" + root.map { String(format: "%02hhx", $0) }.joined()
    }

    var height: Int {
        layers.count
    }
}

// MARK: Helpers
extension MerkleTree {
    func getNeighborsFor(index: Int) -> [TreeNode] {
        var nodeIndex = index
        var nodes: [TreeNode] = []
        // swiftlint:disable identifier_name
        for i in 0..<(height - 1) {
            let neighborIndex = nodeIndex % 2 == 0 ? nodeIndex + 1 : nodeIndex - 1
            nodes.append(layers[i][neighborIndex])
            nodeIndex >>= 1
        }
        return nodes
    }
}

extension MerkleTree {
    static func decode(data: [UInt8]) throws -> Self {
        let flattenLayers = data.chunked(into: 32) // each tree node has size of 32 bytes
        let height = Int(log2(Double(flattenLayers.count + 1)))
        guard flattenLayers.count + 1 == 1 << height else {
            throw Error.decodeError
        }
        var offset = 0
        var layerSize = 1 << (height - 1)
        var layers: [TreeLayer] = []
        while offset < flattenLayers.count {
            layers.append(Array(flattenLayers[offset..<(offset + layerSize)]))
            offset += layerSize
            layerSize /= 2
        }
        return MerkleTree(layers)
    }

    enum Error: Swift.Error {
        case decodeError
    }
}
