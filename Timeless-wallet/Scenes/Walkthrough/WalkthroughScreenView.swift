//
//  WalkthroughScreenView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 10/25/21.
//

import SwiftUI
import TimelessWeather
import web3swift
import Combine
import BigInt
import Nuke

var walkthroughId = 0

struct WalkthroughScreenView {
    @ObservedObject private var cryptoViewModel = CryptoHelper.shared.viewModel
    @StateObject private var viewModel = ViewModel()
    @State private var page = 0
    @State private var videoToggle = true
    @State private var isPlaying = true

    private let spacingPage: CGFloat = 50
    private let titleIntro = [
        "Smart {Contract}\nWallet",
        "Private and\nSecure",
        "Metaverse.\nIt’s Here.",
        "Begin Your Crypto\nJourney on Timeless",
        "Social. Wallet."
    ]
    // swiftlint:disable line_length
    private let subtitleIntro = [
        "Self-custody without having to remember a long alphanumerical wallet address nonsense",
        "Only you can access your assets.\nNot us. Not anyone else.",
        "Timeless wallet makes Web3\nexperience easier, faster and more\nsecure. It is a social wallet for all of your\nMetaverse journey.",
        "Buy, swap, sell with ease.\nStore and share your NFT collection with friends and family",
        "Join 100,000+ Harmonauts"
    ]
}

extension WalkthroughScreenView: View {
    var body: some View {
        VStack(spacing: 0) {
            contentView
            bottomView
        }
        .background(Color.walkthroughBG)
        .ignoresSafeArea()
        .onReceive(cryptoViewModel.$onboardWalletState) { state in
            if case .error(let error) = state {
                onError(error)
            }
        }
        .onAppear {
            runTextTransition()
        }
        .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime), perform: { _ in
            if page != 0 {
                isPlaying = false
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification), perform: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                walkthroughId += 1
                page = 0
                isPlaying = true
                videoToggle.toggle()
            }
        })
        .id(videoToggle)
    }
}

extension WalkthroughScreenView {
    private var contentView: some View {
        VStack(spacing: 0) {
            ZStack {
                MediaResourceView(for: MediaResource(for: MediaResourceVideo(url: Bundle.main.url(
                    forResource: "walkthroughIntro", withExtension: "mp4")!)), isPlaying: $isPlaying)
            }
            .scaledToFit()
            .padding(.horizontal, -23)
            .padding(.top, UIView.hasNotch ? 67 : 25)
            ZStack(alignment: .top) {
                ForEach(0 ..< titleIntro.count) { index in
                    IntroText(
                        page: $page,
                        isPlaying: $isPlaying,
                        index: index,
                        spacingPage: spacingPage,
                        title: titleIntro[index],
                        subtitle: subtitleIntro[index]
                    )
                }
            }
            Spacer(minLength: 0)
        }
    }

    struct IntroText: View {
        @Binding var page: Int
        @Binding var isPlaying: Bool
        @State var opacity = false
        @State var offsetX = CGFloat.zero
        var index: Int
        var spacingPage: CGFloat
        var title: String
        var subtitle: String

        var body: some View {
            VStack(spacing: 0) {
                Text(title)
                    .tracking(-0.2)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(Color.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, UIView.hasNotch ? 23 : 10)
                Text(subtitle)
                    .tracking(-0.2)
                    .font(.system(size: 15))
                    .foregroundColor(Color.noContactDetail)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 53)
            }
            .onAppear {
                opacity = index == 0
                if page == index {
                    offsetX = 0
                } else if page < index {
                    offsetX = spacingPage
                } else {
                    offsetX = -spacingPage
                }
            }
            .offset(x: offsetX)
            .opacity(opacity ? 1 : 0)
            .onChange(of: page) { value in
                if !isPlaying { return }
                if value == index {
                    let temp = walkthroughId
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        guard temp == walkthroughId else {
                            return
                        }
                        withAnimation(.easeInOut(duration: 0.8)) {
                            offsetX = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            guard temp == walkthroughId else {
                                return
                            }
                            withAnimation(.easeInOut(duration: 0.8)) {
                                opacity = true
                            }
                        }
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        opacity = false
                        if page < index {
                            offsetX = spacingPage
                        } else {
                            offsetX = -spacingPage
                        }
                    }
                }
            }
        }
    }

    private var bottomView: some View {
        VStack(spacing: 19) {
            HStack {
                Spacer()
                Text("Create a New Wallet")
                    .foregroundColor(Color.white)
                    .font(.system(size: 17, weight: .regular))
                Spacer()
            }
            .padding(.vertical, 18)
            .background(LinearGradient(colors: [Color.walkthroughBGLinearLeading, Color.walkthroughBGLinearTrailing],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing))
            .cornerRadius(12)
            .padding(.horizontal, 24)
            .onTapGesture {
                DispatchQueue.main.async {
                    showConfirmation(.createWallet, interactiveHide: false)
                    viewModel.createWallet()
                }
            }
            Button(action: {
                showLoadingModal(inputModalType: .importWallet)
            }) {
                Text("I already have one")
                    .foregroundColor(Color.walkthroughAlreadyHave.opacity(0.8))
                    .font(.system(size: 14, weight: .medium))
            }
        }
        .padding(.top, 28)
        .padding(.bottom, UIView.safeAreaBottom + 19)
        .frame(maxWidth: .infinity, alignment: .bottom)
    }
}

extension WalkthroughScreenView {
    private func showLoadingModal(inputModalType: ConfirmationType) {
        showConfirmation(inputModalType)
    }

    private func onError(_ error: OneWalletService.NewWalletError) {
        switch error {
        case .couldNotGenerateSeed, .couldNotGenerateWalletPayload:
            CryptoHelper.shared.generateWalletPayloadSilent()
        default: break
        }
        showSnackBar(.error(error))
    }

    private func runTextTransition() {
        let temp = walkthroughId
        DispatchQueue.main.asyncAfter(deadline: .now() + (
            page == 0 ? 4.3 :
                page == 1 ? 3.8 :
                page == 2 ? 4.1 :
                page == 3 ? 5.8 : 5.6
        )) {
            guard temp == walkthroughId else {
                return
            }
            withAnimation(.easeInOut(duration: 0.8)) {
                page += 1
                if page < 5 {
                    runTextTransition()
                } else {
                    page = 4
                }
            }
        }
    }
}
