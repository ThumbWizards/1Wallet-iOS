//
//  WalletAvatar.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 28/01/22.
//

import Foundation
import SwiftUI

struct WalletAvatar: View {
    var wallet: Wallet
    var frame = CGSize.zero
    var isCircle = true
    @State private var forceRefresh = false
    @State private var renderVideo = false

    var body: some View {
        ZStack {
            let mediaType = wallet.avatarUrl?.split(separator: ".").last ?? ""
            let walletAvatar = MediaResourceModel(
                path: wallet.avatar,
                altText: nil,
                pathPrefix: nil,
                mediaType: String(mediaType),
                thumbnail: nil
            )
            contentView(walletAvatar)
                .id("\(walletAvatar.isVideoMediaType() ? "\(renderVideo)" : "")\(forceRefresh)")
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            renderVideo.toggle()
        }
        .onChange(of: wallet.avatarUrl) { _ in
            withAnimation(.easeInOut) {
                forceRefresh.toggle()
            }
        }
    }
}

extension WalletAvatar {
    private func contentView(_ walletAvatar: MediaResourceModel) -> some View {
        MediaResourceView(for: MediaResource(for: walletAvatar,
                                                targetSize: TargetSize(width: Int(frame.width) + 100,
                                                                       height: Int(frame.height) + 100)),
                             placeholder: WalletPlaceHolder(cornerRadius: isCircle ? .infinity : .zero)
                                .eraseToAnyView(),
                             isAutoPlayback: true,
                             isPlaying: .constant(true))
            .scaledToFill()
            .animation(.easeInOut, value: wallet.avatarUrl)
            .frame(frame)
            .background(walletAvatar.isVideoMediaType() ? Color.black : Color.almostClear)
            .cornerRadius(isCircle ? .infinity : .zero)
    }
}

struct WalletPlaceHolder: View {
    @State private var isShowed = false
    var cornerRadius: CGFloat = 10

    var body: some View {
        Color.white.opacity(0.05)
            .overlay(LoadingShimmerView(isShowed: isShowed, color: Color.placeHolderBalanceBG.opacity(0.9)))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(Animation.default.speed(0.15).delay(0).repeatForever(autoreverses: false)) {
                        isShowed.toggle()
                    }
                }
            }
            .cornerRadius(cornerRadius)
    }
}
