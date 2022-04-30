//
//  SendPaymentViewModel.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 26/11/21.
//

import StreamChatUI
import Combine
import BigInt
import web3swift

extension SendPaymentView {
    class ViewModel: ObservableObject {
        // MARK: - Variables
        @Published var rateUSDGot: Double = 0
        @Published var scanAddress = ""
        @Published var checkAddressCancelable: AnyCancellable?
        @Published var recipientName = ""
        @Published var currencyValue: CGFloat = 0.0
        private var currentAPICalls = Set<AnyCancellable>()
        var isRedPacket = false
        var isDirectSend = false
        var sendOneWalletData: SendOneWallet?
        var recipientAddress: EthereumAddress?
        var redPacket: RedPacket?
        var paymentTypes: [String] {
            return ["Default",
                    "1/n",
                    "Booze",
                    "Gracias",
                    "Red Packet",
                    "Je t'aime"]
        }

        var userTitle: String {
            if isRedPacket {
                return "From your wallet"
            } else {
                return "Recipient address"
            }
        }
        var walletAddress: String {
            if isDirectSend {
                return recipientAddress?.address.trimStringByCount(count: 10) ?? "-"
            } else if isRedPacket {
                return redPacket?.myWalletAddress?.convertToWalletAddress().trimStringByCount(count: 10) ?? "-"
            } else {
                return sendOneWalletData?.recipientAddress?.convertToWalletAddress().trimStringByCount(count: 10) ?? "-"
            }
        }
        var userName: String {
            if isRedPacket {
                return redPacket?.myName?.toCrazyOne() ?? "-"
            } else {
                return sendOneWalletData?.recipientName?.toCrazyOne() ?? "-"
            }
        }

        // MARK: - Init
        init(walletData: SendOneWallet) {
            sendOneWalletData = walletData
            self.isRedPacket = false
            bindCurrency()
        }

        init(redPacket: RedPacket) {
            self.redPacket = redPacket
            self.isRedPacket = true
            bindCurrency()
        }

        init(address: String) {
            self.recipientAddress = EthereumAddress(address.convertBech32ToEthereum())
            self.scanAddress = address
            self.isDirectSend = true
            bindCurrency()
            $scanAddress
                .sink { [weak self] scannedResult in
                    guard let weakSelf = self else { return }
                    weakSelf.checkAddressCancelable?.cancel()
                    weakSelf.checkAddressCancelable = IdentityService.shared
                        .checkWalletAddress(address: scannedResult.convertBech32ToEthereum())
                        .sink(receiveValue: { [weak self] result in
                            guard let self = self else { return }
                            switch result {
                            case .success(let result):
                                if let title = result.title, !title.isEmpty {
                                    self.recipientName = title
                                } else {
                                    self.recipientName = ""
                                }
                            case .failure:
                                self.recipientName = ""
                            }
                        })
                }
                .store(in: &currentAPICalls)
        }

        private func bindCurrency() {
            $currencyValue
                .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
                .sink(receiveValue: { [weak self] value in
                    guard let `self` = self else {
                        return
                    }
                    self.swapONEToUSD(value: value)
                })
                .store(in: &currentAPICalls)
        }
    }
}

// MARK: - Functions
extension SendPaymentView.ViewModel {
    func swapONEToUSD(value: Double, shouldEndSwaping: Bool = false) {
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
            .store(in: &currentAPICalls)
    }

    private func walletBalance() -> Double? {
        guard let currentWallet = Wallet.currentWallet,
                let walletAddress = EthereumAddress(currentWallet.address.convertBech32ToEthereum()) else { return nil }
        do {
            let balance: BigUInt = try Web3Service.shared.getBalance(at: walletAddress)
            let dblBalance = Web3Service.shared.amountFromWeiUnit(amount: balance, weiUnit: OneWalletService.weiUnit)
            return dblBalance
        } catch {
            return nil
        }
    }

    func checkInputAmount(amount: Double) -> Bool {
        guard let walletBalance = walletBalance(), amount <= walletBalance else {
            showSnackBar(.errorMsg(text: "Entered amount is more than wallet balance"))
            return false
        }
        return true
    }
}
