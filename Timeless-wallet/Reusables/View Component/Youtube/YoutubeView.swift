//
//  YoutubeView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/8/21.
//

import SwiftUI
import UIKit
import YouTubePlayer

// YouTubeView use to load a YouTube video content
public struct YouTubeView: UIViewRepresentable {
    public typealias UIViewType = YouTubePlayerView

    // For example: https://www.youtube.com/watch?v=0we7kcmgDOw
    // videoID = 0we7kcmgDOw
    var videoID: String?

    // isPlaying is control the pause/resume state
    var isPlaying: Bool

    init(url: URL, isPlaying: Bool = false) {
        self.isPlaying = isPlaying
        self.videoID = url.absoluteString.youtubeID
    }

    // init view
    public func makeUIView(context: Context) -> UIViewType {
        // Support parameters to control how youtube video should be displayed
        // more detail: https://developers.google.com/youtube/player_parameters#Parameters
        let playerVars = [
            "playsinline": "1",
            "controls": "0",
            "fs": "0",
            "rel": "0",
            "loop": "1"
        ]
        let youtubePlayer = YouTubePlayerView()
        youtubePlayer.playerVars = playerVars as YouTubePlayerView.YouTubePlayerParameters
        return youtubePlayer
    }

    // update video state (play/pause) whenever the UI change
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let videoID = videoID else { return }
        if uiView.ready {
            isPlaying ? uiView.play() : uiView.pause()
        } else if !uiView.ready {
            uiView.loadVideoID(videoID)
        }
    }
}
