//
//  WalletNFTsDetailView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 12/01/2022.
//

import SwiftUI
import BigInt

struct WalletNFTsDetailView: View {
    // MARK: - Input parameters
    let nftsData: NFTTokenMetadata
    let collection: NFTInfo

    // MARK: - Properties
    @AppStorage(ASSettings.Settings.walletBalance.key)
    private var walletBalance = ASSettings.Settings.walletBalance.defaultValue
    @AppStorage(ASSettings.Settings.showCurrencyWallet.key)
    private var showCurrencyWallet = ASSettings.Settings.showCurrencyWallet.defaultValue
    private let mediaSize: CGFloat = UIScreen.main.bounds.width - 32
}

// MARK: - Body view
extension WalletNFTsDetailView {
    var body: some View {
        ZStack(alignment: .top) {
            Color.primaryBackground
            VStack(spacing: 0) {
                header
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        priceView
                        mediaWithBGView
                        if !(nftsData.description ?? "").isEmpty {
                            descriptionView
                        }
                        if nftsData.attributes != nil {
                            propertiesView
                        }
                        // moreDetailView // PENDING
                        detailsView
                    }
                    .padding(.bottom, UIView.hasNotch ? UIView.safeAreaBottom : 35)
                }
                .padding(.top, 11)
            }
        }
        .hideNavigationBar()
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Subview
extension WalletNFTsDetailView {
    private var header: some View {
        ZStack {
            HStack {
                Button(action: { onTapClose() }) {
                    Image("closeBackup")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .padding(.leading, 18.5)
                Spacer()
            }
            Text(nftsData.name ?? "")
                .tracking(-0.2)
                .font(.system(size: 18, weight: .bold))
                .lineLimit(1)
                .foregroundColor(Color.walletDetailTitle)
                .padding(.horizontal, 67)
            HStack {
                Spacer()
                menuView
            }
        }
        .padding(.top, 51)
    }

    private var menuView: some View {
        Menu {
            Button(action: { onTapCopyTokenID() }) {
                HStack {
                    Text("Token ID")
                    Image.docOnDoc
                }
            }
            Button(action: { onTapSaveToPhotos() }) {
                HStack {
                    Text("Save to Photos")
                    Image.photoOnRectangle
                }
            }
            Button(action: { onTapBlockExplorer() }) {
                HStack {
                    Text("Block Explorer")
                    Image.link
                }
            }
//            Button(action: {
//
//            }) {
//                HStack {
//                    Text("Showcase")
//                    Image.infinity
//                }
//            }
        } label: {
            ZStack {
                Color.almostClear
                    .frame(width: 56, height: 30)
                Image.ellipsis
                    .resizable()
                    .foregroundColor(Color.walletDetailTitle)
                    .frame(width: 17, height: 3)
                    .offset(y: 2)
            }
        }
    }

    private var priceView: some View {
        VStack(spacing: 7) {
            Button(action: { onTapFloorPriceInfo() }) {
                HStack(spacing: 5.5) {
                    Text("Per the Floor price")
                        .tracking(-0.1)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.white)
                    Image.infoCircle
                        .resizable()
                        .foregroundColor(Color.white)
                        .frame(width: 16, height: 16)
                }
            }
            SwapCurrencyView(
                value1: nftsData.usdPrice == nil ? "-" : Utils.formatCurrency(nftsData.usdPrice),
                value2: nftsData.price == nil ? "-" :
                    "\(Web3Service.shared.amountFromWeiUnit(amount: nftsData.price!, weiUnit: OneWalletService.weiUnit))",
                type1: "$",
                type2: "ONE",
                isSpacing1: false,
                isSpacing2: showCurrencyWallet ? nftsData.price != nil : true,
                valueAfterType: true,
                font: .system(size: 28, weight: .medium),
                color: Color.white.opacity(0.8)
            )
            .padding(.horizontal, 10)
            .background(Color.almostClear)
            .padding(.horizontal, 10)
            .onTapGesture { onTapPrice() }
        }
        .padding(.top, 11)
        .padding(.horizontal, 16)
    }

    private var mediaWithBGView: some View {
        ZStack {
            Color.black
            mediaView(size: mediaSize)
        }
        .frame(width: mediaSize, height: mediaSize)
        .cornerRadius(10)
        .padding(.top, 14)
        .padding(.horizontal, 16)
    }

    private func mediaView(size: CGFloat, isShowPlayVideoIcon: Bool = true) -> some View {
        let mediaType = nftsData.image?.absoluteString.split(separator: ".").last ?? ""
        let mediaResource = MediaResourceModel(
            path: nftsData.image?.absoluteString ?? "",
            altText: "",
            pathPrefix: "",
            mediaType: String(mediaType),
            thumbnail: ""
        )
        let isVideo = mediaResource.isVideoMediaType()
        var showPlayVideoIcon = isShowPlayVideoIcon
        if isShowPlayVideoIcon, !isVideo {
            showPlayVideoIcon = false
        }
        return MediaResourceView(
            for: MediaResource(
                for: mediaResource, targetSize: TargetSize(width: Int(size), height: Int(size))
            ), placeholder: ZStack {
                Color.black
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)
            }.eraseToAnyView(), isShowPlayVideoIcon: showPlayVideoIcon, isPlaying: .constant(!isVideo))
            .scaledToFill()
            .frame(width: size, height: size)
    }

    private var descriptionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.system(size: 17))
                .foregroundColor(Color.white)
                .padding(.leading, 5)
            ZStack(alignment: .leading) {
                Text(nftsData.description ?? "")
                    .lineLimit(5)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
                    .font(.system(size: 15))
                    .foregroundColor(Color.descriptionNFT.opacity(0.6))
                    .frame(width: UIScreen.main.bounds.width - 66, alignment: .leading)
                    .padding(.top, 15)
                    .padding(.bottom, 18) // PENDING
            }
            .frame(width: UIScreen.main.bounds.width - 32)
            .background(Color.descriptionNFTBG)
            .cornerRadius(12)
            // PENDING
//            Button(action: {
//
//            }) {
//                RoundedRectangle(cornerRadius: .infinity)
//                    .foregroundColor(Color.timelessBlue) // snapAVGColor())
//                    .frame(height: 50)
//                    .overlay(
//                        HStack(spacing: 0) {
//                            Text("\(Image.arrowUpRightCircleFill) View on OpenSea")
//                                .font(.system(size: 17))
//                                .foregroundColor(Color.white) // getButtonTitleColor())
//                        }
//                    )
//            }
//            .padding(.top, 13)
        }
        .padding(.top, 24)
        .padding(.horizontal, 16)
    }

    private var propertiesView: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading) {
                HStack(spacing: 16) {
                    Image.nftsHeaderIcon
                        .resizable()
                        .frame(width: 28, height: 28)
                    Text("Properties")
                        .font(.system(size: 17))
                        .foregroundColor(Color.white)
                    Spacer()
                }
            }
            .padding(.top, 60)
            .padding(.bottom, 12)
            .padding(.horizontal, 16)
            Rectangle()
                .foregroundColor(Color.black)
                .frame(height: 0.25)
                .padding(.horizontal, 16)
                .padding(.bottom, 6.75)
            if let attributeData = nftsData.attributes {
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 10) {
//                        ForEach(0 ..< nftsData.attributes.count) { index in
//                            if nftsData.attributes[index].value == "NONE" {
//                                VStack(spacing: 9) {
//                                    Text(nftsData.attributes[index].trait)
//                                        .font(.system(size: 15))
//                                        .foregroundColor(Color.descriptionNFT.opacity(0.6))
//                                    Text("NONE")
//                                        .font(.system(size: 18, weight: .semibold))
//                                        .foregroundColor(Color.white)
//                                }
//                                .padding(.top, 7)
//                                .padding(.bottom, 13)
//                                .frame(width: 132)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 12)
//                                        .foregroundColor(Color.descriptionNFTBG)
//                                )
//                            }
//                        }
//                    }
//                    .padding(.horizontal, 16)
//                }
//                .padding(.bottom, 10)
                VStack(spacing: 10) {
                    ForEach(0 ..< attributeData.count) { index in
//                        if nftsData.attributes[index].value != "NONE" {
                            VStack(spacing: 0) {
                                Text(attributeData[index].trait)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.descriptionNFT.opacity(0.6))
                                    .padding(.bottom, 9)
                                Text(attributeData[index].value)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color.white)
                                    .padding(.bottom, 8)
                                Text("-% have this trait")
                                // \(nftsData.properties[index].traitPercent)% have this trait") // PENDING
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.descriptionNFT.opacity(0.6))
                            }
                            .padding(.top, 9)
                            .padding(.bottom, 8)
                            .frame(width: UIScreen.main.bounds.width - 32)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundColor(Color.descriptionNFTBG)
                            )
//                        }
                    }
                }
            }
        }
    }

//    private var moreDetailView: some View {
//        VStack(spacing: 0) {
//            HStack(spacing: 0) {
//                menuSocial
//                Spacer()
//            }
//            .padding(.top, 44)
//            .padding(.bottom, 12)
//            Rectangle()
//                .foregroundColor(Color.black)
//                .frame(height: 0.25)
//                .padding(.bottom, 6.75)
//            Text(nftsData.moreDetail)
//                .lineLimit(15)
//                .lineSpacing(2)
//                .font(.system(size: 15))
//                .foregroundColor(Color.descriptionNFT.opacity(0.6))
//                .padding(.horizontal, 17)
//                .padding(.top, 15)
//                .padding(.bottom, 20)
//                .background(
//                    RoundedRectangle(cornerRadius: 12)
//                        .frame(width: UIScreen.main.bounds.width - 32)
//                        .foregroundColor(Color.descriptionNFTBG)
//                )
//        }
//        .padding(.horizontal, 16)
//    }
//
//    private var menuSocial: some View {
//        Menu {
//            Button(action: {
//
//            }) {
//                HStack {
//                    Text("View Collection")
//                    Image.squareGrid2x2Fill
//                }
//            }
//            Button(action: { openURL("https://opensea.io/collection/budverse-cans-heritage-edition") }) {
//                HStack {
//                    Text("Collection Website\n\("opensea.io/collection/budverse-cans-heritage-edition")")
//                    Image(systemName: "safari.fill")
//                }
//            }
//            Button(action: {
//
//            }) {
//                HStack {
//                    Text("Twitter")
//                    Image.atCircleFill
//                }
//            }
//            Button(action: {
//
//            }) {
//                HStack {
//                    Text("Discord")
//                    Image.ellipsisBubbleFill
//                }
//            }
//        } label: {
//            HStack(spacing: 16) {
//                ZStack {
//                    Color.black
//                    mediaView(size: 28, isShowPlayVideoIcon: false)
//                }
//                .frame(width: 28, height: 28)
//                .cornerRadius(5)
//                Text("\(nftsData.name ?? "") \(Image.infoCircle)")
//                    .lineLimit(1)
//                    .font(.system(size: 17))
//                    .foregroundColor(Color.white)
//            }
//        }
//    }

    private var detailsView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button(action: {

                }) {
                    HStack(spacing: 16) {
                        Image.nftsHeaderIcon
                            .resizable()
                            .frame(width: 28, height: 28)
                        Text("Details")
                            .font(.system(size: 17))
                            .foregroundColor(Color.white)
                    }
                }
                Spacer()
            }
            .padding(.top, 52)
            .padding(.bottom, 12)
            Rectangle()
                .foregroundColor(Color.black)
                .frame(height: 0.25)
                .padding(.bottom, 6.75)
            VStack(spacing: 34) {
                // swiftlint:disable line_length
                detailLine(name: "Contract Address",
                           value: collection.contractAddress.address.convertToWalletAddress().trimStringByFirstLastCount(firstCount: 6, lastCount: 5))
                detailLine(name: "Blockchain",
                           value: "Harmony ONE")
                detailLine(name: "Token ID",
                           value: "\(nftsData.tokenId)".trimStringByCount(count: 5))
                detailLine(name: "Token Standard",
                           value: collection.tokenType == .erc721 ? "ERC-721" :
                                  collection.tokenType == .erc1155 ? "ERC-1155" : "-")
            }
            .padding(.top, 22)
            .padding(.bottom, 20)
            .padding(.leading, 13)
            .padding(.trailing, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .frame(width: UIScreen.main.bounds.width - 32)
                    .foregroundColor(Color.descriptionNFTBG)
            )
        }
        .padding(.horizontal, 16)
    }

    private func detailLine(name: String, value: String) -> some View {
        HStack(spacing: 0) {
            Text(name)
                .lineLimit(1)
                .font(.system(size: 17))
                .foregroundColor(Color.white)
            Spacer(minLength: 5)
            Text(value)
                .lineLimit(1)
                .font(.system(size: 17))
                .foregroundColor(Color.white.opacity(0.6))
        }
    }
}

// MARK: - Methods
extension WalletNFTsDetailView {
    private func onTapClose() {
        dismiss()
    }

    private func onTapCopyTokenID() {
        UIPasteboard.general.string = "\(nftsData.tokenId)"
        showSnackBar(.copyTokenID)
    }

    private func onTapSaveToPhotos() {
        guard let imageURL = nftsData.image else {
            return
        }

        getDataFromUrl(url: imageURL) { (data, _, _) in
            guard let data = data, let imageFromData = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                UIImageWriteToSavedPhotosAlbum(imageFromData, nil, nil, nil)
                showSnackBar(.savedToPhotos)
            }
        }
    }

    private func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
        }
        .resume()
    }

    private func onTapBlockExplorer() {
        openURL("https://explorer.harmony.one/address/\(collection.contractAddress.address)")
    }

    private func onTapFloorPriceInfo() {
        showConfirmation(.floorPrice(avgColor: Color.timelessBlue)) // snapAVGColor())) // PENDING
    }

    // PENDING
//    private func snapAVGColor() -> Color {
//        var result = Color.clear
//        let uiimage = mediaView(size: mediaSize, isShowPlayVideoIcon: false).asUIImage()
//        if let uicolor = uiimage.averageColor {
//            result = Color(uicolor)
//        }
//        return result
//    }

//    private func getButtonTitleColor() -> Color {
//        var result = Color.white
//        if UIColor(snapAVGColor()).brightness > 0.7 {
//            result = Color.titleGray
//        }
//        return result
//    }

    private func openURL(_ urlStr: String) {
        if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    private func onTapPrice() {
        withAnimation {
            Utils.playHapticEvent()
            walletBalance.toggle()
        }
    }
}
