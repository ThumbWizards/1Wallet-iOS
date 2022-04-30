//
//  DiscoverCardView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 3/7/22.
//

import SwiftUI
import CollectionViewPagingLayout
import SwiftUIX

struct DiscoverCardType1View {
    struct DataModel {
        var title: String?
        var description: String?
        var bannerUrl: String?
        var ctaType: String?
        var ctaData: [String: Any]?
    }
    let data: DataModel
    let cardSize = CGSize(width: UIScreen.main.bounds.width - 32,
                          height: (UIScreen.main.bounds.width - 32) * 1.24)
}

extension DiscoverCardType1View: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            mediaView
            VStack(alignment: .leading, spacing: 2) {
                Text(data.title ?? "")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.white)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text(data.description ?? "")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color.descriptionDiscoverColor)
                    .tracking(0.2)
                    .lineLimit(3)
                    .minimumScaleFactor(0.5)
            }
            .padding(.leading, 25)
            .padding(.trailing, 34)
            .padding(.top, 14)
            .padding(.bottom, 20)
            .frame(width: cardSize.width, height: cardSize.height - (cardSize.width * 0.84), alignment: .topLeading)
        }
        .frame(width: cardSize.width, height: cardSize.height)
        .background(Color.searchBackground)
        .cornerRadius(20)
        .clipped()
        .onTapGesture {
            onTapActionCard()
        }
    }
}

extension DiscoverCardType1View {
    private var mediaView: some View {
        var mediaResource: MediaResource?
        if let path = data.bannerUrl {
            let targetSize = TargetSize(width: Int(cardSize.width),
                                        height: Int(cardSize.width * 0.84))
            let mediaType = path.isYoutubeVideo ? "youtube" : path.split(separator: ".").last ?? ""
            let resourceModel = MediaResourceModel(
                path: path,
                altText: nil,
                pathPrefix: nil,
                mediaType: String(mediaType),
                thumbnail: nil
            )
            mediaResource = MediaResource(for: resourceModel, targetSize: targetSize)
        }
        return MediaResourceView(for: mediaResource,
                                    placeholder: ProgressView()
                                        .progressViewStyle(.circular)
                                        .scaleEffect(1.2)
                                        .eraseToAnyView(),
                                    isAutoPlayback: true,
                                    isPlaying: .constant(true))
            .scaledToFill()
            .frame(width: cardSize.width,
                   height: cardSize.width * 0.84)
            .clipped()
            .background(Color.black)
    }
}

extension DiscoverCardType1View {
    private func onTapActionCard() {
        guard let ctaType = data.ctaType, let ctaData = data.ctaData else {
            return
        }
        DiscoverHelper.shared.makeAction(ctaType: ctaType, ctaData: ctaData)
    }
}
