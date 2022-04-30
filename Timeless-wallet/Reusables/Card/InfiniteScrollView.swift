//
//  InfinityScrollView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 2/25/22.
//

import SwiftUI

struct InfiniteScrollView<Content: View>: UIViewControllerRepresentable {
    var content: [Content]
    var activeIndex: Int
    @Binding var pageState: WalletSelectorView.PageState
    var calledSuccess: ((WalletSelectorView.PageState, Int) -> Void)?

    func makeUIViewController(context: Context) -> CardsViewController {
        let viewController = CardsViewController()
        viewController.configureViews(contentView: content.map { $0.eraseToAnyView() },
                                      activeIndex: activeIndex)
        viewController.calledSuccess = calledSuccess
        return viewController
    }

    func updateUIViewController(_ uiViewController: CardsViewController, context: Context) {
        if context.coordinator.pageState.wrappedValue != $pageState.wrappedValue {
            context.coordinator.pageState = $pageState
            if context.coordinator.pageState.wrappedValue != .none {
                uiViewController.changingPageState(state: context.coordinator.pageState.wrappedValue)
            }
        }
    }

    func makeCoordinator() -> InfiniteScrollView.Coodinator {
        return Coordinator(pageState: $pageState)
    }

    final class Coodinator: NSObject {
        var pageState: Binding<WalletSelectorView.PageState>

        init(pageState: Binding<WalletSelectorView.PageState>) {
            self.pageState = pageState
        }
    }
}
