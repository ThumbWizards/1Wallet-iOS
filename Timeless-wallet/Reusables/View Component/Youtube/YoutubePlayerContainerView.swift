//
//  YoutubePlayerContainerView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/8/21.
//

import SwiftUI

struct YoutubePlayerContainerView {
    var youtubeView: YouTubeView

    // MARK: - Init
    init(
        isPlaying: Bool = false,
        youtubeView: YouTubeView
    ) {
        self.youtubeView = youtubeView
        self.youtubeView.isPlaying = isPlaying
    }
}

// MARK: - `View` Body
extension YoutubePlayerContainerView: View {
    var body: some View {
        youtubeView
    }
}
