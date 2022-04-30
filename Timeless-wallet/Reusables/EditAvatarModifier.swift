//
//  EditAvatarModifier.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 02/03/2022.
//

import SwiftUI
import Combine

struct EditAvatarModifier: ViewModifier {
    // MARK: - Input Parameters
    @Binding private var isShowingActionSheet: Bool
    private var wallet: Wallet
    private var centerWalletQR: Wallet?
    private var isQRScreen: Bool
    private var setDefaultBrightness: (() -> Void)?

    // MARK: - Properties
    @ObservedObject private var profileViewModel = ProfileModal.ViewModel.shared
    @ObservedObject private var tabbarViewModel = TabBarView.ViewModel.shared
    @ObservedObject private var walletSelectorViewModel = WalletSelectorView.ViewModel.shared
    @State private var showImagePicker = false
    @State private var profileImage: Image?
    @State private var selectedUIImage: UIImage?
    @State private var sourceType = UIImagePickerController.SourceType.photoLibrary
    @State private var updateAvatarWalletCancelable: AnyCancellable?

    init(
        isShowingActionSheet: Binding<Bool>,
        wallet: Wallet,
        centerWalletQR: Wallet? = nil,
        isQRScreen: Bool,
        setDefaultBrightness: (() -> Void)? = nil
    ) {
        self._isShowingActionSheet = isShowingActionSheet
        self.wallet = wallet
        self.centerWalletQR = centerWalletQR
        self.isQRScreen = isQRScreen
        self.setDefaultBrightness = setDefaultBrightness
    }

    func body(content: Content) -> some View {
        content
            .actionSheet(isPresented: $isShowingActionSheet) {
                ActionSheet(title: Text("Assign Avatar"), buttons: [
                    .default(Text("Profile Picture NFTs"), action: {
                        if isQRScreen { setDefaultBrightness?() }
                        present(ProfilePictureNFTsModal(
                            wallet: isQRScreen ? (centerWalletQR ?? Wallet(address: wallet.address)) : wallet
                        ) { image in
                            uploadToCloudinary(image)
                        }.onDisappear {
                            if isQRScreen { UIScreen.main.brightness = 1 }
                        }, presentationStyle: .fullScreen)
                    }),
                    .default(Text("Timeless Identicon"), action: {
                        if isQRScreen { setDefaultBrightness?() }
                        present(ProfileListModal(
                            isFullScreen: !isQRScreen,
                            wallet: isQRScreen ? (centerWalletQR ?? Wallet(address: wallet.address)) : wallet
                        ).onDisappear {
                            if isQRScreen { UIScreen.main.brightness = 1 }
                        }, presentationStyle: isQRScreen ? nil : .fullScreen)
                    }),
                    .default(Text("Pick from Library"), action: {
                        if isQRScreen { setDefaultBrightness?() }
                        sourceType = .photoLibrary
                        showImagePicker = true
                    }),
                    .default(Text("Take a photo"), action: {
                        if isQRScreen { setDefaultBrightness?() }
                        sourceType = .camera
                        showImagePicker = true
                    }),
                    .cancel()
                ])
            }
            .fullScreenCover(isPresented: $showImagePicker) {
                ImagePicker(
                    isVisible: $showImagePicker,
                    image: $profileImage,
                    uiImg: $selectedUIImage,
                    sourceType: sourceType
                )
                .ignoresSafeArea()
                .onDisappear {
                    if isQRScreen {
                        UIScreen.main.brightness = 1
                    }
                }
            }
            .onChange(of: selectedUIImage) { image in
                uploadToCloudinary(image)
            }
    }

    private func uploadToCloudinary(_ image: UIImage?) {
        guard let profileImage = image else { return }
        withAnimation(.easeInOut(duration: 0.4)) {
            if isQRScreen {
                profileViewModel.loadingUploadCloudinary = true
            } else {
                tabbarViewModel.changeAvatarTransition = true
            }
        }
        CloudinaryService.shared.uploadImage(image: profileImage) { imageUrl, error in
            guard error == nil, let imageUrl = imageUrl else {
                showSnackBar(.error(error))
                withAnimation(.easeInOut(duration: 0.4)) {
                    if isQRScreen {
                        profileViewModel.loadingUploadCloudinary = false
                    } else {
                        tabbarViewModel.changeAvatarTransition = false
                    }
                }
                return
            }
            updateAvatarWalletCancelable?.cancel()
            updateAvatarWalletCancelable = IdentityService.shared.updateWalletAvatar(address: wallet.address,
                                                       avatar: imageUrl)
                .sink(receiveValue: { _ in
                    let isSubWallet = !isQRScreen && wallet != Wallet.currentWallet
                    Wallet.updateWallet(wallet: isQRScreen ? centerWalletQR : wallet, avatar: imageUrl)
                    // Refresh data wallet avatar view
                    if let currentWallet = Wallet.currentWallet {
                        WalletInfo.shared.currentWallet = currentWallet
                    }
                    Backup.shared.sync(newBackup: false) { _ in }
                    if isSubWallet { walletSelectorViewModel.refreshSubAvatar.toggle() }
                    DispatchQueue.main.asyncAfter(deadline: .now() + (isQRScreen ? 0.2 : 0.3)) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            if isQRScreen {
                                profileViewModel.loadingUploadCloudinary = false
                            } else {
                                tabbarViewModel.changeAvatarTransition = false
                            }
                        }
                    }
                })
        }
    }
}
