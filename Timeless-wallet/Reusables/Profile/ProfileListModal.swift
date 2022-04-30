//
//  ProfileListModal.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 12/7/21.
//

import SwiftUI
import Combine
import StreamChat

struct ProfileListModal {
    // MARK: - Input Parameters
    var isFullScreen: Bool
    var wallet: Wallet

    // MARK: - Properties
    static var listAvatar = ["https://res.cloudinary.com/timeless/image/upload/v1/app/Wallet/bowie.jpg",
                             "https://res.cloudinary.com/timeless/image/upload/v1/app/Wallet/bruce.jpg",
                             "https://res.cloudinary.com/timeless/image/upload/v1/app/Wallet/dali.jpg",
                             "https://res.cloudinary.com/timeless/image/upload/v1/app/Wallet/gandhi.jpg",
                             "https://res.cloudinary.com/timeless/image/upload/v1/app/Wallet/marilynmonroe.png"]
    @ObservedObject private var viewModel = TabBarView.ViewModel.shared
    @State private var isShowAll = false
    let columns = Array(repeating: GridItem(.flexible(), spacing: 11.35), count: 3)
    @State private var currentNetworkCalls = Set<AnyCancellable>()
    @State var updateAvatarWalletCancelable: AnyCancellable?
}

extension ProfileListModal: View {
    var body: some View {
        ZStack {
            Color.sheetBG
            VStack(spacing: 0) {
                ZStack {
                    Text("Profile Picture")
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
                }
                .padding(.horizontal, 19)
                .padding(.bottom, 33)
                if !isShowAll {
                    HStack {
                        Text("TIMELESS IDENTICONS")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color.white)
                        Spacer()
                        Button {
                            withAnimation {
                                self.isShowAll = true
                            }
                        } label: {
                            Text("See All")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(Color.timelessRed)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                ScrollView {
                    if !isShowAll {
                        LazyVGrid(columns: columns, spacing: 11) {
                            ForEach(ProfileListModal.listAvatar, id: \.self) { item in
                                ZStack {
                                    Button {
                                        onSelected(item)
                                    } label: {
                                        ZStack(alignment: .topLeading) {
                                            let image = MediaResourceModel(path: item,
                                                                           altText: nil,
                                                                           pathPrefix: nil,
                                                                           mediaType: "jpg",
                                                                           thumbnail: nil)
                                            MediaResourceView(for: MediaResource(for: image,
                                                                                    targetSize: TargetSize(width: 103,
                                                                                                           height: 141)),
                                                                 placeholder: WalletPlaceHolder(cornerRadius: .zero)
                                                                    .eraseToAnyView(),
                                                                 isPlaying: .constant(true))
                                                .scaledToFill()
                                                .frame(width: 103, height: 141)
                                                .cornerRadius(12)
                                            Image.checkmarkCircleFill
                                                .resizable()
                                                .frame(width: 16, height: 16)
                                                .foregroundColor(Color.timelessBlue)
                                                .padding([.top, .leading], 6)
                                                .opacity(parseData(item: item) ? 1 : 0)

                                        }
                                    }
                                }
                                .previewContextMenu(preview: previewContent(item),
                                                    actions: [.info, .blockExplorer, .shop, .flex]) { actionType in
                                    print(actionType)
                                }
                            }
                        }
                        .padding(.top, 44)
                        .padding(.horizontal, 21)
                    } else {
                        LazyVStack(spacing: 15) {
                            ForEach(ProfileListModal.listAvatar, id: \.self) { item in
                                ZStack {
                                    Button {
                                        onSelected(item)
                                    } label: {
                                        ZStack(alignment: .topLeading) {
                                            let image = MediaResourceModel(path: item,
                                                                           altText: nil,
                                                                           pathPrefix: nil,
                                                                           mediaType: "jpg",
                                                                           thumbnail: nil)
                                            let width = UIScreen.main.bounds.width - 68
                                            let height = (UIScreen.main.bounds.width - 68) * 1.3
                                            MediaResourceView(for: MediaResource(for: image,
                                                                                    targetSize: TargetSize(width: Int(width),
                                                                                                           height: Int(height))),
                                                                 placeholder: ProgressView()
                                                                    .progressViewStyle(.circular)
                                                                    .eraseToAnyView(),
                                                                 isPlaying: .constant(true))
                                                .scaledToFill()
                                                .frame(width: width,
                                                       height: height)
                                                .cornerRadius(12)
                                            Image.checkmarkCircleFill
                                                .resizable()
                                                .frame(width: 16, height: 16)
                                                .foregroundColor(Color.timelessBlue)
                                                .padding([.top, .leading], 6)
                                                .opacity(parseData(item: item) ? 1 : 0)
                                        }
                                    }
                                }
                                .previewContextMenu(preview: previewContent(item),
                                                    actions: [.info, .blockExplorer, .shop, .flex]) { actionType in
                                    print(actionType)
                                }
                            }
                        }
                        .padding(.bottom, UIView.safeAreaBottom)
                    }
                }
                if !isShowAll {
                    VStack(spacing: 24) {
                        Text("Interested in using NFT as avatar?")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color.white)
                        Button {

                        } label: {
                            Text("Connect my wallet")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(Color.white87)
                                .frame(width: UIScreen.main.bounds.width - 85, height: 41)
                                .background(Color.walletDetailBottomBtn.cornerRadius(20.5))
                        }
                        // swiftlint:disable line_length
                        Text("Express yourself. Now with 1wallet, you can easily mint your own Profile Picture NFTs (PFPs) with a single tap of a menu and participate in a contactless cyber fashion.")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color.white40.opacity(0.6))
                            .padding(.horizontal, 23)
                    }
                    .padding(.bottom, UIView.safeAreaBottom + 61)
                    // Todo
                    .disabled(true)
                    .opacity(0.2)
                }
            }
            .padding(.top, isFullScreen ? UIView.safeAreaTop : 15)
        }
        .ignoresSafeArea()
    }
}

extension ProfileListModal {
    private func previewContent(_ name: String) -> some View {
        let image = MediaResourceModel(path: name,
                                       altText: nil,
                                       pathPrefix: nil,
                                       mediaType: "jpg",
                                       thumbnail: nil)
        return ZStack(alignment: .bottom) {
            GeometryReader { proxy in
                MediaResourceView(for: MediaResource(for: image,
                                                        targetSize: TargetSize(width: Int(proxy.size.width),
                                                                               height: Int(proxy.size.height))),
                                     placeholder: ProgressView()
                                        .progressViewStyle(.circular)
                                        .eraseToAnyView(),
                                     isPlaying: .constant(true))
                    .scaledToFill()
                    .frame(width: proxy.size.width,
                           height: proxy.size.height)
            }
            WalletAddressView(address: Wallet.currentWallet?.address ?? "", trimCount: 10)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.white.opacity(0.8))
                .padding(.bottom, 24)
                .padding(.horizontal)
                .minimumScaleFactor(0.5)
        }
    }
}

extension ProfileListModal {
    private func onClose() { dismiss() }

    private func parseData(item: String) -> Bool {
        return URL(string: item)?.absoluteString == wallet.avatarUrl ?? ""
    }

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
        onClose()
    }
}
