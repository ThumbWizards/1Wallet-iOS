//
//  NFTServiceProtocol.swift
//  Timeless-wallet
//
//  Created by Vinh Dang on 1/5/22.
//

import Foundation
import Combine
import web3swift
import BigInt

protocol NFTServiceProtocol {
    var web3Service: Web3ServiceProtocol { get }
    func contractDetails(contractAddress: EthereumAddress, tokenType: NFTType) -> AnyPublisher<NFTInfo, Never>
    func tokenDetails(contractInfo: NFTInfo, tokenId: BigUInt) -> AnyPublisher<NFTTokenMetadata, NFTError>
    func fullDetails(tokensMapping: [NFTInfo: [BigUInt]]) -> AnyPublisher<[(collection: NFTInfo, tokens: [NFTTokenMetadata])], Never>
}

enum NFTType: Codable {
    case erc721
    case erc1155
}

struct NFTInfo: Codable, Hashable {
    let tokenType: NFTType
    let contractAddress: EthereumAddress
    let name: String?
    let symbol: String?

    init(tokenType: NFTType, contractAddress: EthereumAddress, name: String? = nil, symbol: String? = nil) {
        self.tokenType = tokenType
        self.contractAddress = contractAddress
        self.name = name
        self.symbol = symbol
    }
}

struct NFTTokenMetadata: Codable {
    let tokenId: BigUInt
    let name: String?
    let description: String?
    let image: URL?
    let externalUrl: URL?
    let attributes: [NFTTrait]?
    let price: BigUInt?
    let usdPrice: Double?

    private enum CodingKeys: String, CodingKey {
        case tokenId, name, description, image, externalUrl, attributes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tokenId = try container.decodeIfPresent(BigUInt.self, forKey: .tokenId) ?? 0
        name = try container.decodeIfPresent(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        externalUrl = try container.decodeIfPresent(URL.self, forKey: .externalUrl)
        attributes = try container.decodeIfPresent([NFTTrait].self, forKey: .attributes)
        price = nil // TODO: Fetch this once we integrate with opensea
        usdPrice = nil

        guard let imgString = try container.decodeIfPresent(String.self, forKey: .image) else {
            image = nil
            return
        }
        if !imgString.contains("://") {
            // Assuming it's ipfs hash
            image = URL(string: "https://ipfs.io/ipfs/" + imgString)
        } else if imgString.starts(with: "ipfs://") {
            let offset = imgString.index(imgString.startIndex, offsetBy: 7)
            image = URL(string: "https://ipfs.io/ipfs/" + imgString[offset...])
        } else {
            image = URL(string: imgString)
        }
    }

    init(tokenId: BigUInt, name: String?, description: String?, image: URL?, externalUrl: URL?, attributes: [NFTTrait]?, price: BigUInt?, usdPrice: Double? = nil) {
        self.tokenId = tokenId
        self.name = name
        self.description = description
        self.image = image
        self.externalUrl = externalUrl
        self.attributes = attributes
        self.price = price
        self.usdPrice = usdPrice
    }

    func clone(tokenId: BigUInt) -> NFTTokenMetadata {
        return NFTTokenMetadata(
            tokenId: tokenId,
            name: name,
            description: description,
            image: image,
            externalUrl: externalUrl,
            attributes: attributes,
            price: price
        )
    }
}

struct NFTTrait: Codable {
    let trait: String
    let value: String

    private enum CodingKeys: String, CodingKey {
        case trait = "trait_type", value
    }
}

enum NFTError: Error {
    case web3Error
    case invalidToken
    case invalidTokenId
    case unknownError
}
