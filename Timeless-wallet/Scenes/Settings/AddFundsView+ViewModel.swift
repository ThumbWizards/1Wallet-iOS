//
//  AddFundsView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 1/12/22.
//

import Foundation
import Combine

extension AddFundsView {
    class ViewModel: ObservableObject {
        @Published var isLoading = false
        @Published var isSwaping = false
        @Published var uid = ""
        @Published var rateOne = ""
        @Published var convertToOneONE = ""
        var currentNetworkCalls = Set<AnyCancellable>()
        var debounce: Timer?
    }
}

extension AddFundsView.ViewModel {
    func checkout(amount: Double, completion: @escaping ((URL) -> Void)) {
        isLoading = true
        SimplexService.shared.getNewQuote(amount: amount, uid: uid)
            .sink { [weak self] result in
                guard let weakSelf = self else {
                    return
                }
                switch result {
                case .success(let data):
                    guard let currentWallet = Wallet.currentWallet else { return }
                    SimplexService.shared.getPaymentId(walletAddress: currentWallet.address,
                                                       quoteResponse: data)
                        .sink { [weak self] result in
                            guard let weakSelf = self else {
                                return
                            }
                            switch result {
                            case .success(let data):
                                SimplexService.shared.getCheckout(paymentId: data.paymentId ?? "")
                                    .sink { [weak self] result in
                                        guard let weakSelf = self else {
                                            return
                                        }
                                        switch result {
                                        case .success(let url):
                                            let baseURL = SimplexService.RequestType.checkout.baseURL
                                            let urlString = baseURL + url
                                            if let url = URL(string: urlString) {
                                                completion(url)
                                            }
                                            weakSelf.isLoading = false
                                        case .failure(let error):
                                            showSnackBar(.error(error))
                                            weakSelf.isLoading = false
                                        }
                                    }
                                    .store(in: &weakSelf.currentNetworkCalls)
                            case .failure(let error):
                                showSnackBar(.error(error))
                                weakSelf.isLoading = false
                            }
                        }
                        .store(in: &weakSelf.currentNetworkCalls)
                case .failure(let error):
                    showSnackBar(.error(error))
                    weakSelf.isLoading = false
                }
            }
            .store(in: &currentNetworkCalls)
    }

    func getNewQuote(amount: Double, uid: String) {
        isSwaping = true
        guard amount >= 50 else {
            rateOne = Utils.formatBalance(0)
            isSwaping = false
            return
        }
        currentNetworkCalls.forEach {
            $0.cancel()
        }
        currentNetworkCalls.removeAll()
        debounce?.invalidate()
        debounce = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            guard let weakSelf = self else { return }
            SimplexService.shared.getNewQuote(amount: amount, uid: uid)
                .sink { [weak self] result in
                    guard let weakSelf = self else {
                        return
                    }
                    switch result {
                    case .success(let data):
                        weakSelf.rateOne = Utils.formatBalance(data.digitalMoney?.amount ?? 0)
                        weakSelf.convertToOneONE = Utils.formatBalance((data.digitalMoney?.amount ?? 0) / amount)
                        weakSelf.isSwaping = false
                    case .failure(let error):
                        showSnackBar(.error(error))
                        weakSelf.isSwaping = false
                    }
                }
                .store(in: &weakSelf.currentNetworkCalls)
        }
    }
}

// MARK: - Static Properties
extension AddFundsView.ViewModel {
    static let shared = AddFundsView.ViewModel()
}
