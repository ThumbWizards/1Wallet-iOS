//
//  Discover+ViewModel.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 08/12/21.
//

import Foundation
import Combine
import SwiftUI

extension DiscoverView {
    class ViewModel: ObservableObject {
        // MARK: - Variables
        @Published var loadingState: LoadingState = .initing
        @Published var discoverItem: DiscoverItemModel?
        private var currentAPICalls = Set<AnyCancellable>()

        var isHasNextPage: Bool {
            discoverItem?.children?.cursor?.isEmpty == false
        }

        var isShowSurveyView: Bool {
            if loadingState != .initing,
               !isHasNextPage {
                return true
            }
            return false
        }

        enum LoadingState: Equatable {
            case initing
            case refreshing
            case paging
            case done
            case error(API.APIError)
        }
    }
}

extension DiscoverView.ViewModel {
    func getDiscoverItems(isFetchNextPage: Bool = false, callback: (() -> Void)? = nil) {
        if loadingState == .paging && isFetchNextPage {
            return
        }
        if loadingState != .initing {
            withAnimation {
                loadingState = isFetchNextPage ? .paging : .refreshing
            }
        }
        DiscoverService.shared.getDiscoverItems(cursor: isFetchNextPage ? discoverItem?.children?.cursor : nil)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                guard let self = self else {
                    return
                }
                callback?()
                switch result {
                case .success(let model):
                    switch self.loadingState {
                    case .initing, .refreshing:
                        withAnimation {
                            self.loadingState = .done
                            self.discoverItem = model
                        }
                    case .paging:
                        var currentDiscoverItem = model
                        currentDiscoverItem.children?.items = self.discoverItem?.children?.items
                        currentDiscoverItem.children?.items?.append(contentsOf: model.children?.items ?? [])
                        withAnimation {
                            self.loadingState = .done
                            self.discoverItem = currentDiscoverItem
                        }
                    default: break
                    }
                case .failure(let error):
                    withAnimation {
                        self.loadingState = .error(.requestError)
                    }
                    showSnackBar(.error(error))
                }
            })
            .store(in: &currentAPICalls)
    }
}

extension DiscoverView.ViewModel {
    static let shared = DiscoverView.ViewModel()
}
