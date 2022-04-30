//
//  WalletMultiSigView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 28/01/2022.
//

import SwiftUI
import web3swift

struct WalletMultiSigView {
    // MARK: - Input Parameters
    @ObservedObject var viewModel: ViewModel

    // MARK: - Properties
    @AppStorage(ASSettings.WalletDetail.multiSigFilterType.key)
    private var multiSigFilterType: Int = ASSettings.WalletDetail.multiSigFilterType.defaultValue
    @State private var renderUI = false
}

// MARK: - BodyVuew
extension WalletMultiSigView: View {
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if viewModel.queuedData.isEmpty {
                    if !viewModel.isLoading {
                        emptyView
                        daoCreationButton
                    }
                } else {
                    filterView
                    if MultiSigFilterType.selectedFilterType.key == 0 {
                        MultiSigQueuedView(data: viewModel.queuedData, viewModel: viewModel)
                            .id(viewModel.refreshId)
                    } else {
                        MultiSigHistoryView(data: [])
                    }
                }
            }
        }
        .onAppear(perform: {
            viewModel.getTransaction()
        })
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            renderUI.toggle()
        }
        .loadingOverlay(isShowing: viewModel.isLoading)
        .padding(.top, 30)
    }
}

// MARK: - Subview
extension WalletMultiSigView {
    private var emptyView: some View {
        VStack(spacing: 0) {
            Text("No multisig wallet for which\nyou’re an approved signatory")
                .tracking(0.7)
                .multilineTextAlignment(.center)
                .font(.system(size: 18))
                .foregroundColor(Color.exchangeCurrency)
                .padding(.bottom, UIView.hasNotch ? 42 : 12)
            if renderUI {
                loadingMultisig
            } else {
                loadingMultisig
            }
        }
        .padding(.top, 27)
    }

    private var loadingMultisig: some View {
        LottieView(name: "nftsLottie", loopMode: .constant(.loop), isAnimating: .constant(true))
            .scaledToFill()
            .aspectRatio(255 / 236, contentMode: .fit)
            .padding(.horizontal, 72)
            .padding(.bottom, UIView.hasNotch ? 79 : 59)
            .offset(x: -2)
    }

    private var daoCreationButton: some View {
        Button(action: {
            showSnackBar(.errorMsg(text: "Not available on alpha release"))
// Todo
//            dismiss()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                showConfirmation(.daoTemplates)
//            }
        }) {
            Rectangle()
                .foregroundColor(Color.walletDetailBottomBtn)
                .frame(height: 70)
                .overlay(
                    HStack(spacing: 0) {
                        WalletAvatar(wallet: viewModel.wallet, frame: CGSize(width: 40, height: 40))
                            .padding(.trailing, 10)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("DAO Creation")
                                .font(.system(size: 17))
                                .foregroundColor(Color.white)
                            Text("Try!")
                                .font(.system(size: 15))
                                .foregroundColor(Color.walletDetailDeposit)
                        }
                        Spacer(minLength: 0)
                        Image.chevronRight
                            .resizable()
                            .frame(width: 9, height: 16)
                            .foregroundColor(Color.walletDetailChevronRight)
                            .padding(.trailing, 14)
                    }
                    .padding(.leading, 12), alignment: .leading
                )
                .cornerRadius(12)
        }
        .padding(.horizontal, 22)
    }

    private var filterView: some View {
        HStack(spacing: 19) {
            FilterButtonView(
                keyForCaching: ASSettings.WalletDetail.multiSigFilterType.key,
                filterList: MultiSigFilterType.filterList,
                selectedFilter: MultiSigFilterType.selectedFilterType
            )
            .id(multiSigFilterType)
            if MultiSigFilterType.selectedFilterType.key == 0 {
                Text("\(viewModel.awaitingAmount) awaiting confirmation")
                    .tracking(-0.6)
                    .font(.system(size: 14))
                    .foregroundColor(Color.white.opacity(0.4))
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.leading, 11)
        .padding(.bottom, 15)
    }
}
