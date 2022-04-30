//
//  ExchangeModal.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/18/21.
//

import SwiftUI

struct ExchangeModal {
    // MARK: - Properties
    @AppStorage(ASSettings.Settings.firstDeposit.key)
    private var firstDeposit = ASSettings.Settings.firstDeposit.defaultValue
}

// MARK: - Body view
extension ExchangeModal: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            closeButton
            actionsView
            Spacer()
        }
        .height(390)
    }
}

// MARK: - Subview
extension ExchangeModal {
    private var closeButton: some View {
        HStack {
            Spacer()
            Button(action: { onTapClose() }) {
                Image.closeBackup
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            .padding(.top, 16)
            .padding(.trailing, 31)
            .padding(.bottom, 5)
        }
    }

    private var actionsView: some View {
        VStack(alignment: .leading, spacing: 43.5) {
            ForEach(ExchangeItem.allCases, id: \.self) { item in
                action(item)
            }
        }
    }

    private func action(_ item: ExchangeItem) -> some View {
        Button(action: {
            onTapClose()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                switch item {
                case .buy:
                    present(NavigationView {
                        DepositView(firstDeposit: firstDeposit).hideNavigationBar()
                    }, presentationStyle: .automatic)
                    if firstDeposit {
                        firstDeposit = false
                    }
                case .receive:
                    present(ProfileModal(wallet: WalletInfo.shared.currentWallet), presentationStyle: .fullScreen)
                case .send:
                    showConfirmation(.exchangeWarning)
                case .swap:
                    present(NavigationView { SwapView().hideNavigationBar() }, presentationStyle: .overCurrentContext)
                }
            }
        }) {
            HStack(spacing: 19.5) {
                ZStack {
                    item.image
                        .resizable()
                        .frame(width: item.imageSize.width, height: item.imageSize.height)
                        .foregroundColor(Color.white60)
                }
                .frame(width: 24)
                VStack(alignment: .leading) {
                    Text(item.title)
                        .tracking(0.5)
                        .font(.system(size: 18))
                        .foregroundColor(Color.white87)
                    Text(item.subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(Color.white60)
                        .opacity(0.6)
                }
            }
            .padding(.horizontal, 29)
        }
    }
}

// MARK: - Methods
extension ExchangeModal {
    private func onTapClose() {
        hideConfirmationSheet()
    }
}

enum ExchangeItem: CaseIterable {
    case buy
    case receive
    case send
    case swap

    var title: String {
        switch self {
        case .buy: return "Buy"
        case .receive: return "Receive"
        case .send: return "Send"
        case .swap: return "Swap"
        }
    }

    var subtitle: String {
        switch self {
        case .buy: return "Buy crypto with cash"
        case .receive: return "Deposit tokens to your wallet"
        case .send: return "Transfer tokens to another wallet"
        case .swap: return "Exchange any tokens"
        }
    }

    var image: Image {
        switch self {
        case .buy: return Image.creditcard
        case .receive: return Image.qrcode
        case .send: return Image.paperPlane
        case .swap: return Image.arrowTriangleSwap
        }
    }

    var imageSize: CGSize {
        switch self {
        case .buy: return CGSize(width: 24, height: 17)
        case .receive: return CGSize(width: 19, height: 19)
        case .send: return CGSize(width: 22, height: 22)
        case .swap: return CGSize(width: 20, height: 18)
        }
    }
}
