//
//  RedPacket+ViewModel.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 03/12/21.
//

import StreamChatUI
import Combine

extension RedPacketView {
    class ViewModel: ObservableObject {
        // MARK: - Variables
        @Published var rateUSDPay: Double = 0
        var cancellables = Set<AnyCancellable>()
        var redPacket: RedPacket
        var channelUsers: Int {
            return redPacket.channelUsers ?? 1
        }

        // MARK: - Init
        init(redPacket: RedPacket) {
            self.redPacket = redPacket
        }
    }
}

// MARK: - Functions
extension RedPacketView.ViewModel {
    func swapONEToUSD(value: Double) {
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
                    weakSelf.rateUSDPay = weiAmount
                    weakSelf.redPacket.usdAmount = weiAmount
                case .failure(let error):
                    showSnackBar(.error(error))
                }
            }
            .store(in: &cancellables)
    }

    func isValidAmount() -> Bool {
        let amount = redPacket.amount ?? 0
        let recipientsCount = Float(redPacket.participantsCount ?? 0)
        if amount >= recipientsCount {
            return true
        } else {
            showSnackBar(.redPacketAmountValidation)
            return false
        }
    }
}
