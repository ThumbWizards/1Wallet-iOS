//
//  WalletTrxnView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 1/18/22.
//

import Foundation
import Combine
import SwiftUI

extension WalletTrxnView {
    class ViewModel: ObservableObject {
        @Published var loadingState: LoadingState = .initing
        @Published var transactionGrouped: [[TransactionInfo]]?
        @Published var transactionList: [TransactionInfo]?
        @Published var searchingText: String = ""
        @Published var searchedResults: [[TransactionInfo]]?
        private var nextPage: Int?
        private(set) var searchingCancellable: AnyCancellable?
        private(set) var cancellables = Set<AnyCancellable>()

        var wallet: Wallet

        init(wallet: Wallet) {
            self.wallet = wallet
            searchingCancellable = AnyCancellable(
                $searchingText
                    .debounce(for: 0.3, scheduler: DispatchQueue.global())
                    .removeDuplicates()
                    .sink { text in self.search(for: text) }
            )
        }

        var isHasNextPage: Bool {
            nextPage != nil
        }

        enum LoadingState {
            case initing
            case refreshing
            case paging
            case done
        }
    }
}

extension WalletTrxnView.ViewModel {
    func getTransactionHistory(isFetchNextPage: Bool = false) {
        guard let walletData = OneWalletService.shared.getUserWalletData(for: wallet) else { return }
        if loadingState == .paging && isFetchNextPage {
            return
        }
        if loadingState != .initing {
            DispatchQueue.main.async {
                withAnimation {
                    self.loadingState = isFetchNextPage ? .paging : .refreshing
                }
            }
        }
        OneWalletService.shared.transactionHistory(address: walletData.address,
                                                   page:  isFetchNextPage ? nextPage ?? 0 : 0)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                guard let weakSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    withAnimation {
                        weakSelf.loadingState = .done
                    }
                }
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    showSnackBar(.error(error))
                    weakSelf.transactionGrouped = []
                }
            } receiveValue: { [weak self] res in
                guard let weakSelf = self else {
                    return
                }
                withAnimation {
                    weakSelf.transactionGrouped = weakSelf.groupedTransactions(res.transactions)
                }
                weakSelf.nextPage = res.nextPage
            }
            .store(in: &cancellables)
    }

    func groupedTransactions(_ trans: [TransactionInfo]) -> [[TransactionInfo]] {
        var today = [TransactionInfo]()
        var week = [TransactionInfo]()
        var month = [TransactionInfo]()
        var lastMonth = [TransactionInfo]()
        var groupingList = trans
        for data in groupingList {
            if data.time.isDateInToday() {
                today.append(data)
                groupingList.removeFirst()
            } else if data.time.isDateInWeek() {
                week.append(data)
                groupingList.removeFirst()
            } else if data.time.isDateInMonth() {
                month.append(data)
                groupingList.removeFirst()
            } else if data.time.isDateInLastMonth() {
                lastMonth.append(data)
                groupingList.removeFirst()
            } else {
                break
            }
        }
        var groupedTrans = groupingList.sliced(by: [.year, .month], for: \.time)
        groupedTrans.insert(lastMonth, at: 0)
        groupedTrans.insert(month, at: 0)
        groupedTrans.insert(week, at: 0)
        groupedTrans.insert(today, at: 0)
        groupedTrans.removeAll { $0.isEmpty }
        return groupedTrans
    }

    func search(for keySearch: String) {
        guard !keySearch.isBlank else {
            DispatchQueue.main.async {
                self.searchedResults = nil
            }
            return
        }
        let keySearch = keySearch.lowercased()
        var groupedTrans = [[TransactionInfo]]()
        (self.transactionGrouped ?? []).forEach { items in
            let filteredItems = items.filter {
                $0.from.address.lowercased().contains(keySearch)
                || $0.to?.address.lowercased().contains(keySearch) ?? false
                || $0.amountString?.lowercased().contains(keySearch) ?? false
                || $0.type.title.lowercased().contains(keySearch)
                || ($0.type != .contract && ($0.token?.symbol ?? "ONE").lowercased().contains(keySearch))
            }
            if !filteredItems.isEmpty {
                groupedTrans.append(filteredItems)
            }
        }
        DispatchQueue.main.async {
            withAnimation {
                self.searchedResults = groupedTrans
            }
        }
    }
}
