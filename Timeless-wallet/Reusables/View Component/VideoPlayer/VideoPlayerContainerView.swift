//
//  VideoPlayerContainerView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/8/21.
//

import SwiftUI
import AVFoundation
import VideoPlayer
import SwiftUIX

struct VideoPlayerContainerView: Equatable {
    static func == (lhs: VideoPlayerContainerView, rhs: VideoPlayerContainerView) -> Bool {
        true
    }

    var url: URL
    @Binding var isPlaying: Bool
    var isAutoPlayback: Bool
    var isMute: Bool
    @State private var isLoading: Bool = true
    @State private var time: CMTime = .zero
    @State private var shouldPauseAtZero = false
    @State private var isPlayingShadow: Bool = true
    @State private var totalDuration: Double = 0

    init(
        url: URL,
        isPlaying: Binding<Bool>,
        isAutoPlayback: Bool = false,
        isMute: Bool = true
    ) {
        self.url = url
        self._isPlaying = isPlaying
        self.isAutoPlayback = isAutoPlayback
        self.isMute = isMute
    }
}

// MARK: - `View` Body
extension VideoPlayerContainerView: View {

    var body: some View {
        VideoPlayer(url: url, play: $isPlayingShadow, time: $time)
            // Todo: autoReplay is cause of scroll shutter
            // .autoReplay(isAutoPlayback)
            .mute(isMute)
            .onStateChanged { state in
                switch state {
                case .loading: break
                case .playing(let totalDuration):
                    if shouldPauseAtZero {
                        time = .zero
                        isPlayingShadow = false
                    }
                    isLoading = false
                    self.totalDuration = totalDuration
                default:
                    isLoading = false
                }
            }
            .loadingOverlay(isShowing: isLoading)
            .onAppear {
                if isLoading && !isPlaying {
                    shouldPauseAtZero = true
                }
            }
            .onChange(of: isPlaying, perform: { isPlaying in
                isPlayingShadow = isPlaying
            })
    }
}
