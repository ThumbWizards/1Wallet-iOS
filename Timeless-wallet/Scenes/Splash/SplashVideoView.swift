//
//  SplashVideoView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 11/02/2022.
//

import SwiftUI

struct SplashVideoView {
    // MARK: - Input Parameters
    @Binding var isPlayingSplash: Bool
    var isLocked = true

    // MARK: - Properties
    @State private var alreadyDismiss = false
    @State private var animateSplash = false

    @AppStorage(ASSettings.General.firstLaunch.key)
    private var firstLaunch = ASSettings.General.firstLaunch.defaultValue
}

// MARK: - Body view
extension SplashVideoView: View {
    var body: some View {
        ZStack {
            if !isLocked {
                Color.black
            }
            ZStack {
                MediaResourceView(for: MediaResource(for: MediaResourceVideo(url: Bundle.main.url(
                    forResource: "splash", withExtension: "mp4")!)), isPlaying: $isPlayingSplash)
            }
            .scaledToFit()
            .padding(.horizontal, 70)
            .scaleEffect(isLocked ? 1 : (animateSplash ? 1 : 0.7))
            .opacity(isLocked ? 1 : (animateSplash ? 1 : 0))
        }
        .ignoresSafeArea()
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            if !isLocked, isPlayingSplash {
                dismiss()
                alreadyDismiss = true
            }
        }
        .onAppear {
            firstLaunch = false
            if !isLocked {
                UIApplication.shared.endEditing()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation {
                        animateSplash = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.4) {
                            withAnimation {
                                animateSplash = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                if !alreadyDismiss {
                                    dismiss()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension SplashVideoView {
    class ViewModel: ObservableObject {
        // MARK: - Variables
        @Published var hideScreen = true
    }
}

extension SplashVideoView.ViewModel {
    static let shared = SplashVideoView.ViewModel()
}
