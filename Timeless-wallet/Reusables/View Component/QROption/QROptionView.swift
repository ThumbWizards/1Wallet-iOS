//
//  QROptionView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 01/02/22.
//

import SwiftUI

struct QROptionView {
    // MARK: - Input Parameters
    @ObservedObject var viewModel: ViewModel

    // MARK: - Properties
    let generator = UINotificationFeedbackGenerator()
}

// MARK: - Body view
extension QROptionView: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 28) {
                headerView
                actionsView
            }
            closeButton
        }
        .frame(height: 390)
    }
}

// MARK: - Subview
extension QROptionView {
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 13) {
                if viewModel.loadingRecipientName {
                    PlaceHolderBalanceView(font: .system(size: 18, weight: .medium),
                                           cornerRadius: 5, placeholderText: "fullAliasName".toCrazyOne() ?? "")
                } else {
                    Text((viewModel.recipientName.isEmpty ? viewModel.address.trimStringByCount(count: 10) :
                            "\(viewModel.recipientName)".toCrazyOne()) ?? "")
                        .tracking(0.5)
                        .font(.system(size: 18, weight: .medium))
                        .lineLimit(1)
                        .foregroundColor(Color.white.opacity(0.87))
                    Button(action: { onTapCopy() }) {
                        Image.docOnDoc
                            .resizable()
                            .frame(width: 15.5, height: 19)
                            .foregroundColor(Color.white.opacity(0.8))
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.trailing, 57)
            Text("wallet address scanned")
                .tracking(-0.2)
                .font(.system(size: 12))
                .foregroundColor(Color.white.opacity(0.6))
                .padding(.leading, 1)
        }
        .padding(.top, 43)
        .padding(.leading, 28)
    }

    private var closeButton: some View {
        Button(action: { onTapClose() }) {
            Image.scannedClose
                .resizable()
                .frame(width: 25, height: 25)
        }
        .padding(.top, 16)
        .padding(.trailing, 31)
    }

    private var actionsView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                ForEach(ViewModel.QROptionItem.allCases, id: \.self) { item in
                    Button(action: { onTapAction(item) }) {
                        HStack(spacing: 6) {
                            ZStack {
                                item.image
                                    .resizable()
                                    .frame(width: item.imageSize.width, height: item.imageSize.height)
                                    .foregroundColor(Color.white.opacity(0.8))
                            }
                            .frame(width: 31)
                            .padding(.leading, 13)
                            .padding(.trailing, 10)
                            .offset(x: item == .chat ? 4 : (item == .send ? -2 : 0))
                            .offset(y: item == .chat ? 0.5 : 1.5)
                            VStack(alignment: .leading, spacing: 0) {
                                Text(item.title)
                                    .tracking(0.5)
                                    .font(.system(size: 18))
                                    .foregroundColor(Color.white)
                                    .opacity(item == .chat && !viewModel.isChatEnable ? 0.4 : 0.87)
                                ZStack {
                                    if item == .chat && !viewModel.isChatEnable {
                                        Text("Only available to Timeless wallet users")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.white.opacity(0.6))
                                            .opacity(0.6)
                                    } else {
                                        Text(item.subtitle)
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.white.opacity(0.6))
                                            .opacity(0.6)
                                    }
                                }
                                .animation(.easeInOut(duration: 0.2), value: viewModel.isChatEnable)
                            }
                            .offset(y: 1.5)
                            Spacer(minLength: 0)
                        }
                        .frame(height: 76)
                    }
                    .disabled(item == .chat && !viewModel.isChatEnable)
                    if item != ViewModel.QROptionItem.allCases.last {
                        Color.qrSeparatorColor.frame(height: 1)
                    }
                }
            }
            .background(Color.scannedWalletBG)
            .cornerRadius(10)
            .padding(.horizontal, 20)
            Spacer()
        }
    }
}

// MARK: - Methods
extension QROptionView {
    private func onTapClose() {
        hideConfirmationSheet()
        generator.notificationOccurred(.success)
    }

    private func onTapCopy() {
        hideConfirmationSheet()
        showSnackBar(.coppiedAddress)
        generator.notificationOccurred(.success)
        UIPasteboard.general.string = viewModel.recipientName.isEmpty ? viewModel.address : viewModel.recipientName.toCrazyOne()
    }

    private func onTapAction(_ item: ViewModel.QROptionItem) {
        onTapClose()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            switch item {
            case .chat: viewModel.showChatController()
            case .contact:
                present(AddContactView(viewModel: .init(address: viewModel.address),
                                       contactViewModel: .init(screenType: .contact)),
                        presentationStyle: .automatic)
            case .send:
                present(SendPaymentView(viewModel: .init(address: .init(viewModel.address)),
                                        recipientName: viewModel.recipientName).hideNavigationBar(),
                        presentationStyle: .automatic)
            }
        }
    }
}
