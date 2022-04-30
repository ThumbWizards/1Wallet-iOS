//
//  MultisigWalletView.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 31/01/22.
//

import SwiftUI

struct MultisigWalletView {
    // MARK: - Variables
    var walletAddress: String?
    var walletName: String?
    var walletAvatar: String?
    var type: ViewType

    var deleteTapped: (() -> Void)?
    var editTapped: (() -> Void)?
    var walletLinkTapped: (() -> Void)?

    private var walletAvatarUrl: URL? {
        URL(string: walletAvatar ?? "")
    }
    private var trimmedWalletAddress: String {
        (walletAddress?.convertToWalletAddress() ?? "").trimStringByCount(count: 10)
    }
}

extension MultisigWalletView {
    enum ViewType {
        case edit
        case editAndDelete
        case walletLink
    }
}

extension MultisigWalletView: View {
    var body: some View {
        HStack {
            if walletAvatar.verifyUrl() {
                let image = MediaResourceModel(path: walletAvatarUrl?.absoluteString ?? "",
                                               altText: nil,
                                               pathPrefix: nil,
                                               mediaType: nil,
                                               thumbnail: nil)
                MediaResourceView(
                    for: MediaResource(
                        for: image,
                           targetSize: TargetSize(
                            width: 100,
                            height: 100)),
                       placeholder: ProgressView().progressViewStyle(.circular).eraseToAnyView(),
                       isPlaying: .constant(true))
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .cornerRadius(.infinity)
                    .padding(.leading, 20)
                    .padding(.vertical, 16)
            } else {
                if walletAvatar != nil {
                    Image.contactAvatarBear
                        .padding(.leading, 20)
                        .padding(.vertical, 16)
                } else if let systemImage = Image(systemName: walletAvatar ?? "") {
                    systemImage
                        .padding(.leading, 20)
                        .padding(.vertical, 16)
                } else {
                    Image(walletAvatar ?? "")
                        .padding(.leading, 20)
                        .padding(.vertical, 16)
                }
            }
            VStack(alignment: .leading) {
                Text(walletName ?? "-")
                    .lineLimit(2)
                    .font(.sfProText(size: 17))
                    .foregroundColor(.white)
                WalletAddressView(address: walletAddress ?? "", trimCount: 10, tracking: -0.38)
                    .font(.sfProText(size: 15))
                    .foregroundColor(.descriptionNFT.opacity(0.6))
            }
            Spacer()
            HStack {
                switch type {
                case .edit:
                    editButton
                case .editAndDelete:
                    editButton
                    deleteButton
                case .walletLink:
                    linkButton
                }
            }
            .padding(.trailing, 19)
        }
        .background(Color.containerBackground.opacity(0.18))
        .cornerRadius(6)
    }
}

extension MultisigWalletView {
    private var editButton: some View {
        Button(action: {
            editTapped?()
        }) {
            Image.pencilCircle
                .tint(.white)
                .frame(width: 26, height: 26)
        }
    }

    private var deleteButton: some View {
        Button(action: {
            deleteTapped?()
        }) {
            Image.trashFill
                .tint(.descriptionNFT.opacity(0.6))
                .frame(width: 26, height: 26)
        }
    }

    private var linkButton: some View {
        Button(action: {
            walletLinkTapped?()
        }) {
            Text("\(Image.arrowUpRightSquare)")
                .foregroundColor(.descriptionNFT.opacity(0.6))
                .font(.sfProText(size: 15))
        }
    }
}

struct MultisigWalletView_Previews: PreviewProvider {
    static var previews: some View {
        MultisigWalletView(type: .edit)
    }
}
