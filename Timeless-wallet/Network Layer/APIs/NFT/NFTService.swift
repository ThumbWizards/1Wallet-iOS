//
//  NFTService.swift
//  Timeless-wallet
//
//  Created by Vinh Dang on 1/5/22.
//

import Foundation
import Combine
import web3swift
import BigInt

class NFTService: NFTServiceProtocol {
    static let shared: NFTService = NFTService(web3Service: Web3Service.shared)

    let web3Service: Web3ServiceProtocol

    init(web3Service: Web3ServiceProtocol) {
        // Not doing anything yet but injecting the Web3Service instance to the constructor here
        // will make it easier to swap between mainnet & testnet
        self.web3Service = web3Service
    }

    func contractDetails(contractAddress: EthereumAddress, tokenType: NFTType) -> AnyPublisher<NFTInfo, Never> {
        guard let nftContract = web3Service.erc721Contract(at: contractAddress),
              let nameTx = nftContract.read("name"),
              let symbolTx = nftContract.read("symbol") else {
                  return Just(NFTInfo(tokenType: tokenType, contractAddress: contractAddress)).eraseToAnyPublisher()
        }
        return Publishers.Zip(
            nameTx.callPromise(transactionOptions: web3Service.defaultTransactionOptions).publisher,
            symbolTx.callPromise(transactionOptions: web3Service.defaultTransactionOptions).publisher
        )
            .map { nameResult, symbolResult in
                guard let name = nameResult["0"] as? String,
                      let symbol = symbolResult["0"] as? String else {
                    return NFTInfo(tokenType: tokenType, contractAddress: contractAddress)
                }
                return NFTInfo(tokenType: tokenType, contractAddress: contractAddress, name: name, symbol: symbol)
            }
            .replaceError(with: NFTInfo(tokenType: tokenType, contractAddress: contractAddress))
            .eraseToAnyPublisher()
    }

    func tokenDetails(contractInfo: NFTInfo, tokenId: BigUInt) -> AnyPublisher<NFTTokenMetadata, NFTError> {
        var nftContract: web3.web3contract?
        var tx: ReadTransaction?
        switch contractInfo.tokenType {
        case .erc721:
            nftContract = web3Service.erc721Contract(at: contractInfo.contractAddress)
            tx = nftContract?.read("tokenURI", parameters: [tokenId] as [AnyObject])
        case .erc1155:
            nftContract = web3Service.erc1155Contract(at: contractInfo.contractAddress)
            tx = nftContract?.read("uri", parameters: [tokenId] as [AnyObject])
        }
        guard tx != nil else {
            return Fail(error: .web3Error).eraseToAnyPublisher()
        }
        return tx!.callPromise(transactionOptions: web3Service.defaultTransactionOptions)
            .publisher
            .tryMap { result -> String in
                guard let uriString = result["0"] as? String, !uriString.isEmpty else {
                    throw NFTError.web3Error
                }
                return uriString
            }
            .tryMap { uriString -> URL in
                var uri: URL?
                if !uriString.contains("://") {
                    // Assuming it's ipfs hash
                    uri = URL(string: "https://ipfs.io/ipfs/" + uriString)
                } else if uriString.starts(with: "ipfs://") {
                    let offset = uriString.index(uriString.startIndex, offsetBy: 7)
                    uri = URL(string: "https://ipfs.io/ipfs/" + uriString[offset...])
                } else {
                    uri = URL(string: uriString)
                }
                guard let uri = uri else {
                    throw NFTError.web3Error
                }
                return uri
            }
            .flatMap { uri -> AnyPublisher<NFTTokenMetadata, Error> in
                let request = URLRequest(url: uri)
                return URLSession.shared.erasedDataTaskPublisher(for: request)
                    .map { $0.data }
                    .decodeFromJson(NFTTokenMetadata.self)
                    .map { res in
                        return res.clone(tokenId: tokenId)
                    }
                    .eraseToAnyPublisher()
            }
            .mapError { $0 as? NFTError ?? .unknownError }
            .eraseToAnyPublisher()
    }

    func fullDetails(tokensMapping: [NFTInfo: [BigUInt]]) -> AnyPublisher<[(collection: NFTInfo, tokens: [NFTTokenMetadata])], Never> {
        let contracts = Array(tokensMapping.keys)
        var tokensFetching: [AnyPublisher<[Result<NFTTokenMetadata, NFTError>], Never>] = []
        for contract in contracts {
            let tokenIds = tokensMapping[contract]!
            let tokensInfo = Publishers.SafeZipMany(
                Array(tokenIds.map { self.tokenDetails(contractInfo: contract, tokenId: $0) })
            ).eraseToAnyPublisher()
            tokensFetching += [tokensInfo]
        }
        return Publishers.SafeZipMany(tokensFetching)
            .map { (res: [Result<[Result<NFTTokenMetadata, NFTError>], Never>]) in
                var output = [(collection: NFTInfo, tokens: [NFTTokenMetadata])]()
                for idx in 0..<res.count {
                    var tokensInfo: [NFTTokenMetadata] = []
                    switch res[idx] {
                    case .success(let wrappedTokensInfo):
                        for wrappedTokenInfo in wrappedTokensInfo {
                            switch wrappedTokenInfo {
                            case .success(let tokenInfo):
                                tokensInfo += [tokenInfo]
                            default: continue
                            }
                        }
                    default: continue
                    }
                    output += [(collection: contracts[idx], tokens: tokensInfo)]
                }
                return output
            }
            .eraseToAnyPublisher()
    }
}
