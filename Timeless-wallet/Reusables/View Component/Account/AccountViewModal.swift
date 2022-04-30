//
//  AccountViewModal.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/2/21.
//

import SwiftUI
import SwiftMessages

struct AccountViewModal {
    @ObservedObject private var viewModel = WalletView.ViewModel.shared
    // MARK: - Input parameters
    var isHideMenu = false

    // MARK: - Properties
    @State private var index = 1
    @ObservedObject private var walletInfo = WalletInfo.shared
    @ObservedObject private var tabbarViewModel = TabBarView.ViewModel.shared
}

// MARK: - Body view
extension AccountViewModal: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                headerView
                listAccount
                bottomButton
            }
            .height(486)
            buttonClose
        }
    }
}

// MARK: - Subview
extension AccountViewModal {
    private var headerView: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Your Account")
                    .tracking(-0.3)
                    .font(.system(size: 20))
                    .foregroundColor(Color.white)
                Text(Wallet.currentWallet?.nameFullAlias ?? "")
                    .font(.system(size: 15))
                    .foregroundColor(Color.white60)
                    .padding(.trailing, 68)
            }
            Spacer()
        }
        .padding(.top, 38)
        .padding(.leading, 26)
        .padding(.bottom, 15)
    }

    private var listAccount: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 9.5) {
                ForEach(walletInfo.allWallets) { wallet in
                    Button(action: {
                        Utils.playHapticEvent()
                        hideConfirmationSheet()
                        if walletInfo.currentWallet != wallet {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                let host = UIHostingController(rootView: ChangingWalletView(wallet: wallet))
                                host.modalPresentationStyle = .overFullScreen
                                host.modalTransitionStyle = .crossDissolve
                                present(host, animated: true)
                                walletInfo.isShowingAnimation = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                    walletInfo.currentWallet = wallet
                                }
                            }
                        }
                    }) {
                        HStack {
                            WalletAvatar(wallet: wallet, frame: CGSize(width: 43, height: 43))
                            VStack(alignment: .leading, spacing: 3) {
                                Text(wallet.nameFullAlias)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.white87)
                                    .lineLimit(1)
                                if wallet.detailViewModel.overviewModel.totalUSDAmount == nil ||
                                    wallet.detailViewModel.overviewModel.totalONEAmount == nil {
                                    PlaceHolderBalanceView(font: .system(size: 12), cornerRadius: 3)
                                } else {
                                    // swiftlint:disable line_length
                                    SwapCurrencyView(
                                        usdStr: viewModel.getStrBeforeDecimal(wallet.detailViewModel.overviewModel.totalUSDAmount),
                                        decimalUSD: viewModel.getStrAfterDecimal(wallet.detailViewModel.overviewModel.totalUSDAmount),
                                        oneStr: viewModel.getStrBeforeDecimal(wallet.detailViewModel.overviewModel.totalONEAmount),
                                        decimalONE: viewModel.getStrAfterDecimal(wallet.detailViewModel.overviewModel.totalONEAmount, isThreeDigit: true),
                                        type1: "$",
                                        type2: "ONE",
                                        isSpacing1: false,
                                        isSpacing2: true,
                                        valueAfterType: true,
                                        font: .system(size: 12),
                                        color: Color.white.opacity(0.6)
                                    )
                                }
                            }
                            Spacer()
                            Image.checkmark
                                .font(.system(size: 12))
                                .foregroundColor(Color.checkMarkAccount)
                                .opacity(walletInfo.currentWallet == wallet ? 1 : 0)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.keyboardAccessoryBG)
                        .cornerRadius(10)
                        .overlay(walletInfo.currentWallet == wallet ?
                                 RoundedRectangle(cornerRadius: 8).stroke(Color.checkMarkAccount,
                                                                          lineWidth: 1)
                                    .eraseToAnyView() :
                                    EmptyView().eraseToAnyView())
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.top, 15)
        }
        .frame(height: 268)
    }

    private var bottomButton: some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.horizontal, 25)
            HStack(alignment: .top, spacing: 0) {
                ForEach(BottomAccountItems.allCases, id: \.self) { item in
                    actionBottom(item)
                }
            }
            .foregroundColor(Color.white60)
        }
    }

    private func actionBottom(_ item: BottomAccountItems) -> some View {
        Button(action: {
            Utils.playHapticEvent()
            onTapClose()
            switch item {
            case .settings:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    present(SettingsView(), presentationStyle: .overFullScreen)
                }
            case .contact:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    present(ContactModalView(viewModel: .init(screenType: .contact)))
                }
            case .qr:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    Utils.scanWallet { strScanned in
                        showConfirmation(.qrOptions(result: strScanned))
                    }
                }
            }
        }) {
            VStack(spacing: 0) {
                ZStack {
                    item.image
                        .resizable()
                        .frame(width: item.imageSize.width, height: item.imageSize.height)
                }
                .frame(height: 22)
                .padding(.bottom, 9)
                Text(item.title)
                    .tracking(0.1)
                    .font(.system(size: 14))
                    .fixedSize(horizontal: true, vertical: false)
                Spacer()
            }
            .padding(.top, 25.5)
            .offset(x: item.offsetX)
            .frame(width: UIScreen.main.bounds.width / CGFloat(BottomAccountItems.allCases.count))
        }
        .opacity(item == .settings ? 1 : (isHideMenu ? 0.3 : 1))
        .disabled(item == .settings ? false : isHideMenu)
    }

    private var buttonClose: some View {
        Button(action: { onTapClose() }) {
            Image.closeSmall
                .resizable()
                .frame(width: 25, height: 25)
        }
        .padding(.top, 36)
        .padding(.trailing, 31)
    }
}

// MARK: - Methods
extension AccountViewModal {
    private func onTapClose() {
        hideConfirmationSheet()
    }
}

enum BottomAccountItems: CaseIterable {
    case settings
    case contact
    case qr

    var title: String {
        switch self {
        case .settings: return "Settings"
        case .contact: return "Contact"
        case .qr: return "QR"
        }
    }

    var image: Image {
        switch self {
        case .settings: return Image.personCropCircle
        case .contact: return Image.personTextRectangle
        case .qr: return Image.qrcodeViewFinder
        }
    }

    var imageSize: CGSize {
        switch self {
        case .settings: return CGSize(width: 24, height: 24)
        case .contact: return CGSize(width: 26, height: 20)
        case .qr: return CGSize(width: 22, height: 22)
        }
    }

    var offsetX: CGFloat {
        switch self {
        case .settings: return 24
        case .contact: return 0
        case .qr: return -24
        }
    }
}
