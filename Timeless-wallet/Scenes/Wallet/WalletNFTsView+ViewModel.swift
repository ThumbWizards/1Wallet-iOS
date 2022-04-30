//
//  WalletNFTsView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 17/01/2022.
//

import Combine
import web3swift

extension WalletNFTsView {
    class ViewModel: ObservableObject {
        @Published var modelData: [(NFTInfo, [NFTTokenMetadata])] = []
        @Published var isLoading = false
        private var cancellables = Set<AnyCancellable>()
        var wallet: Wallet

        init(wallet: Wallet) {
            self.wallet = wallet
        }
    }
}

extension WalletNFTsView.ViewModel {
    func getNFTsToken() {
        guard let walletAddress = EthereumAddress(wallet.address) else { return }
        isLoading = true
        OneWalletService.shared.getNFTTokens(walletAddress: walletAddress)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .flatMap { tokensMapping in
                NFTService.shared.fullDetails(tokensMapping: tokensMapping)
            }
            .sink { data in
                DispatchQueue.main.async {
                    self.modelData = data.sorted { $0.0.name ?? "" < $1.0.name ?? "" }
                    self.isLoading = false
                }
            }
            .store(in: &cancellables)
    }
}
