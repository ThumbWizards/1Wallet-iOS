//
//  DiscoverHorizontalCardView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 3/11/22.
//

import Foundation
import Combine
import SwiftUI

extension DiscoverHorizontalCardView {
    class ViewModel: ObservableObject {
        @Published var childrenItems: [DiscoverItemModel]?
        var item: DiscoverItemModel
        private var currentAPICalls = Set<AnyCancellable>()

        init(item: DiscoverItemModel) {
            self.item = item
        }
    }
}

extension DiscoverHorizontalCardView.ViewModel {
    func getChildrenItems() {
        DiscoverService.shared.getChildrenItems(id: item.id ?? "/", cursor: nil)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                guard let self = self else {
                    return
                }
                switch result {
                case .success(let model):
                    if let items = model.items {
                        withAnimation {
                            self.childrenItems = items
                        }
                    }
                case .failure(let error):
                    showSnackBar(.error(error))
                }
            })
            .store(in: &currentAPICalls)
    }
}
