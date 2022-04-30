//
//  NFTCollectionView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 19/01/2022.
//

import SwiftUI

struct NFTCollectionView: View {
    // MARK: - Input Parameters
    var collection: NFTInfo
    var nftList: [NFTTokenMetadata]
    var itemsPerLine: Int = 2
    var capTitle: Bool = true
    var showPlayButton: Bool = true
    var onTapItem: ((NFTInfo, NFTTokenMetadata) -> Void)?

    // MARK: - Properties
    private let mediaSize: CGFloat = ((UIScreen.main.bounds.width - 43) / 2) - 14

    // MARK: - Body view
    var body: some View {
        VStack(spacing: 0) {
            ExpandCollapseView(title: collection.name ?? "", subTitle: "\(nftList.count)", verticalSpacing: 19) {
                VStack(alignment: .leading, spacing: 11) {
                    ForEach(Array(stride(from: 0, to: nftList.count, by: itemsPerLine)), id: \.self) { index in
                        gridLine(index: index)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        // .padding(.top, 38) // PENDING
    }

    // MARK: - Subview
    private func gridLine(index: Int) -> some View {
        HStack(spacing: 11) {
            ForEach(index..<(index + itemsPerLine), id: \.self) { idx in
                if idx < nftList.count {
                    collectionItem(idx)
                }
            }
            if index + itemsPerLine - 1 >= nftList.count {
                Spacer(minLength: 0)
            }
        }
    }

    private func collectionItem(_ idx: Int) -> some View {
        let mediaResource = MediaResourceModel(
            path: nftList[idx].image?.absoluteString ?? "",
            altText: "",
            pathPrefix: "",
            mediaType: nftList[idx].image?.absoluteString.suffix(4) == ".mp4" ? "mp4" : "",
            thumbnail: ""
        )

        return NFTItem(item: nftList[idx],
                       collection: collection,
                       mediaResource: mediaResource,
                       mediaSize: mediaSize,
                       capTitle: capTitle,
                       showPlayButton: showPlayButton)
            .onTapGesture {
                onTapItem?(collection, nftList[idx])
            }
    }
}
