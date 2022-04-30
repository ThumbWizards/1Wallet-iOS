//
//  ProfilePictureNFTsModal.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 2/8/22.
//

import SwiftUI
import Combine

struct ProfilePictureNFTsModal {
    var wallet: Wallet
    var onChangeAvatar: ((UIImage) -> Void)?
    @ObservedObject private var viewModel = ViewModel.shared
    @State private var tempData: [(NFTInfo, [NFTTokenMetadata])] = []
    @State private var updateAvatarWalletCancelable: AnyCancellable?
    @State private var isLoading = false
    @AppStorage(ASSettings.ProfilePicture.connected.key)
    private var connectWallet = ASSettings.ProfilePicture.connected.defaultValue
    @State private var renderUI = false
}

extension ProfilePictureNFTsModal: View {
    var body: some View {
        ZStack(alignment: .top) {
            Color.sheetBG
            VStack(spacing: 0) {
                ZStack {
                    Text("Profile Picture NFTs")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.white)
                    HStack {
                        Button {
                            onClose()
                        } label: {
                            Image.closeBackup
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 30)
                        }
                        Spacer()
                    }

                    HStack {
                        Spacer()
                        Button {
                            present(ProfileDetailModal(wallet: WalletInfo.shared.currentWallet,
                                                       connectWallet: connectWallet))
                        } label: {
                            HStack {
                                Image.infoCircle
                                    .foregroundColor(Color.white)
                            }
                        }
                    }
                }
                .padding(.horizontal, 19)
                .padding(.bottom, 33)
                if !connectWallet {
                    noWalletConnectView
                } else {
                    walletConnectedView
                }
            }
            .padding(.top, UIView.safeAreaTop + 15)
        }
        .ignoresSafeArea()
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            renderUI.toggle()
        }
    }
}

extension ProfilePictureNFTsModal {
    private var noWalletConnectView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Text("DEMO PURPOSE ONLY")
                    .font(.phosphate(size: 22))
                    .foregroundColor(Color.white)
                    .padding(.top, 31)
                if renderUI {
                    lottieView
                } else {
                    lottieView
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("1wallet Exploratory Feature")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(Color.white)
                        .padding(.bottom, 5)
                    Text("Flex your prized possessions")
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundColor(Color.white)
                        .padding(.bottom, 14)
                    // swiftlint:disable line_length
                    Text("Own an Ape on Ethereum? Now you can set your profile picture to an NFT you own by connecting your crypto wallet and verifying your address. ")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color.white60)
                    Spacer()
                        .minHeight(93)
                    Text("Given the public nature of blockchain, by connecting your wallet, others will be able to associate your profile and your wallet address.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color.white40)
                }
                .padding(.leading, 33)
                .padding(.trailing, 30)
                .padding(.bottom, 25)
                Button {
                    showConfirmation(.connectWallet)
                } label: {
                    Text("Connect to Ethereum")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(Color.white87)
                        .frame(width: UIScreen.main.bounds.width - 85, height: 41)
                        .background(Color.walletDetailBottomBtn.cornerRadius(20.5))
                }
            }
        }
    }

    private var lottieView: some View {
        LottieView(name: "revised_red", loopMode: .constant(.loop), isAnimating: .constant(true))
            .scaledToFill()
            .frame(width: 124, height: 124)
            .scaleEffect(1.5)
            .offset(x: -4, y: -6)
            .padding(.top, 33)
            .padding(.bottom, 17)
    }

    private var walletConnectedView: some View {
        ScrollView {
            VStack(spacing: 38) {
                HStack {
                    Text("MY NFTs")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color.white)
                    Spacer()
                }
                .padding(.leading, 16)
                ForEach(0 ..< DataSample.List.count) { idx in
                    NFTCollectionView(collection: DataSample.List[idx].0,
                                      nftList: DataSample.List[idx].1,
                                      capTitle: false,
                                      showPlayButton: false) { _, data in
                        onSelected(data.image?.absoluteString ?? "")
                        onClose()
                    }
                }
                VStack(alignment: .leading, spacing: 11) {
                    Text("EXPRESS YOUR DIGITAL SELF")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color.white)
                        .padding(.leading, 16)
                    VStack(spacing: 14) {
                        HStack {
                            Image.checkerBoardShield
                            Text("Mint NFT")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(Color.white)
                            Spacer()
                            Text("COMING SOON")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Color.white40)
                        }
                        Divider()
                        HStack {
                            Image.photoCircle
                            Text("Browse Shop")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(Color.white)
                            Spacer()
                            Text("COMING SOON")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Color.white40)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 15)
                    .background(Color.walletDetailBottomBtn.cornerRadius(10))
                    .padding(.horizontal, 16)
                    // swiftlint:disable line_length
                    Text("Express yourself. Now with Timeless, you can easily mint your own Profile Picture NFTs (PFPs) with a single tap of a menu and participate in a contactless cyber fashion.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color.white40.opacity(0.6))
                        .padding(.horizontal, 23)
                }
                .padding(.bottom, UIView.safeAreaBottom + 41)
            }
// TODO
//            } else {
//                VStack(spacing: 0) {
//                    VStack(alignment: .leading, spacing: 5) {
//                        Text("Your connected wallet doesn’t have any NFT assets")
//                            .font(.system(size: 20, weight: .regular))
//                            .foregroundColor(Color.white)
//                        Text("NFTs that you own will be displayed here")
//                            .font(.system(size: 15, weight: .regular))
//                            .foregroundColor(Color.white60)
//                    }
//                    .padding(.horizontal, 40)
//                    LottieView(name: "revised_red", loopMode: .constant(.loop), isAnimating: .constant(true))
//                        .scaledToFill()
//                        .frame(width: 124, height: 124)
//                        .scaleEffect(1.5)
//                        .offset(x: -4, y: -6)
//                        .padding(.top, 55)
//                        .padding(.bottom, 62)
//                    VStack(spacing: 11) {
//                        Text("Try connecting another wallet")
//                            .font(.system(size: 15, weight: .regular))
//                            .foregroundColor(Color.white60)
//                        Button {
//                            let modal = CustomPresentedViewController()
//                            let hostView = UIHostingController(rootView: ConnectWalletModal())
//                            modal.set(contentViewController: hostView)
//                            UIApplication.shared.getTopViewController()?.view.clipsToBounds = true
//                            UIApplication.shared.getTopViewController()?.present(modal, animated: true)
//                        } label: {
//                            Text("Connect to Ethereum")
//                                .font(.system(size: 17, weight: .regular))
//                                .foregroundColor(Color.white87)
//                                .frame(width: UIScreen.main.bounds.width - 85, height: 41)
//                                .background(Color.walletDetailBottomBtn.cornerRadius(20.5))
//                        }
//                    }
//                    .padding(.bottom, 28)
//                    Divider()
//                        .padding(.bottom, 33)
//                        .padding(.horizontal, 25)
//                    VStack(alignment: .leading, spacing: 11) {
//                        Text("EXPRESS YOUR DIGITAL SELF")
//                            .font(.system(size: 17, weight: .semibold))
//                            .foregroundColor(Color.white)
//                            .padding(.leading, 16)
//                        VStack(spacing: 14) {
//                            HStack {
//                                Image.checkerBoardShield
//                                Text("Mint NFT")
//                                    .font(.system(size: 17, weight: .regular))
//                                    .foregroundColor(Color.white)
//                                Spacer()
//                                Text("COMING SOON")
//                                    .font(.system(size: 14, weight: .regular))
//                                    .foregroundColor(Color.white40)
//                            }
//                            Divider()
//                            HStack {
//                                Image.photoCircle
//                                Text("Browse Shop")
//                                    .font(.system(size: 17, weight: .regular))
//                                    .foregroundColor(Color.white)
//                                Spacer()
//                                Text("COMING SOON")
//                                    .font(.system(size: 14, weight: .regular))
//                                    .foregroundColor(Color.white40)
//                            }
//                        }
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 15)
//                        .background(Color.walletDetailBottomBtn.cornerRadius(10))
//                        .padding(.horizontal, 16)
//                        // swiftlint:disable line_length
//                        Text("Express yourself. Now with Timeless, you can easily mint your own Profile Picture NFTs (PFPs) with a single tap of a menu and participate in a contactless cyber fashion.")
//                            .font(.system(size: 12, weight: .regular))
//                            .foregroundColor(Color.white40.opacity(0.6))
//                            .padding(.horizontal, 23)
//                    }
//                }
//            }
        }
    }
}

extension ProfilePictureNFTsModal {
    private func onClose() { dismiss() }

    private func onSelected(_ item: String) {
        Wallet.updateWallet(wallet: wallet, avatar: item)
        // Refresh data wallet avatar view
        if let currentWallet = Wallet.currentWallet {
            WalletInfo.shared.currentWallet = currentWallet
        }
        updateAvatarWalletCancelable?.cancel()
        updateAvatarWalletCancelable = IdentityService.shared.updateWalletAvatar(address: wallet.address,
                                                   avatar: item)
            .sink(receiveValue: { _ in })
        Backup.shared.sync(newBackup: false) { _ in }
    }
}
