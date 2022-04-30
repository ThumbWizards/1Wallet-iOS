//
//  DiscoverCardType2View.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 3/8/22.
//

import SwiftUI

struct DiscoverCardType2View {
    struct DataModel {
        var superscript: String?
        var title: String?
        var bannerUrl: String?
    }
    var data: DataModel
    private let cardSize = CGSize(width: (UIScreen.main.bounds.width - 40),
                                  height: (UIScreen.main.bounds.width - 40) * 1.33)
}

extension DiscoverCardType2View: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            mediaView
                .overlay(Rectangle()
                            .foregroundColor(.clear)
                            .background(Color.primaryBackground.opacity(0.3)))
            VStack(spacing: 12) {
                Text(data.superscript ?? "")
                    .font(.futuraBook(size: 17))
                    .foregroundColor(Color.white)
                    .lineLimit(1)
                Text(data.title ?? "")
                    .font(.futuraExtraBoldOblique(size: 36))
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .padding(.bottom, 28)
            .padding(.horizontal, 18)
        }
        .frame(width: cardSize.width, height: cardSize.height)
        .cornerRadius(10)
    }
}

extension DiscoverCardType2View {
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
                                    isShowPlayVideoIcon: false,
                                    isPlaying: .constant(true))
            .scaledToFill()
            .frame(width: cardSize.width,
                   height: cardSize.height)
            .cornerRadius(10)
    }
}
