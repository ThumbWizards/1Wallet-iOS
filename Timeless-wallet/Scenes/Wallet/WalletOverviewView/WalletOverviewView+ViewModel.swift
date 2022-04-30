//
//  WalletOverviewView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 1/18/22.
//

import Combine
import web3swift
import Foundation

extension WalletOverviewView {
    class ViewModel: ObservableObject {
        @Published var chartData: [(time: Date, price: Double)] = []
        @Published var walletAsset: [WalletAssetInfo]?
        @Published var timeDisplayOption: TimeDisplayOption = .daily
        @Published var loadingChartData = false
        var currentNetworkCalls = Set<AnyCancellable>()
        var wallet: Wallet
        @Published var totalUSDAmount: Double?
        @Published var totalONEAmount: Double?
        var totalPriceChangePercentage: Double = 0
        var totalPriceChange: Double = 0
        
        init(wallet: Wallet) {
            self.wallet = wallet
        }

        var compareUnit: String {
            switch timeDisplayOption {
            case .hourly: return "Past Hour"
            case .daily: return "Today"
            case .weekly: return "Past Week"
            case .monthly: return "Past Month"
            case .yearly: return "Past Year"
            }
        }
    }
}

extension WalletOverviewView.ViewModel {
    func getChartData() {
        loadingChartData = true
        let range = timeDisplayOption.range
        GetDataChartService.shared.getDataChart(fromTime: range.fromTime, toTime: range.toTime)
            .sink { [weak self] result in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.loadingChartData = false
                switch result {
                case .success(let data):
                    weakSelf.mappingChartData(data)
                case .failure(let error):
                    showSnackBar(.error(error))
                }
            }
            .store(in: &currentNetworkCalls)
    }

    func getWalletAssetInfo(completion: (() -> Void)?) {
        OneWalletService.shared.walletAssets(for: EthereumAddress(wallet.address)!)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { result in
                switch result {
                case .finished:
                    break
                case .failure:
                    self.walletAsset = []
                    completion?()
                }
            } receiveValue: { result in
                self.walletAsset = result
                let amount = Web3Service.shared.amountToWeiUnit(amount: 1,
                                                                weiUnit: OneWalletService.weiUnit)
                ExchangeRateService.shared.ONEToUSD(amount: amount)
                    .subscribe(on: DispatchQueue.global())
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] result in
                        guard let weakSelf = self else {
                            return
                        }
                        switch result {
                        case .success(let usdAmound):
                            guard let walletAsset = weakSelf.walletAsset else { return }
                            weakSelf.totalUSDAmount = walletAsset.map { $0.usdAmount }.reduce(0, +)
                            if walletAsset.contains(where: { $0.token != nil  }) {
                                weakSelf.totalONEAmount = (weakSelf.totalUSDAmount ?? 0) / usdAmound
                            } else {
                                weakSelf.totalONEAmount = walletAsset.map { $0.displayAmount }.reduce(0, +)
                            }
                            if let total = weakSelf.totalUSDAmount {
                                weakSelf.totalPriceChangePercentage = walletAsset.map {
                                    $0.usdAmount * $0.priceChangePercentage24h / 100
                                }
                                .reduce(0, +) / total
                                weakSelf.totalPriceChange = abs(total * weakSelf.totalPriceChangePercentage / 100)
                            } else {
                                weakSelf.totalPriceChangePercentage = 0
                                weakSelf.totalPriceChange = 0
                            }
                            completion?()
                        case .failure:
                            break
                        }
                    }
                    .store(in: &self.currentNetworkCalls)
            }
            .store(in: &currentNetworkCalls)
    }

    private func mappingChartData(_ array: ChartData) {
        if let prices = array.prices {
            let chart = prices.map { double in
                (Date(timeIntervalSince1970: double[0] / 1000), double[1])
            }
            self.chartData = chart
        }
    }
}
