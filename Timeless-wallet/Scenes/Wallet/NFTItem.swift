//
//  NFTItem.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 19/01/2022.
//

import SwiftUI

struct NFTItem {
    // MARK: - Input Parameters
    let item: NFTTokenMetadata
    let collection: NFTInfo
    let mediaResource: MediaResourceModel
    let mediaSize: CGFloat
    let capTitle: Bool
    let showPlayButton: Bool

    // MARK: - Properties
    @AppStorage(ASSettings.Settings.showCurrencyWallet.key)
    private var showCurrencyWallet = ASSettings.Settings.showCurrencyWallet.defaultValue
}

// MARK: - Body view
extension NFTItem: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            mediaView
            Text(capTitle ? item.name?.uppercased() ?? "" : item.name ?? "")
                .lineLimit(1)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color.white)
                .padding(.top, 7.5)
                .padding(.horizontal, 4)
            SwapCurrencyView(
                value1: item.usdPrice == nil ? "n/a" : Utils.formatCurrency(item.usdPrice),
                value2: item.price == nil ? "-" :
                    "\(Web3Service.shared.amountFromWeiUnit(amount: item.price!, weiUnit: OneWalletService.weiUnit))",
                type1: "$",
                type2: "ONE",
                isSpacing1: false,
                isSpacing2: showCurrencyWallet ? item.price != nil : true,
                valueAfterType: true,
                font: .system(size: 13),
                color: Color.white.opacity(0.6)
            )
            .padding(.top, 3)
            .padding(.horizontal, 4)
        }
        .padding(.top, 6)
        .padding(.horizontal, 7)
        .padding(.bottom, 7)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.sendTextFieldBG)
        )
        .frame(width: mediaSize + 14)
    }
}

// MARK: - Subview
extension NFTItem {
    private var mediaView: some View {
        let isVideo = mediaResource.isVideoMediaType()

        return ZStack {
            Color.black
            ZStack(alignment: .topTrailing) {
                MediaResourceView(
                    for: MediaResource(
                        for: mediaResource, targetSize: TargetSize(width: Int(mediaSize), height: Int(mediaSize))
                    ), placeholder: ZStack {
                        Color.black
                        WalletPlaceHolder(cornerRadius: .zero)
                    }.eraseToAnyView(), isShowPlayVideoIcon: showPlayButton ? isVideo : false, isPlaying: .constant(!isVideo))
                    .scaledToFill()
                    .frame(width: mediaSize, height: mediaSize)
                    .disabled(isVideo)
                Image.checkmarkCircleFill
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(Color.timelessBlue)
                    .padding([.top, .trailing], 6)
                    .opacity(parseData(item: mediaResource.path) ? 1 : 0)
            }
        }
        .frame(width: mediaSize, height: mediaSize)
        .cornerRadius(10)
    }
}

// MARK: - Methods
extension NFTItem {
    private func onTapNFTsDetail(tokenData: NFTTokenMetadata) {
        present(WalletNFTsDetailView(
            nftsData: tokenData,
            collection: collection
        ), presentationStyle: .fullScreen)
    }

    private func parseData(item: String) -> Bool {
        return URL(string: item)?.absoluteString == WalletInfo.shared.currentWallet.avatarUrl ?? ""
    }
}
