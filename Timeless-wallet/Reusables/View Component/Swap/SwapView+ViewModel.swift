//
//  SwapView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/22/21.
//

import Foundation
import Combine
import web3swift
import SwiftUI
import BigInt

extension SwapView {
    class ViewModel: ObservableObject {
        @Published var payValue: Double = 0
        @Published var gotValue: Double = 0
        @Published var payText = ""
        @Published var gotText = ""
        @Published var model: [TokenModel] = []
        @Published var selectedPay: TokenModel?
        @Published var selectedGot: TokenModel?
        @Published var rateUSDPay: Double = 0
        @Published var rateUSDGot: Double = 0
        @Published var focusState: FocusState = .pay
        @Published var loadingState: LoadingState = .none
        @Published var transactionState: SwapTransactionState = .none
        @Published var swapRate = ""
        var swapTransaction: SwapTransaction?
        var providerFee = 0.003
        var loadingIconView: AnyView {
            ProgressView()
                .progressViewStyle(.circular)
                .eraseToAnyView()
        }
        var cancellables = Set<AnyCancellable>()
        var listenCancellables = Set<AnyCancellable>()
        static let shared = ViewModel()

        var lastPay: Double = 0
        var lastGot: Double = 0

        var rateUSDCompare: String {
            rateUSDGot == 0 ? "$\(Utils.formatCurrency(rateUSDGot))" :
                    "~$\(Utils.formatCurrency(rateUSDGot))"
        }

        enum LoadingState {
            case payChanged
            case gotChanged
            case resetting
            case none
        }

        enum FocusState {
            case pay
            case got
            case none
        }

        init() {
            initPayValue()
            initGotValue()
        }
    }
}

extension SwapView.ViewModel {
    func getWalletData() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.model = TokenInfo.shared.listToken
                weakSelf.selectedPay = weakSelf.model.first(where: { $0.key != nil })
                weakSelf.selectedGot = weakSelf.model.first(where: { $0.symbol == "1USDC" })
                weakSelf.resetInitialData()
                weakSelf.updateBalance()
            }
        }
    }

    func updateBalance() {
        for index in 0...model.count - 1 {
            Utils.getWalletBalance(token: model[index].token)
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .receive(on: RunLoop.main)
                .sink { [weak self] balance in
                    guard let self = self else {
                        return
                    }
                    self.model[index].balance = balance
                    if self.model[index].symbol == self.selectedPay?.symbol {
                        self.selectedPay = self.model[index]
                    }
                    if self.model[index].symbol == self.selectedGot?.symbol {
                        self.selectedGot = self.model[index]
                    }
                }
                .store(in: &cancellables)
        }
    }

    func swapONEToUSD(value: Double, focusState: FocusState, shouldEndSwaping: Bool = false) {
        let amount = Web3Service.shared.amountToWeiUnit(amount: value,
                                                        weiUnit: OneWalletService.weiUnit)
        ExchangeRateService.shared.ONEToUSD(amount: amount)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let weakSelf = self else {
                    return
                }
                switch result {
                case .success(let weiAmount):
                    switch focusState {
                    case .got:
                        weakSelf.rateUSDGot = weiAmount
                    case .pay:
                        weakSelf.rateUSDPay = weiAmount
                    default:
                        break
                    }
                case .failure(let error):
                    showSnackBar(.error(error))
                }
                if shouldEndSwaping {
                    weakSelf.loadingState = .none
                }
            }
            .store(in: &cancellables)
    }

    func swapTokenToUSD(value: Double, token: Web3Service.Erc20Token, focusState: FocusState, shouldEndSwaping: Bool = false) {
        let amount = Web3Service.shared.amountToWeiUnit(amount: value,
                                                        weiUnit: token.weiUnit)
        ExchangeRateService.shared.tokenToUSD(token: token, amount: amount)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let weakSelf = self else {
                    return
                }
                switch result {
                case .success(let weiAmount):
                    switch focusState {
                    case .got:
                        weakSelf.rateUSDGot = weiAmount
                    case .pay:
                        weakSelf.rateUSDPay = weiAmount
                    default:
                        break
                    }
                case .failure(let error):
                    showSnackBar(.error(error))
                }
                if shouldEndSwaping {
                    weakSelf.loadingState = .none
                }
            }
            .store(in: &cancellables)
    }

    func swapRateFromONE(value: Double, focusState: FocusState, token: Web3Service.Erc20Token) {
        let oneAmount = Web3Service.shared.amountToWeiUnit(amount: value,
                                                           weiUnit: OneWalletService.weiUnit)
        ExchangeRateService.shared.swapRateFromONE(to: token, amount: oneAmount)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let weakSelf = self else {
                    return
                }
                switch result {
                case .success(let tokenAmount):
                    let amount = Web3Service.shared.amountFromWeiUnit(amount: tokenAmount,
                                                                      weiUnit: token.weiUnit)
                    weakSelf.swapRate = weakSelf.swapRate(amount, value, isFromONE: true)
                    switch focusState {
                    case .pay:
                        weakSelf.setGotValue(amount)
                        weakSelf.lastGot = amount
                        weakSelf.swapTokenToUSD(value: amount,
                                                token: token,
                                                focusState: .got,
                                                shouldEndSwaping: true)
                    case .got:
                        weakSelf.setPayValue(amount)
                        weakSelf.lastPay = amount
                        weakSelf.swapTokenToUSD(value: amount,
                                                token: token,
                                                focusState: .pay,
                                                shouldEndSwaping: true)
                    default: break
                    }
                case .failure(let error):
                    weakSelf.resetData()
                    showSnackBar(.error(error))
                    weakSelf.loadingState = .none
                }
            }
            .store(in: &cancellables)
    }

    private func setPayValue(_ value: Double) {
        payText = Utils.formatBalance(value)
        payValue = Utils.formatStringToDouble(payText)
    }

    private func setGotValue(_ value: Double) {
        gotText = Utils.formatBalance(value)
        gotValue = Utils.formatStringToDouble(gotText)
    }

    func swapRateToONE(value: Double, focusState: FocusState, token: Web3Service.Erc20Token) {
        let tokenAmount = Web3Service.shared.amountToWeiUnit(amount: value,
                                                             weiUnit: token.weiUnit)
        ExchangeRateService.shared.swapRateToONE(from: token,
                                                 amount: tokenAmount)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let weakSelf = self else {
                    return
                }
                switch result {
                case .success(let oneAmount):
                    let amount = Web3Service.shared.amountFromWeiUnit(amount: oneAmount,
                                                                      weiUnit: OneWalletService.weiUnit)
                    weakSelf.swapRate = weakSelf.swapRate(amount, value, isFromONE: false)
                    switch focusState {
                    case .pay:
                        weakSelf.setGotValue(amount)
                        weakSelf.lastGot = weakSelf.gotValue
                        weakSelf.swapONEToUSD(value: amount,
                                              focusState: .got,
                                              shouldEndSwaping: true)
                    case .got:
                        weakSelf.setPayValue(amount)
                        weakSelf.lastPay = weakSelf.payValue
                        weakSelf.swapONEToUSD(value: amount,
                                              focusState: .pay,
                                              shouldEndSwaping: true)
                    default: break
                    }
                case .failure(let error):
                    weakSelf.resetData()
                    showSnackBar(.error(error))
                    weakSelf.loadingState = .none
                }
            }
            .store(in: &cancellables)
    }

    func swapONEToToken() {
        guard let token = selectedGot?.token else { return }
        swapTransaction = SwapTransaction(token: token, amount: payValue, delegate: self)
        swapTransaction?.startSwapOneToToken()
    }

    func swapTokenToONE() {
        guard let token = selectedPay?.token else { return }
        swapTransaction = SwapTransaction(token: token, amount: payValue, delegate: self)
        swapTransaction?.startSwapTokenToOne()
    }
    
    private func initPayValue() {
        $payValue
            .filter { !(self.loadingState == .resetting && $0 <= 0)
                && self.focusState == .pay && !Utils.isExiestCurrencyMaxDigit(String($0)) }
            .filter { self.lastPay != $0 }
            .map({ [weak self] value -> Double in
                self?.loadingState = .payChanged
                self?.lastPay = value
                return value
            })
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] doubleValue in
                guard let weakSelf = self,
                      weakSelf.selectedPay != nil,
                      weakSelf.selectedGot != nil else {
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
                if let token = weakSelf.selectedPay?.token {
                    weakSelf.swapRateToONE(value: doubleValue,
                                           focusState: .pay,
                                           token: token)
                    weakSelf.swapTokenToUSD(value: doubleValue,
                                            token: token,
                                            focusState: .pay)
                } else if let token = weakSelf.selectedGot?.token {
                    weakSelf.swapRateFromONE(value: doubleValue,
                                             focusState: .pay,
                                             token: token)
                    weakSelf.swapONEToUSD(value: doubleValue,
                                          focusState: .pay)
                }
            }
            .store(in: &listenCancellables)
    }

    private func initGotValue() {
        $gotValue
            .filter { !(self.loadingState == .resetting && $0 <= 0)
                && self.focusState == .got && !Utils.isExiestCurrencyMaxDigit(String($0)) }
            .filter { self.lastGot != $0 }
            .map({ [weak self] value -> Double in
                self?.loadingState = .gotChanged
                self?.lastGot = value
                return value
            })
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] doubleValue in
                guard let weakSelf = self,
                      weakSelf.selectedGot != nil,
                      weakSelf.selectedPay != nil else {
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
                if let token = weakSelf.selectedGot?.token {
                    weakSelf.swapRateToONE(value: doubleValue,
                                           focusState: .got,
                                           token: token)
                    weakSelf.swapTokenToUSD(value: doubleValue,
                                            token: token,
                                            focusState: .got)
                } else if let token = weakSelf.selectedPay?.token {
                    weakSelf.swapRateFromONE(value: doubleValue,
                                             focusState: .got,
                                             token: token)
                    weakSelf.swapONEToUSD(value: doubleValue,
                                          focusState: .got)
                }
            }
            .store(in: &listenCancellables)
    }

    func resetInitialData() {
        loadingState = .resetting
        resetData()
        cancellables.forEach {
            $0.cancel()
        }
        cancellables.removeAll()
        if let token = selectedGot?.token {
            let oneAmount = Web3Service.shared.amountToWeiUnit(amount: 1,
                                                               weiUnit: OneWalletService.weiUnit)
            ExchangeRateService.shared.swapRateFromONE(to: token, amount: oneAmount)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] result in
                    guard let weakSelf = self else {
                        return
                    }
                    switch result {
                    case .success(let tokenAmount):
                        let amount = Web3Service.shared.amountFromWeiUnit(amount: tokenAmount,
                                                                          weiUnit: token.weiUnit)
                        weakSelf.swapRate = weakSelf.swapRate(amount, 1, isFromONE: true)
                    case .failure(let error):
                        showSnackBar(.error(error))
                    }
                    weakSelf.loadingState = .none
                }
                .store(in: &cancellables)

        } else if let token = selectedPay?.token {
            let tokenAmount = Web3Service.shared.amountToWeiUnit(amount: 1,
                                                                 weiUnit: token.weiUnit)
            ExchangeRateService.shared.swapRateToONE(from: token,
                                                     amount: tokenAmount)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] result in
                    guard let weakSelf = self else {
                        return
                    }
                    switch result {
                    case .success(let oneAmount):
                        let amount = Web3Service.shared.amountFromWeiUnit(amount: oneAmount,
                                                                          weiUnit: OneWalletService.weiUnit)
                        weakSelf.swapRate = weakSelf.swapRate(amount, 1, isFromONE: false)
                    case .failure(let error):
                        showSnackBar(.error(error))
                    }
                    weakSelf.loadingState = .none
                }
                .store(in: &cancellables)
        }
    }

    private func resetData() {
        if payValue != 0 || focusState == .got {
            payValue = 0
            payText = ""
        }
        if gotValue != 0 || focusState == .pay {
            gotValue = 0
            gotText = ""
        }
        lastPay = 0
        lastGot = 0
        rateUSDPay = 0
        rateUSDGot = 0
    }

    func swapRate(_ amount: Double, _ value: Double, isFromONE: Bool) -> String {
        let number = amount / value > 1 ? amount / value : value / amount
        let symbol = selectedPay?.key == nil ? selectedPay?.symbol ?? "" : selectedGot?.symbol ?? ""
        if isFromONE {
            if amount > value {
                return "1 ONE ~ \(Utils.formatBalance(number)) \(symbol)"
            } else {
                return "1 \(symbol) ~ \(Utils.formatBalance(number)) ONE"
            }
        } else {
            if amount > value {
                return "1 \(symbol) ~ \(Utils.formatBalance(number)) ONE"
            } else {
                return "1 ONE ~ \(Utils.formatBalance(number)) \(symbol)"
            }
        }
    }
}

// MARK: - swapTransaction delegate
extension SwapView.ViewModel: SwapTransactionDelegate {
    func transactionState(instance: SwapTransaction, state: SwapTransactionState) {
        transactionState = state
    }

    func didFinishTransaction(instance: SwapTransaction) {
        hideConfirmationSheet()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showConfirmation(.transaction(swapViewModel: self))
            WalletInfo.shared.refreshWalletData()
        }
    }

    func didFailTransaction(instance: SwapTransaction, with error: Error?) {
        showSnackBar(.error(error))
        hideConfirmationSheet()
    }
}
