//
//  MediaResourceModel.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/8/21.
//

import AVKit
import Foundation

public struct MediaResourceModel: Codable, Hashable {
    public init(path: String, altText: String?, pathPrefix: String?, mediaType: String?, thumbnail: String?) {
        self.path = path
        self.altText = altText ?? "Media Resource"
        self.pathPrefix = pathPrefix
        self.mediaType = mediaType
        self.thumbnail = thumbnail
    }

    public var path: String
    public var altText: String?
    public var pathPrefix: String?
    public var mediaType: String?
    public var thumbnail: String?

    public func url(width: Int? = nil, height: Int? = nil) -> String {
        if isCloudinaryURL {
            var sizing = ""
            if width != nil {
                sizing = "w_\(width!)"
                if height != nil {
                    sizing += ",h_\(height!)"
                }
                sizing += "/"
            }
            return "\(pathPrefix!)\(sizing)\(path)"
        }
        return "\(pathPrefix ?? "")\(path)"
    }
}

extension MediaResourceModel {
    func isVideoMediaType() -> Bool {
        guard let mediaType = mediaType else { return false }
        let videoTypes = Constants.DataType.videos
        return videoTypes.contains(mediaType)
    }

    func customUrl(width: Int? = nil, height: Int? = nil) -> String {
        return url(width: width, height: height)
    }

    func url(width: Int? = nil, height: Int? = nil) -> URL? {
        let urlString: String = url(width: width, height: height)
        return URL(string: urlString) ?? urlString.encodedUrl()
    }

    var feedUrl: URL? {
        return URL(string: path)
    }

    var isFeedVideo: Bool {
        path.hasSuffix(".mp4") || path.hasSuffix(".avi") || isYoutubeVideo
    }

    var isYoutubeVideo: Bool {
        feedUrl?.host?.hasSuffix("youtu.be") ?? false || feedUrl?.host?.hasSuffix("youtube.com") ?? false
    }

    var isCloudinaryURL: Bool {
        pathPrefix?.starts(with: "https://res.cloudinary.com") == true
    }

    func playVideo() {
        guard let feedUrl = feedUrl, isFeedVideo else {
            return
        }
        if isYoutubeVideo {
            UIApplication.shared.open(feedUrl)
        } else {
            let player = AVPlayer(url: feedUrl)
            let playerController = AVPlayerViewController()
            playerController.player = player
            playerController.allowsPictureInPicturePlayback = true
            playerController.player?.play()
            UIApplication.shared.getTopViewController()?.present(playerController, animated: true, completion: nil)
        }
    }
}
