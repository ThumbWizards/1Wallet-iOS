//
//  WalletNFTsView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 10/01/2022.
//

import SwiftUI

struct WalletNFTsView {
    // MARK: - Properties
    @ObservedObject var viewModel: ViewModel
    @State private var renderUI = false
}

// MARK: - Subview
extension WalletNFTsView: View {
    var body: some View {
        ZStack(alignment: .top) {
            if !viewModel.isLoading {
                if !viewModel.modelData.isEmpty {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 52) {
                            // totalCollectible // PENDING
                            VStack(spacing: 38) {
                                ForEach(0 ..< viewModel.modelData.count) { idx in
                                    NFTCollectionView(collection: viewModel.modelData[idx].0, nftList: viewModel.modelData[idx].1) { collection, tokenData in
                                        present(WalletNFTsDetailView(
                                            nftsData: tokenData,
                                            collection: collection
                                        ), presentationStyle: .fullScreen)
                                    }
                                }
                            }
                            showcaseButton
                        }
                        .padding(.top, 15) // .padding(.top, 31) // PENDING WITH TOTAL COLLECTIBLE
                        .padding(.bottom, 52)
                    }
                    .padding(.top, 15)
                } else {
                    VStack(spacing: 0) {
                        noNFTsView
                        showcaseButton
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            renderUI.toggle()
        }
        .loadingOverlay(isShowing: viewModel.isLoading)
    }
}

extension WalletNFTsView {
    private var totalCollectible: some View {
        RoundedRectangle(cornerRadius: 10)
            .foregroundColor(Color.sendTextFieldBG)
            .frame(height: 162)
            .overlay(
                Image.bigPig
                    .resizable()
                    .frame(width: 58, height: 59)
                    .padding(.trailing, 24)
                    .padding(.bottom, 28), alignment: .bottomTrailing
            )
            .overlay(
                VStack(alignment: .leading, spacing: 0) {
                    Text("Total Collectible Value")
                        .tracking(0.23)
                        .font(.system(size: 20))
                        .foregroundColor(Color.white)
                        .padding(.top, 23)
                    Text("By Floor Price")
                        .tracking(-0.15)
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.8))
                        .padding(.top, 11.5)
                    Text("$1,000,000")
                        .tracking(1)
                        .font(.system(size: 23, weight: .bold))
                        .foregroundColor(Color.timelessBlue)
                        .padding(.top, 12.5)
                    Text("4,000,000 ONES")
                        .tracking(0.3)
                        .font(.system(size: 14))
                        .foregroundColor(Color.exchangeCurrency)
                        .padding(.top, 5.5)
                        .padding(.leading, 4)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 18), alignment: .topLeading
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
    }

    private var noNFTsView: some View {
        VStack(spacing: 0) {
            Text(" ")
                .font(.system(size: 55, weight: .bold))
            Text("No NFTs yet")
                .tracking(0.7)
                .lineLimit(1)
                .font(.system(size: 18))
                .foregroundColor(Color.exchangeCurrency)
                .padding(.bottom, UIView.hasNotch ? 52 : 22)
            if renderUI {
                loadingNFT
            } else {
                loadingNFT
            }
        }
        .padding(.top, 3)
    }

    private var loadingNFT: some View {
        LottieView(name: "nftsLottie", loopMode: .constant(.loop), isAnimating: .constant(true))
            .scaledToFill()
            .aspectRatio(255 / 236, contentMode: .fit)
            .padding(.horizontal, 72)
            .padding(.bottom, UIView.hasNotch ? 79 : 59)
            .offset(x: -3)
    }

    private var showcaseButton: some View {
        Button(action: { onTapNFTShowcase() }) {
            Rectangle()
                .foregroundColor(Color.walletDetailBottomBtn)
                .frame(height: 70)
                .overlay(
                    HStack(spacing: 0) {
                        WalletAvatar(wallet: viewModel.wallet, frame: CGSize(width: 40, height: 40))
                            .padding(.trailing, 10)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("NFT Showcase")
                                .font(.system(size: 17))
                                .foregroundColor(Color.white)
                            Text("Explore")
                                .font(.system(size: 15))
                                .foregroundColor(Color.walletDetailDeposit)
                        }
                        Spacer(minLength: 0)
                        Text("Coming Soon")
                            .font(.system(size: 14))
                            .foregroundColor(Color.walletDetailComingSoon)
                            .padding(.trailing, 9.5)
                        Image.chevronRight
                            .resizable()
                            .frame(width: 9, height: 16)
                            .foregroundColor(Color.walletDetailChevronRight)
                            .padding(.trailing, 14)
                    }
                    .padding(.leading, 12), alignment: .leading
                )
                .cornerRadius(12)
        }
        .padding(.horizontal, 22)
    }
}

// MARK: - Methods
extension WalletNFTsView {
    private func onTapNFTShowcase() {
        // TODO: PENDING
    }
}
