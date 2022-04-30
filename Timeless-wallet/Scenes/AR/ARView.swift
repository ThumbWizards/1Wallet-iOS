//
//  ARView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 4/1/22.
//

import SwiftUI
import CollectionViewPagingLayout
import ARKit

struct ARView {
    // MARK: - Variables
    @StateObject private var viewModel = ViewModel.shared
    @State private var showingPreview = false
    @State private var activeCard: CarouselItem.ID? = 0
    @State private var selectedModel: Discover!
    var options: ScaleTransformViewOptions {
        return ScaleTransformViewOptions(
            minScale: 0.9,
            maxScale: 1,
            translationRatio: CGPoint(x: 0.95, y: 0.8),
            maxTranslationRatio: CGPoint(x: 2, y: 0),
            scaleCurve: .linear,
            translationCurve: .linear
        )
    }
}

extension ARView: View {
    var body: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()
            VStack {
                headerView
                    .padding(.vertical, 10)
                TransformPageView(viewModel.discoverItems, selection: $activeCard) { item, progress in
                    ZStack(alignment: .top) {
                        VStack {
                            ZStack(alignment: .leading) {
                                VStack {
                                    HStack {
                                        VStack {
                                            Text(item.modelDetails)
                                                .font(.system(size: 22, weight: .bold))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        Spacer()
                                        Image.arkit
                                            .padding()
                                    }
                                    .padding(.horizontal, 15)
                                    Spacer()
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Demo")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text(item.name.uppercased())
                                            .font(.futuraStdExtraBold(size: 28))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.bottom, 10)
                                        HStack(spacing: 0) {
                                            Group {
                                                HStack {
                                                    Text("EXPLORE")
                                                        .font(.sfProDisplayBold(size: 16))
                                                        .foregroundColor(.white)
                                                    Image(systemName: "play.fill")
                                                }
                                            }
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 15)
                                            .padding(.vertical, 5)
                                            .frame(width: 165, alignment: .center)
                                            .background(Color.discoverExploreBg)
                                            .cornerRadius(4)
                                            .padding(.trailing, 4)
                                            Image.squareAndArrowUp
                                                .foregroundColor(.white)
                                                .frame(width: 30, height: 30)
                                                .background(Color.almostClear)
                                            HeartButtonDiscover()
                                        }
                                    }
                                    .onTapGesture(perform: {
                                        selectedModel = viewModel.discoverItems[activeCard ?? 0]
                                        if let topVC = UIApplication.shared.getTopViewController(),
                                           let objectUrl = Bundle.main.path(
                                            forResource: selectedModel.modelName,
                                            ofType: "usdz"
                                           ) {
                                            ARPreviewVC().show(controller: topVC, with: URL(fileURLWithPath: objectUrl))
                                        }
                                    })
                                    .padding()
                                }
                            }
                            .padding(.bottom, 15)
                            .frame(maxHeight: .infinity)
                        }
                    }
                    .background {
                        ZStack {
                            if item.id == 3 || item.id == 4 {
                                Color.black
                            } else {
                                Color.white
                            }
                            Image(item.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width - 30, height: UIScreen.main.bounds.height * 0.4)
                            Color.primaryBackground
                                .opacity(0.3)

                        }
                        .cornerRadius(10)
                    }
                    .scaleEffect(1 - abs(progress) * 0.3)
                    .transformEffect(.init(translationX: 0, y: max((progress * 1000), 0)))
                }
                .pagePadding(
                    top: .absolute(0),
                    left: .absolute(0),
                    bottom: .absolute(60),
                    right: .absolute(0)
                )
                .scrollDirection(.vertical)
            }
            .padding(.horizontal, 15)
        }
        .onChange(of: self.activeCard, perform: { _ in
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
        })
    }
}

extension ARView {
    private var headerView: some View {
        HStack {
            VStack(spacing: 5) {
                Text("NFT Showcase")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.discoverText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Mint, showcase, buy NFTs")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white40)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer()
            Button(action: { onTapBack() }) {
                Image.closeBackup
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 30)
            }
        }
        .padding(.top, 15)
    }
}

extension ARView {
    struct HeartButtonDiscover: View {
        // MARK: - Properties
        @State private var isPlayHeartAnimate = false
        @State private var isHideHeartIcon = false
        @State private var isLiked = false

        var body: some View {
            ZStack {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .resizable()
                    .frame(width: 17, height: 15)
                    .foregroundColor(isHideHeartIcon ? .clear : .white)
                    .background(
                        isPlayHeartAnimate ? LottieView(name: "heart-animated",
                                                        loopMode: .constant(.playOnce),
                                                        isAnimating: .constant(true),
                                                        tintColor: .white)
                            .scaledToFit()
                            .frame(width: 32, height: 32) : nil
                    )
                    .offset(y: 1)
                    .frame(width: 20, height: 20)
                    .overlay(Color.almostClear.onTapGesture {
                        if !isLiked {
                            isHideHeartIcon = true
                        }
                        withAnimation {
                            if !isLiked {
                                isPlayHeartAnimate = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    if isPlayHeartAnimate {
                                        isPlayHeartAnimate = false
                                    }
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    isHideHeartIcon = false
                                }
                            }
                            isLiked.toggle()
                        }
                    })
            }
            .frame(width: 30, height: 30)
        }
    }
}

extension ARView {
    private func onTapBack() {
        dismiss()
    }
}
