//
//  SendView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 28/12/21.
//

import Combine
import SwiftUI

extension SendView {
    class ViewModel: ObservableObject {
        @Published var payValue: Double = 0
        @Published var payText = ""
        @Published var rateUSDPay: Double = 0
        @Published var rateONEPay: Double = 0
        @Published var loadingState: LoadingState = .none
        @Published var sendAmountType: AmountType = .token
        @Published var listToken: [TokenModel] = []
        @Published var selectedToken: TokenModel?
        @Published var getMaxUSDLoading = false

        var lastPay: Double = 0
        var cancellables = Set<AnyCancellable>()
        var listenCancellables = Set<AnyCancellable>()
        var getMaxUSDCancelable: AnyCancellable?

        enum LoadingState {
            case payChanged
            case resetting
            case none
        }

        enum AmountType: Equatable {
            case token
            case usd
            case maxAmount
            case none

            var fraction: Int {
                switch self {
                case .token:
                    return 4
                case .usd:
                    return 2
                default:
                    return 4
                }
            }
        }

        var rateCurrency: String {
            sendAmountType == .token ? "$\(Utils.formatCurrency(rateUSDPay))" :
                    "\(Utils.formatBalance(rateONEPay))"
        }

        init() {
            initPayValue()
        }
    }
}

extension SendView.ViewModel {
    func swapONEToUSD(value: Double, isUSDToOne: Bool = false) {
        let amount = Web3Service.shared.amountToWeiUnit(amount: isUSDToOne ? 1 : value,
                                                        weiUnit: OneWalletService.weiUnit)
        ExchangeRateService.shared.ONEToUSD(amount: amount)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let weakSelf = self else {
                    return
                }
                switch result {
                case .success(let usdAmount):
                    if isUSDToOne {
                        weakSelf.rateONEPay = value / usdAmount
                    } else {
                        weakSelf.rateUSDPay = usdAmount
                    }
                case .failure(let error):
                    showSnackBar(.error(error))
                }
                weakSelf.loadingState = .none
            }
            .store(in: &cancellables)
    }

    func swapTokenToUSD(value: Double, token: Web3Service.Erc20Token, isUSDToToken: Bool = false) {
        let amount = Web3Service.shared.amountToWeiUnit(amount: isUSDToToken ? 1 : value,
                                                        weiUnit: token.weiUnit)
        ExchangeRateService.shared.tokenToUSD(token: token, amount: amount)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let weakSelf = self else {
                    return
                }
                switch result {
                case .success(let usdAmount):
                    if isUSDToToken {
                        weakSelf.rateONEPay = value / usdAmount
                    } else {
                        weakSelf.rateUSDPay = usdAmount
                    }
                case .failure(let error):
                    showSnackBar(.error(error))
                }
            }
            .store(in: &cancellables)
    }

    func getMaxUSDfromONE(value: Double, isUSDToOne: Bool = false, getMaxUSDComplete: @escaping ((Double) -> Void)) {
        let amount = Web3Service.shared.amountToWeiUnit(amount: value, weiUnit: OneWalletService.weiUnit)
        getMaxUSDCancelable?.cancel()
        getMaxUSDCancelable = ExchangeRateService.shared.ONEToUSD(amount: amount)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let weakSelf = self else { return }
                switch result {
                case .success(let usdAmount): getMaxUSDComplete(usdAmount)
                case .failure(let error):
                    showSnackBar(.error(error))
                    withAnimation { weakSelf.getMaxUSDLoading = false }
                }
            }
    }

    func getMaxUSDfromToken(
        value: Double, token: Web3Service.Erc20Token, isUSDToToken: Bool = false, getMaxUSDComplete: @escaping ((Double) -> Void)
    ) {
        let amount = Web3Service.shared.amountToWeiUnit(amount: value, weiUnit: token.weiUnit)
        getMaxUSDCancelable?.cancel()
        getMaxUSDCancelable = ExchangeRateService.shared.tokenToUSD(token: token, amount: amount)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let weakSelf = self else { return }
                switch result {
                case .success(let usdAmount): getMaxUSDComplete(usdAmount)
                case .failure(let error):
                    showSnackBar(.error(error))
                    withAnimation { weakSelf.getMaxUSDLoading = false }
                }
            }
    }

    func stopCancellable() {
        getMaxUSDCancelable?.cancel()
        withAnimation { getMaxUSDLoading = false }
    }

    func resetInitialData() {
        loadingState = .resetting
        resetData()
        cancellables.forEach {
            $0.cancel()
        }
        cancellables.removeAll()
        loadingState = .none
    }

    private func resetData() {
        if payValue != 0 {
            payValue = 0
            payText = ""
        }
        lastPay = 0
        rateUSDPay = 0
        rateONEPay = 0
    }

    private func initPayValue() {
        $payValue
            .filter { !(self.loadingState == .resetting && $0 <= 0) && !Utils.isExiestCurrencyMaxDigit(String($0)) }
            .filter { self.lastPay != $0 }
            .map({ [weak self] value -> Double in
                self?.loadingState = .payChanged
                self?.lastPay = value
                return value
            })
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] doubleValue in
                guard let weakSelf = self else {
                          return
                      }
                if doubleValue == 0 {
                    weakSelf.resetInitialData()
                    return
                }
                weakSelf.cancellables.forEach {
                    $0.cancel()
                }
                weakSelf.cancellables.removeAll()
                if weakSelf.sendAmountType == .token {
                    if let token = weakSelf.selectedToken?.token {
                        weakSelf.swapTokenToUSD(value: doubleValue, token: token)
                    } else {
                        weakSelf.swapONEToUSD(value: doubleValue)
                    }
                } else {
                    if let token = weakSelf.selectedToken?.token {
                        weakSelf.swapTokenToUSD(value: doubleValue, token: token, isUSDToToken: true)
                    } else {
                        weakSelf.swapONEToUSD(value: doubleValue, isUSDToOne: true)
                    }
                }
            }
            .store(in: &listenCancellables)
    }

    func getWalletData() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.listToken = TokenInfo.shared.listToken
                weakSelf.selectedToken = weakSelf.listToken.first(where: { $0.key != nil })
                weakSelf.resetInitialData()
                weakSelf.updateBalance()
            }
        }
    }

    func updateBalance() {
        for index in 0...listToken.count - 1 {
            Utils.getWalletBalance(token: listToken[index].token)
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .receive(on: RunLoop.main)
                .sink { [weak self] balance in
                    guard let self = self else {
                        return
                    }
                    self.listToken[index].balance = balance
                    if self.listToken[index].symbol == self.selectedToken?.symbol {
                        self.selectedToken = self.listToken[index]
                    }
                }
                .store(in: &cancellables)
        }
    }
}
