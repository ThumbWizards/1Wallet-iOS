//
//  MediaResource.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/8/21.
//

import Foundation

public struct TargetSize: Hashable {
    public let width: Int?
    public let height: Int?
}

public struct MediaResourceWebImage: Hashable {
    public let url: URL
    public let isAnimated: Bool
    public let targetSize: TargetSize?
    public let mediaType: String?
    public let isCaching: Bool

    init(url: URL, isAnimated: Bool, targetSize: TargetSize? = nil, mediaType: String? = nil, isCaching: Bool = false) {
        self.url = url
        self.isAnimated = isAnimated
        self.targetSize = targetSize
        self.mediaType = mediaType
        self.isCaching = isCaching
    }

    var isStaticImageMediaType: Bool {
        // Todo: could not check with mediaType b/c BE is returning a wrong mediaType
        return url.absoluteString.hasSuffix("jpg") || url.absoluteString.hasSuffix("png")
    }
}

public struct MediaResourceVideo: Hashable {
    public let url: URL
    public let mediaType: String?

    init(url: URL, mediaType: String? = nil) {
        self.url = url
        self.mediaType = mediaType
    }
}

public enum MediaResource {

    case webImage(MediaResourceWebImage)
    case video(MediaResourceVideo)
    // case bundledImage(String)

    init(for mediaResource: MediaResourceModel, targetSize: TargetSize? = nil) {
        if mediaResource.isVideoMediaType() {
            if let url = URL(string: mediaResource.url()) {
                self = .video(
                    MediaResourceVideo(
                        url: url,
                        mediaType: mediaResource.mediaType
                    )
                )
                return
            }
        } else {
            if let url = URL(string: mediaResource.customUrl(width: targetSize?.width, height: targetSize?.height)) ??
                mediaResource.customUrl(width: targetSize?.width, height: targetSize?.height).encodedUrl() {
                self = .webImage(
                    MediaResourceWebImage(
                        url: url,
                        isAnimated: true,
                        targetSize: targetSize,
                        mediaType: mediaResource.mediaType
                    )
                )
                return
            }
        }
        self = MediaResource(
            for: MediaResourceWebImage(
                // swiftlint:disable line_length
                url: URL(string: "https://res.cloudinary.com/timeless/image/upload/v1627420709/app/event_cards/3D%20-%20Gifs/54_SAILING.gif")!,
                isAnimated: true
            )
        )
    }

    init(for webImage: MediaResourceWebImage) {
        self = .webImage(webImage)
    }

    init(for video: MediaResourceVideo) {
        self = .video(video)
    }
}

extension MediaResource: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .webImage(webImage):
            webImage.hash(into: &hasher)
        case let .video(video):
            video.hash(into: &hasher)
        }
    }

    public static func == (lhs: MediaResource, rhs: MediaResource) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
