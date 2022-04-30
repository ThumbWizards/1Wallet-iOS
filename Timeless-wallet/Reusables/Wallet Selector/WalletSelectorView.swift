//
//  WalletSelectorView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 13/01/22.
//

import SwiftUI
import CollectionViewPagingLayout

struct WalletSelectorView {
    // MARK: - Variables
    @ObservedObject private var tabbarViewModel = TabBarView.ViewModel.shared
    @ObservedObject private var walletInfo = WalletInfo.shared
    @ObservedObject private var viewModel = ViewModel.shared
    @State private var pageState: PageState = .none
    @State private var forceRefresh = false
    let generator = UINotificationFeedbackGenerator()

    enum PageState {
        case previous
        case next
        case none
    }
}

extension WalletSelectorView: View {
    var body: some View {
        ZStack {
            if walletInfo.activeWalletIndex != -1 {
                if forceRefresh {
                    avatarView
                } else {
                    avatarView
                }
            }
        }
        .frame(width: 50, height: 50)
        .overlay(forceRefresh ? EmptyView() : EmptyView())
        .gesture(DragGesture(minimumDistance: 0.5)
                    .onEnded({ value in
            guard Wallet.allWallets.count > 1,
                  !walletInfo.isShowingAnimation,
                  value.translation.height != 0 else { return }
            if value.translation.height < 0 {
                pageState = .next
            } else if value.translation.height > 0 {
                pageState = .previous
            }
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
        }))
        .onTapGesture(perform: {
            generator.notificationOccurred(.success)
            showConfirmation(.avatar())
        })
        .onReceive(walletInfo.$didChangedCurrentWallet, perform: { _ in
            walletInfo.activeWalletIndex = walletInfo.carouselWallets.firstIndex(where: { $0.wallet == walletInfo.currentWallet }) ?? 0
            forceRefresh.toggle()
        })
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                walletInfo.currentWallet = walletInfo.currentWallet
            }
            walletInfo.activeWalletIndex = walletInfo.carouselWallets.firstIndex(where: { $0.wallet == walletInfo.currentWallet  }) ?? 0
            forceRefresh.toggle()
        }
        .onChange(of: viewModel.refreshSubAvatar) { _ in
            forceRefresh.toggle()
        }
        .opacity(tabbarViewModel.changeAvatarTransition ? 0 : 1)
    }
}

extension WalletSelectorView {
    private func changeActiveWalletIndex( _ state: PageState, index: Int) {
        if state == .next {
            if index == walletInfo.carouselWallets.count - 1 {
                walletInfo.activeWalletIndex = 0
            } else {
                walletInfo.activeWalletIndex += 1
            }
        } else if state == .previous {
            if index == 0 {
                walletInfo.activeWalletIndex = walletInfo.carouselWallets.count - 1
            } else {
                walletInfo.activeWalletIndex -= 1
            }
        }
        pageState = .none
    }

    private var avatarView: some View {
        InfiniteScrollView(content: walletInfo.carouselWallets.map { WalletAvatar(wallet: $0.wallet,
                                                                                  frame: CGSize(width: 40, height: 40)) },
                           activeIndex: walletInfo.activeWalletIndex,
                           pageState: $pageState
        ) { state, index in
            changeActiveWalletIndex(state, index: index)
        }
        .frame(width: 50, height: 50)
    }
}

extension WalletSelectorView {
    class ViewModel: ObservableObject {
        // MARK: - Variables
        @Published var refreshSubAvatar = false
    }
}

extension WalletSelectorView.ViewModel {
    static let shared = WalletSelectorView.ViewModel()
}
