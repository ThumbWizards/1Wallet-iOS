//
//  MediaResourceView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/8/21.
//

import Foundation
import SwiftUI
import Network
import AVKit
import Kingfisher
import SwiftUIX

public struct MediaResourceView: View {
    static var processorCache: [String: DownsamplingImageProcessor] = [:]
    var placeholder: AnyView?
    var mediaResource: MediaResource?
    var isShowPlayVideoIcon: Bool
    var isAutoPlayback: Bool

    @Binding var isPlaying: Bool

    init(
        for mediaResource: MediaResource?,
        placeholder: AnyView? = ZStack {
            Color.black
            Image.tminus
                .resizable()
                .scaledToFill()
                .frame(width: 66, height: 95)
        }.eraseToAnyView(),
        isShowPlayVideoIcon: Bool = false,
        isAutoPlayback: Bool = false,
        isPlaying: Binding<Bool>
    ) {
        self.mediaResource = mediaResource
        self.placeholder = placeholder
        self._isPlaying = isPlaying
        self.isShowPlayVideoIcon = isShowPlayVideoIcon
        self.isAutoPlayback = isAutoPlayback
    }

    @ViewBuilder
    public var body: some View {
        if let mediaResource = mediaResource {
            switch mediaResource {
            case .webImage(let resource):
                Group {
                    if resource.isStaticImageMediaType {
                        let processor = getDownsamplingImageProcessor(width: resource.targetSize?.width ?? 0,
                                                                      height: resource.targetSize?.height ?? 0)
                        KFImage.url(resource.url)
                            .placeholder { _ in
                                placeholder
                            }
                            .loadDiskFileSynchronously()
                            .cacheMemoryOnly()
                            .setProcessor(processor)
                            .resizable()
                    } else {
                        if isPlaying {
                            KFAnimatedImage.url(resource.url)
                                .configure({ config in
                                    config.framePreloadCount = 3
                                })
                                .placeholder { _ in
                                    placeholder
                                }
                        } else {
                            KFImage.url(resource.url)
                                .placeholder { _ in
                                    placeholder
                                }
                                .loadDiskFileSynchronously()
                                .cacheMemoryOnly()
                                .resizable()
                        }
                    }
                }
                .onDisappear {
                    DispatchQueue.global(qos: .background).async {
                        KingfisherManager.shared.cache.memoryStorage.remove(forKey: resource.url.absoluteString)
                    }
                }
            case .video(let videoResource):
                if videoResource.mediaType == Constants.DataType.youtube {
                    if isShowPlayVideoIcon {
                        YoutubePlayerContainerView(isPlaying: false,
                                                   youtubeView: YouTubeView(url: videoResource.url, isPlaying: false))
                            .disabled(true)
                            .overlay(ZStack {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .background(BlurEffectView(style: .regular))
                                    .clipShape(Circle())
                                Image.playFill
                                    .resizable()
                                    .foregroundColor(Color.playButtonColor)
                                    .opacity(0.9)
                                    .frame(width: 19.84, height: 23.27)
                                    .offset(x: 3)
                            }
                            .frame(width: 60, height: 60)
                            .onTapGesture {
                                UIApplication.shared.open(videoResource.url)
                            })
                    } else {
                        YoutubePlayerContainerView(isPlaying: isPlaying,
                                                   youtubeView: YouTubeView(url: videoResource.url, isPlaying: true))
                    }
                } else {
                    if isShowPlayVideoIcon {
                        AVKit.VideoPlayer(player: .init(url: videoResource.url))
                            .onTapGesture {
                                let player = AVPlayer(url: videoResource.url)
                                let playerController = AVPlayerViewController()
                                playerController.player = player
                                playerController.player?.isMuted = true
                                playerController.allowsPictureInPicturePlayback = true
                                playerController.player?.play()
                                // swiftlint:disable line_length
                                UIApplication.shared.getTopViewController()?.present(playerController, animated: true, completion: nil)
                            }
                    } else {
                        VideoPlayerContainerView(url: videoResource.url,
                                                 isPlaying: $isPlaying,
                                                 isAutoPlayback: isAutoPlayback)
                            .equatable()
                    }
                }
            }
        } else {
            placeholder
        }
    }

    func getDownsamplingImageProcessor(width: Int, height: Int) -> DownsamplingImageProcessor {
        let key = "\(width)-\(height)"
        if Self.processorCache[key] == nil {
            Self.processorCache[key] = DownsamplingImageProcessor(size: CGSize(width: width,
                                                                               height: height))
        }
        return Self.processorCache[key]!
    }
}
