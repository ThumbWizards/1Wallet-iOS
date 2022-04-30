//
//  DataProfilePictureSample.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 2/11/22.
//

import Foundation
import web3swift
import UIKit

extension ProfilePictureNFTsModal {
    enum DataSample {
        static var List = [
            (NFTInfo(tokenType: .erc721,
                     contractAddress: EthereumAddress(WalletInfo.shared.currentWallet.address)!,
                     name: "#Bored Ape Yacht Club", symbol: ""),
              [
                // swiftlint:disable line_length
                NFTTokenMetadata(tokenId: 0,
                                 name: "#299",
                                 description: "",
                                 image: URL(string: "https://res.cloudinary.com/timeless/image/upload/app/Wallet/Bored%20Apes/299.png"),
                                 externalUrl: URL(string: "https://res.cloudinary.com/timeless/image/upload/app/Wallet/Bored%20Apes/299.png"),
                                 attributes: [],
                                 price: 0,
                                 usdPrice: 269_434.52),
                NFTTokenMetadata(tokenId: 0,
                                 name: "#2283",
                                 description: "",
                                 image: URL(string: "https://res.cloudinary.com/timeless/image/upload/app/Wallet/Bored%20Apes/2283.png"),
                                 externalUrl: URL(string: "https://res.cloudinary.com/timeless/image/upload/app/Wallet/Bored%20Apes/2283.png"),
                                 attributes: [],
                                 price: 0,
                                 usdPrice: 259_434.52),
                NFTTokenMetadata(tokenId: 0,
                                 name: "#2766",
                                 description: "",
                                 image: URL(string: "https://res.cloudinary.com/timeless/image/upload/app/Wallet/Bored%20Apes/2766.png"),
                                 externalUrl: URL(string: "https://res.cloudinary.com/timeless/image/upload/app/Wallet/Bored%20Apes/2766.png"),
                                 attributes: [],
                                 price: 0,
                                 usdPrice: 174_340.21),
                NFTTokenMetadata(tokenId: 0,
                                 name: "#3199",
                                 description: "",
                                 image: URL(string: "https://res.cloudinary.com/timeless/image/upload/app/Wallet/Bored%20Apes/3199.png"),
                                 externalUrl: URL(string: "https://res.cloudinary.com/timeless/image/upload/app/Wallet/Bored%20Apes/3199.png"),
                                 attributes: [],
                                 price: 0,
                                 usdPrice: 218_717.58),
                NFTTokenMetadata(tokenId: 0,
                                 name: "#3200",
                                 description: "",
                                 image: URL(string: "https://res.cloudinary.com/timeless/image/upload/app/Wallet/Bored%20Apes/3200.png"),
                                 externalUrl: URL(string: "https://res.cloudinary.com/timeless/image/upload/app/Wallet/Bored%20Apes/3200.png"),
                                 attributes: [],
                                 price: 0,
                                 usdPrice: 187_019.38),
                NFTTokenMetadata(tokenId: 0,
                                 name: "#5738",
                                 description: "",
                                 image: URL(string: "https://res.cloudinary.com/timeless/image/upload/app/Wallet/Bored%20Apes/5738.png"),
                                 externalUrl: URL(string: "https://res.cloudinary.com/timeless/image/upload/app/Wallet/Bored%20Apes/5738.png"),
                                 attributes: [],
                                 price: 0,
                                 usdPrice: 237_736.50),
                NFTTokenMetadata(tokenId: 0,
                                 name: "#5678",
                                 description: "",
                                 image: URL(string: "https://res.cloudinary.com/timeless/image/upload/app/Wallet/Bored%20Apes/5678.png"),
                                 externalUrl: URL(string: "https://res.cloudinary.com/timeless/image/upload/app/Wallet/Bored%20Apes/5678.png"),
                                 attributes: [],
                                 price: 0,
                                 usdPrice: 215_547.76),
                NFTTokenMetadata(tokenId: 0,
                                 name: "#9080",
                                 description: "",
                                 image: URL(string: "https://res.cloudinary.com/timeless/image/upload/app/Wallet/Bored%20Apes/9080.png"),
                                 externalUrl: URL(string: "https://res.cloudinary.com/timeless/image/upload/app/Wallet/Bored%20Apes/9080.png"),
                                 attributes: [],
                                 price: 0,
                                 usdPrice: 218_717.58)
              ]),
            (NFTInfo(tokenType: .erc721,
                      contractAddress: EthereumAddress(WalletInfo.shared.currentWallet.address)!, name: "Timeless Living", symbol: ""),
              [
                // swiftlint:disable line_length
                NFTTokenMetadata(tokenId: 0,
                                 name: "Daydreamin’",
                                 description: "",
                                 image: URL(string: "https://res.cloudinary.com/timeless/video/upload/v1644831816/app/Wallet/meeting-discuss.mp4"),
                                 externalUrl: URL(string: "https://res.cloudinary.com/timeless/video/upload/v1644831816/app/Wallet/meeting-discuss.mp4"),
                                 attributes: [],
                                 price: 0),
                NFTTokenMetadata(tokenId: 0,
                                 name: "Drowning in Luxury’",
                                 description: "",
                                 image: URL(string: "https://res.cloudinary.com/timeless/video/upload/v1644831818/app/Wallet/shopping-travel.mp4"),
                                 externalUrl: URL(string: "https://res.cloudinary.com/timeless/video/upload/v1644831818/app/Wallet/shopping-travel.mp4"),
                                 attributes: [],
                                 price: 0),
                NFTTokenMetadata(tokenId: 0,
                                 name: "Relaxin’",
                                 description: "",
                                 image: URL(string: "https://res.cloudinary.com/timeless/video/upload/v1644831817/app/Wallet/relaxing-dog.mp4"),
                                 externalUrl: URL(string: "https://res.cloudinary.com/timeless/video/upload/v1644831817/app/Wallet/relaxing-dog.mp4"),
                                 attributes: [],
                                 price: 0),
                NFTTokenMetadata(tokenId: 0,
                                 name: "Gone Fishing",
                                 description: "",
                                 image: URL(string: "https://res.cloudinary.com/timeless/video/upload/v1644831819/app/Wallet/waiting.mp4"),
                                 externalUrl: URL(string: "https://res.cloudinary.com/timeless/video/upload/v1644831819/app/Wallet/waiting.mp4"),
                                 attributes: [],
                                 price: 0),
                NFTTokenMetadata(tokenId: 0,
                                 name: "Woo… sah",
                                 description: "",
                                 image: URL(string: "https://res.cloudinary.com/timeless/video/upload/v1644831819/app/Wallet/wellbeing-calm.mp4"),
                                 externalUrl: URL(string: "https://res.cloudinary.com/timeless/video/upload/v1644831819/app/Wallet/wellbeing-calm.mp4"),
                                 attributes: [],
                                 price: 0)
              ])
        ]
    }
}

class AssetExtractor {
    static func createLocalUrl(forImageNamed name: String, forType ofType: String) -> URL? {
        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let url = cacheDirectory.appendingPathComponent("\(name).\(ofType)")

        guard fileManager.fileExists(atPath: url.path) else {
            guard
                let image = UIImage(named: name),
                let data = image.pngData()
            else { return nil }

            fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
            return url
        }
        return url
    }
}
