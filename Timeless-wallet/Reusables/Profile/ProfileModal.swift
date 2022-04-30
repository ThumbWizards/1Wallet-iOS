//
//  ProfileModal.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 12/7/21.
//

import SwiftUI
import LinkPresentation
import CollectionViewPagingLayout
import SwiftUIX

struct ProfileModal {
    var wallet: Wallet
    private var qrCodeCGImage: [String: CGImage] {
        walletInfo.qrCodeCGImage
    }
    @State private var isShowingActionSheet = false
    @State private var activeWallet: CarouselItem.ID! = 0
    @State private var screenBrightness: CGFloat = 1
    @State private var firstAppear = true
    @ObservedObject private var walletInfo = WalletInfo.shared
    @ObservedObject private var viewModel = ViewModel.shared
    var onDismiss: ((Bool) -> Void)?
    private var carouselWallets: [CarouselItem] {
        return walletInfo.carouselWallets
    }
    var options: ScaleTransformViewOptions {
        return ScaleTransformViewOptions(
            minScale: 0.9,
            maxScale: 1,
            translationRatio: CGPoint(x: 0.9, y: 0.9),
            maxTranslationRatio: CGPoint(x: 2, y: 0),
            scaleCurve: .linear,
            translationCurve: .linear
        )
      }
}

extension ProfileModal: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            Color.black.height(UIScreen.main.bounds.height)
        }
        .overlay(
            VStack(spacing: 0) {
                headerView
                ScalePageView(walletInfo.carouselWallets, selection: $activeWallet) { item in
                    VStack(spacing: 0) {
                        menuView(item.wallet).zIndex(1)
                        WalletAvatar(wallet: item.wallet, frame: CGSize(width: 116, height: 116))
                            .padding(.bottom, UIView.hasNotch ? 50 : 30)
                        infoView
                            .padding(.bottom, UIView.hasNotch ? 25 : 5)
                        qrCodeView(item.wallet)
                            .padding(.bottom, UIView.hasNotch ? 54 : 25)
                        Button(action: {
                            onShare(item.wallet)
                        }) {
                            ZStack {
                                Color.myQRShareBtn
                                HStack(spacing: 9) {
                                    Image.shareImageIcon
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundColor(Color.white)
                                        .font(.system(size: 17, weight: .semibold))
                                        .frame(width: 18, height: 19)
                                    Text("Share")
                                        .foregroundColor(Color.white)
                                        .font(.system(size: 17, weight: .semibold))
                                }
                            }
                        }
                        .frame(width: 195, height: 49)
                        .cornerRadius(10)
                        .padding(.bottom, 31)
                        .disabled(qrCodeCGImage[item.wallet.address] == nil)
                        .opacity(qrCodeCGImage[item.wallet.address] == nil ? 0.3 : 1)
                        Text("use it to share contact or receive money")
                            .tracking(-0.7)
                            .font(.system(size: 16))
                            .foregroundColor(Color.white)
                            .opacity(0.4)
                            .padding(.bottom, 15)
                    }
                    .width(UIScreen.main.bounds.width - 50)
                    .background(Color.searchBackground)
                    .cornerRadius(12)
                    .padding(.bottom, 8)
                }
                .options(options)
                .pagePadding(
                    horizontal: .absolute(20)
                )
                .id("\(qrCodeCGImage.count)")
                .frame(height: UIScreen.main.bounds.height * 0.8)
                if carouselWallets.count > 1 {
                    HStack {
                        Spacer()
                        ForEach(carouselWallets.indices, id: \.self) { index in
                            Rectangle()
                                .frame(width: activeWallet == index ? 18 : 6, height: 6)
                                .cornerRadius(.infinity)
                                .foregroundColor(activeWallet == index ? Color.carouselRectangle : Color.carouselCircle)
                                .animation(.easeInOut(duration: 0.2), value: activeWallet)
                        }
                        Spacer()
                    }
                }
            }
        )
        .modifier(EditAvatarModifier(
            isShowingActionSheet: $isShowingActionSheet,
            wallet: wallet,
            centerWalletQR: activeWallet < carouselWallets.count ? carouselWallets[activeWallet].wallet : wallet,
            isQRScreen: true,
            setDefaultBrightness: setDefaultBrightness
        ))
        .disabled(viewModel.loadingUploadCloudinary)
        .overlay(
            BlurEffectView(style: .systemUltraThinMaterial)
                .overlay(
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(viewModel.loadingUploadCloudinary ? 1.5 : 0.1)
                )
                .opacity(viewModel.loadingUploadCloudinary ? 1 : 0)
                .edgesIgnoringSafeArea(.all)
        )
        .onReceive(NotificationCenter.default.publisher(for: UIScreen.brightnessDidChangeNotification)) { _ in
            screenBrightness = UIScreen.main.brightness
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            UIScreen.main.brightness = 1
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            screenBrightness = UIScreen.main.brightness
            UIScreen.main.brightness = 1
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            setDefaultBrightness()
        }
        .onAppear {
            screenBrightness = UIScreen.main.brightness
            UIScreen.main.brightness = 1
            if firstAppear {
                firstAppear = false
                let activeWallet = carouselWallets.firstIndex(where: {
                    $0.wallet.address == wallet.address
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.activeWallet = activeWallet
                }
            }
        }
        .onDisappear {
            setDefaultBrightness()
        }
        .ignoresSafeArea()
        .hideNavigationBar()
    }
}

extension ProfileModal {
    private var headerView: some View {
        HStack {
            Button(action: { onTapClose() }) {
                Image.closeBackup
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 30)
            }
            .padding(.leading, 24)
            .offset(y: 2)
            Spacer()
        }
        .padding(.bottom, 12)
    }

    private var infoView: some View {
        VStack(spacing: 0) {
            Text(carouselWallets[activeWallet].wallet.nameFullAlias)
                .lineLimit(1)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.8))
                .padding(.horizontal, 25)
            Button(action: { copyWalletAddress() }) {
                WalletAddressView(address: carouselWallets[activeWallet].wallet.address, trimCount: 10)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.8))
                    .padding(.horizontal, 25)
                    .padding(.vertical, 8)
                    .background(Color.almostClear)
            }
        }
    }

    private func qrCodeView(_ wallet: Wallet) -> some View {
        ZStack {
            if let qrCodeCGImage = qrCodeCGImage[wallet.address] {
                Image(cgImage: qrCodeCGImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .padding(4)
            }
        }
        .frame(width: 160, height: 160)
        .background(qrCodeCGImage[wallet.address] == nil ? Color.primaryBackground.opacity(0.3) : Color.white)
        .cornerRadius(10)
        .onTapGesture { copyWalletAddress() }
        .loadingOverlay(isShowing: qrCodeCGImage[wallet.address] == nil)
    }

    private func menuView(_ wallet: Wallet) -> some View {
        Menu {
            Button {
                isShowingActionSheet = true
            } label: {
                HStack {
                    Text("Edit Avatar")
                    Image.personCropCircle
                }
            }

// Todo
//            Button {
//
//            } label: {
//                HStack {
//                    Text("Create HNS")
//                    Image.atBadgePlus
//                }
//            }

            Button {
                onShare(wallet)
            } label: {
                HStack {
                    Text("Share")
                    Image.squareAndArrowUp
                }
            }

        } label: {
            HStack {
                Spacer()
                Image.ellipsisCircle
                    .resizable()
                    .frame(width: 30, height: 30)
            }
            .padding(.top, 16)
            .padding(.trailing, 10)
        }
    }
}

extension ProfileModal {
    private func onTapClose() {
        dismiss()
    }

    private func setDefaultBrightness() {
        UIScreen.main.brightness = screenBrightness
    }

    private func copyWalletAddress() {
        UIPasteboard.general.string = wallet.address.convertToWalletAddress()
        showSnackBar(.coppied)
    }

    // This func is for share the QR Image and the Wallet Address
    private func onShare(_ wallet: Wallet) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let view = UIHostingController(rootView: SharedQRImageView(qrCodeCGImage: qrCodeCGImage[wallet.address]!,
                                                                       wallet: wallet)).view
            UIApplication.shared.keyWindowInConnectedScenes?.addSubview(view!)
            view?.frame = CGRect(origin: CGPoint(x: 0, y: 200), size: CGSize(width: 326, height: 447))
            UIApplication.shared.keyWindowInConnectedScenes?.layoutSubviews()
            view?.backgroundColor = .clear
            let uiimage = view?.asImage(rect: CGRect(origin: .zero, size: CGSize(width: 326, height: 447)))
            view?.removeFromSuperview()

            let walletString = "\(wallet.address.convertToWalletAddress())"
            let activityViewController = UIActivityViewController(
                activityItems: [uiimage ?? .init(), MyActivityItemSource(title: "My wallet", text: walletString)],
                applicationActivities: nil
            )
            activityViewController.completionWithItemsHandler = {(
                activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                if !completed {
                    // User canceled
                    return
                }
            }
            present(activityViewController)
        }
    }
}

class MyActivityItemSource: NSObject, UIActivityItemSource {
    var title: String
    var text: String

    init(title: String, text: String) {
        self.title = title
        self.text = text
        super.init()
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return text
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return text
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return title
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        if let releaseAppIcon = UIImage.releaseAppIcon {
            metadata.iconProvider = NSItemProvider(object: (UIImage.appIcon ?? releaseAppIcon))
        }
        //https://stackoverflow.com/questions/60563773/ios-13-share-sheet-changing-subtitle-item-description
        // You may need to escape some special characters like "/".
        if !text.isEmpty {
            metadata.originalURL = URL(fileURLWithPath: text)
        }
        return metadata
    }
}
