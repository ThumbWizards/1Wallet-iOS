//
//  MoreActionModal.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/2/21.
//

import SwiftUI
import SwiftMessages

struct MoreActionModal {
    // MARK: - Properties
    @AppStorage(ASSettings.Settings.showCurrencyWallet.key)
    private var showCurrencyWallet = ASSettings.Settings.showCurrencyWallet.defaultValue
    @AppStorage(ASSettings.Settings.walletBalance.key)
    private var walletBalance = ASSettings.Settings.walletBalance.defaultValue
    @ObservedObject private var walletViewModel = WalletView.ViewModel.shared
    var wallet: Wallet
    let generator = UINotificationFeedbackGenerator()

    // MARK: - Computed variables
    private var showPlaceHolder: Bool {
        wallet.detailViewModel.overviewModel.totalUSDAmount == nil
        || wallet.detailViewModel.overviewModel.totalONEAmount == nil
    }
}

// MARK: - Body view
extension MoreActionModal: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                headerView
                actionsView
                Spacer(minLength: 0)
            }
            .padding(.top, 27)
            .height(398)
            closeButton
        }
    }
}

// MARK: - Subview
extension MoreActionModal {
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(wallet.nameFullAlias)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.white)
                    .lineLimit(1)
                if showPlaceHolder {
                    PlaceHolderBalanceView(font: .system(size: 15), cornerRadius: 5)
                } else {
                    // swiftlint:disable line_length
                    SwapCurrencyView(
                        usdStr: walletViewModel.getStrBeforeDecimal(wallet.detailViewModel.overviewModel.totalUSDAmount),
                        decimalUSD: walletViewModel.getStrAfterDecimal(wallet.detailViewModel.overviewModel.totalUSDAmount),
                        oneStr: walletViewModel.getStrBeforeDecimal(wallet.detailViewModel.overviewModel.totalONEAmount),
                        decimalONE: walletViewModel.getStrAfterDecimal(wallet.detailViewModel.overviewModel.totalONEAmount, isThreeDigit: true),
                        type1: "$",
                        type2: "ONE",
                        isSpacing1: false,
                        isSpacing2: true,
                        valueAfterType: true,
                        font: .system(size: 15)
                    )
                }
            }
            Spacer()
        }
        .padding(.leading, 26)
        .padding(.trailing, 59)
        .padding(.bottom, 4)
    }

    private var actionsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(MoreActionItem.allCases, id: \.self) { item in
                action(item)
            }
        }
    }

    private func action(_ item: MoreActionItem) -> some View {
        Button(action: {
            generator.notificationOccurred(.success)
            switch item {
            case .copyAddress:
                hideConfirmationSheet()
                showSnackBar(.coppiedAddress)
                UIPasteboard.general.string = wallet.address.convertToWalletAddress()
            case .showQRCode:
                hideConfirmationSheet()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    present(ProfileModal(wallet: wallet), presentationStyle: .fullScreen)
                }
//            case .renameWallet:
//                hideConfirmationSheet()
//                showSnackBar(.errorMsg(text: "Not available on alpha release"))
            case .disconnectAndRemove:
                hideConfirmationSheet()
                showSnackBar(.errorMsg(text: "Not available on alpha release"))
                // TODO:- Disable for demo
//                hideConfirmationSheet()
//                showConfirmation(.disconnectAndRemove(wallet: wallet))
            }
        }) {
            HStack(spacing: 21.5) {
                ZStack {
                    item.image
                        .resizable()
                        .frame(width: item.imageSize.width, height: item.imageSize.height)
                        .foregroundColor(item == .disconnectAndRemove ? Color.timelessRed : Color.white60)
                }
                .frame(width: 22)
                .offset(x: item.offset.width, y: item.offset.height)
                VStack(alignment: .leading, spacing: 0) {
                    Text(item.title)
                        .tracking(0.5)
                        .font(.system(size: 18))
                        .foregroundColor(item == .disconnectAndRemove ? Color.timelessRed : Color.white87)
                    if !item.subtitle.isEmpty {
                        Group {
                            if item == .copyAddress {
                                WalletAddressView(address: wallet.address)
                            } else {
                                Text(item.subtitle)
                            }
                        }
                            .font(.system(size: 14))
                            .foregroundColor(Color.white60)
                            .opacity(0.6)
                    }
                }
                Spacer(minLength: 5)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 21.5)
            .background(Color.almostClear)
        }
    }

    private var closeButton: some View {
        Button(action: { onTapClose() }) {
            Image.closeBackup
                .resizable()
                .frame(width: 25, height: 25)
                .padding(.vertical, 28)
                .padding(.horizontal, 31)
                .background(Color.almostClear)
        }
    }
}

// MARK: - Methods
extension MoreActionModal {
    private func onTapClose() {
        hideConfirmationSheet()
    }
}

enum MoreActionItem: CaseIterable {
    case copyAddress
    case showQRCode
//    case renameWallet
    case disconnectAndRemove

    var title: String {
        switch self {
        case .copyAddress: return "Copy Address"
        case .showQRCode: return "Show QR code"
//        case .renameWallet: return "Rename wallet"
        case .disconnectAndRemove: return "Disconnect & Remove"
        }
    }

    var subtitle: String {
        switch self {
        case .copyAddress: return (Wallet.currentWallet?.address ?? "").convertToWalletAddress().trimStringByCount(count: 10)
        case .showQRCode: return ""
//        case .renameWallet: return "crazy.one subdomain service"
        case .disconnectAndRemove: return ""
        }
    }

    var image: Image {
        switch self {
        case .copyAddress: return Image.docOnDoc
        case .showQRCode: return Image.qrcode
//        case .renameWallet: return Image.squareAndPencil
        case .disconnectAndRemove: return Image.trashFill
        }
    }

    var imageSize: CGSize {
        switch self {
        case .copyAddress: return CGSize(width: 22, height: 28)
        case .showQRCode: return CGSize(width: 19, height: 19)
//        case .renameWallet: return CGSize(width: 22, height: 22)
        case .disconnectAndRemove: return CGSize(width: 20, height: 22)
        }
    }

    var offset: CGSize {
        switch self {
        case .copyAddress: return CGSize(width: 0, height: -1)
        case .showQRCode: return CGSize(width: -1, height: -1)
//        case .renameWallet: return CGSize(width: 1, height: 0)
        case .disconnectAndRemove: return CGSize(width: 0, height: 0)
        }
    }
}
