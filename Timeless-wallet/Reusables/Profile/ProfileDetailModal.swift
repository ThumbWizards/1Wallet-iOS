//
//  ProfileDetailModal.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 12/7/21.
//

import SwiftUI

struct ProfileDetailModal {
    var wallet: Wallet
    var connectWallet: Bool
}

extension ProfileDetailModal: View {
    var body: some View {
        ZStack {
            Color.sheetBG
            VStack(spacing: 0) {
                ZStack {
                    Text(connectWallet ? "Profile Picture NFTs" : "Connect my wallet")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.white)
                    Button {
                        onClose()
                    } label: {
                        HStack {
                            Image.closeBackup
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 30)
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 19)
                if connectWallet {
                    connectView
                } else {
                    noConnectView
                }
            }
            .padding(.top, 15)
        }
        .ignoresSafeArea()
    }
}

extension ProfileDetailModal {
    private var connectView: some View {
        Group {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    // swiftlint:disable line_length
                    Text("""
                        Crypto communities have become an expressive place where users depict themselves in various avatars through their profile pictures. Chances are, you’ve seen these pixelated punks, bored apes, and adorable felines floating in the Twitterverse, which will soon be verified. This is no longer a fad for the crypto-natives. PFPs are going mainstream with celebrities like Jay-Z and Snoop Dogg buying and choosing Cryptopunks as their profile pictures on Twitter, payments company Visa adding a Punk to their collection, and society continuing to embrace this cultural bull market.

                        What started as a quirky art project has mushroomed into an entire crypto art movement. CryptoPunks are an internet artifact that inspired the ERC-721 standard which powers digital art and collectibles today. There are 10,000 unique CryptoPunks, with each boasting randomly generated attributes. These pixelated characters are a mix of guys and girls, rare zombies, apes, and aliens.¹
                        """)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.white87)
                        .lineSpacing(4)
                        .padding(.horizontal, 20)
                    Text("Now with Timeless, you can easily mint your own Profile Picture NFTs (PFPs) with a single tap of a menu and participate in a contactless cyber fashion.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.white87)
                        .lineSpacing(4)
                        .padding(.horizontal, 19)
                }
                .padding(.top, 30)

            }
            VStack(alignment: .leading) {
                Divider()
                Text("1. Source: Consensys")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.white40)
            }
            .opacity(0.6)
            .padding(.bottom, UIView.safeAreaBottom + 16)
            .padding(.horizontal, 24)
        }
    }

    private var noConnectView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                HStack {
                    Text("Example")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.white60)
                    Spacer()
                }
                VStack {
                    Image.connectImage
                        .resizable()
                        .frame(width: 63, height: 63)
                    Button {
                        if let url = URL(string: "https://opensea.io/assets/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d/9080") {
                            present(WebView(url: url)
                                        .ignoresSafeArea()
                            )
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(wallet.address.convertToWalletAddress().trimStringByFirstLastCount(firstCount: 8, lastCount: 6))
                                .foregroundColor(Color.white)
                                .font(.system(size: 17, weight: .regular))
                            Image.arrowUpRightSquare
                                .foregroundColor(Color.white60)
                                .font(.system(size: 17, weight: .regular))
                        }
                    }
                }
                .padding(.bottom, 35)
                HStack {
                    Text("IMPORTANT NOTE")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.white60)
                    Spacer()
                }
                .padding(.bottom, 10)
                Text("""
                    We’re adding NFTs as one of several ways to customize your 1wallet profile so you can showcase the NFTs you own cross-chain all while you maintain full custody of the asset.

                    This exploratory feature aims to enable Ethereum NFT owners who are also 1wallet users on Harmony to 1) verify the ownership of their Ethereum NFT and 2) use them as an avatar for their 1wallet. The attestation smart contract will store the NFT ownership and verification information on-chain (on Harmony) for anyone to query.

                    The feature is a first important step to enable cross-chain NFT capability on Harmony, namely to make use of NFT that is already minted and owned by the same user on another chain.

                    A couple of things to be aware of when connecting a crypto wallet to your 1wallet account:

                    1wallet will NEVER request funds from your crypto wallet. You should remain vigilant, and check all incoming requests to your wallet. Don’t accept any transfer requests unless it is a known transaction.

                    1wallet will NEVER request your private key or seed phrase, and you should never share your private keys or seed phrases anywhere, including on 1wallet.

                    Although we won’t maintain an ongoing connection with your crypto wallet, we store your public address to check for continued ownership of the NFT you set as your profile avatar.
                    """)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.white60)
            }
            .padding(.top, 32)
            .padding(.leading, 23)
            .padding(.trailing, 28)
            .padding(.bottom, UIView.safeAreaBottom + 10)
        }
    }
}

extension ProfileDetailModal {
    private func onClose() { dismiss() }
}
