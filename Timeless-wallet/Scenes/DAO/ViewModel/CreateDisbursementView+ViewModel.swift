//
//  CreateDisbursementView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 02/02/22.
//

import StreamChatUI
import Combine
import BigInt
import web3swift
import SwiftUI
import StreamChat

extension CreateDisbursementView {
    class ViewModel: ObservableObject {
        // MARK: - Variables
        @Published var currencyValue: CGFloat = 0
        @Published var currency: String = "0"
        @Published var amountState: SendView.ViewModel.AmountType = .none
        @Published var rateUSDGot: Double = 0
        @Published var oneValue = 0.0
        @Published var totalOneBalance = 0.0
        @Published var recipientWalletAddress = ""
        @Published var recipientBalance = 0.0
        @Published var stringPurpose = ""
        @Published var maxAmount: Double = 100.0
        @Published var isCurrencyUpdate = false {
            didSet {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    guard let `self` = self else { return }
                    self.isCurrencyUpdate = false
                }
            }
        }
        private var currentSwapCalls = Set<AnyCancellable>()
        private var oneCancellable = Set<AnyCancellable>()
        private var balanceCancellable = Set<AnyCancellable>()
        var walletAddress: String
        var disbursementModel: DisbursementModel?
        var hideKeyboard: (() -> Void)?
        var walletAddressInfo: String {
            return walletAddress.convertToWalletAddress().trimStringByCount(count: 10)
        }

        // MARK: - Init
        init(with data: [String: RawJSON]) {
            recipientWalletAddress = "one1dcw94welpwewc0xrd0shc994dgh3mtrxffcqkm"
            disbursementModel = DisbursementModel(with: data)
            self.walletAddress = disbursementModel?.getSafeAddress() ?? ""
            $oneValue
                .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
                .sink { [weak self] value in
                    guard let `self` = self else { return }
                    self.swapONEToUSD(value: value)
                }
                .store(in: &oneCancellable)
            getWalletBalance()
        }

    }
}

// MARK: - Functions
extension CreateDisbursementView.ViewModel {
    private func swapONEToUSD(value: Double, shouldEndSwaping: Bool = false) {
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
                    weakSelf.rateUSDGot = weiAmount
                case .failure(let error):
                    showSnackBar(.error(error))
                }
            }
            .store(in: &currentSwapCalls)
    }

    private func getWalletBalance() {
        guard let address = EthereumAddress(self.walletAddress.convertBech32ToEthereum()) else { return }
        Web3Service.shared.getBalance(at: address)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] balance in
                guard let `self` = self else { return }
                self.maxAmount = Web3Service.shared.amountFromWeiUnit(amount: balance, weiUnit: OneWalletService.weiUnit)
                self.totalOneBalance = self.maxAmount
            })
            .store(in: &self.balanceCancellable)
        guard let recipientAddress = EthereumAddress(self.recipientWalletAddress.convertBech32ToEthereum()) else { return }
        Web3Service.shared.getBalance(at: recipientAddress)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] recipientBalances in
                guard let `self` = self else { return }
                self.recipientBalance = Web3Service.shared.amountFromWeiUnit(
                    amount: recipientBalances,
                    weiUnit: OneWalletService.weiUnit
                )
            })
            .store(in: &self.balanceCancellable)
    }

    @objc func doneButtonTapped() {
        self.hideKeyboard?()
    }

    func submitReview(recipientWalletAddress: String) {
        guard let ethereumAddress = EthereumAddress(recipientWalletAddress.convertBech32ToEthereum()) else {
            return
        }
        self.disbursementModel?.recipientWallet = ethereumAddress
        self.disbursementModel?.usdBalance = rateUSDGot
        self.disbursementModel?.oneBalance = oneValue
        self.disbursementModel?.purpose = stringPurpose
    }

    func isValidInputAmount(amount: Double) -> Bool {
        guard amount <= maxAmount else {
            return false
        }
        return true
    }

    func onQRCodeScanSuccess(strScanned: String) {
        if let url = URL(string: strScanned), UIApplication.shared.canOpenURL(url) {
            let lastComponent = url.lastPathComponent
            if lastComponent.isOneWalletAddress,
               EthereumAddress(lastComponent.convertBech32ToEthereum()) != nil {
                recipientWalletAddress = lastComponent
            }
        } else if strScanned.isOneWalletAddress,
                  EthereumAddress(strScanned.convertBech32ToEthereum()) != nil {
            recipientWalletAddress = strScanned
        }
    }
}
