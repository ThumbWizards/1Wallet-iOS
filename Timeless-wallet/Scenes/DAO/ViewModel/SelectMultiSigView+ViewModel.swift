//
//  SelectMultiSigView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 01/02/22.
//

import Foundation
import web3swift
import StreamChat
import Combine

extension SelectMultiSigView {
    class ViewModel: ObservableObject {
        // MARK: - Variables
        var daoModel: CreateDaoModel
        var deleteIndex: Int?
        var cancellable = Set<AnyCancellable>()
        @Published var signers: [SignerWallet] = []
        @Published var thresholdCount = "2"
        @Published var isLoading = false

        // MARK: - Init
        init(_ daoModel: CreateDaoModel) {
            self.daoModel = daoModel
            if let currentWallet = Wallet.currentWallet {
                signers.append(.init(
                    walletAddress: EthereumAddress(currentWallet.address),
                    walletName: currentWallet.name ?? "Wallet Alias",
                    walletAvatar: ChatClient.shared.currentUserController().currentUser?.imageURL?.absoluteString
                    ?? "contactAvatar2"))
            }
        }
    }
}

// MARK: - Functions
extension SelectMultiSigView.ViewModel {
    func addSigner(_ data: SignerWallet) {
        guard signers.filter({$0.walletAddress == data.walletAddress}).isEmpty else {
            showSnackBar(.message(text: "Signer already exists"))
            return
        }
        signers.append(data)
    }

    func addSigner(_ data: CheckAddress) {
        guard signers.filter({$0.walletAddress?.address == data.address}).isEmpty else {
            showSnackBar(.message(text: "Signer already exists"))
            return
        }
        guard let address = EthereumAddress(data.address?.convertBech32ToEthereum() ?? "") else {
            showSnackBar(.message(text: "Invalid wallet address"))
            return
        }
        var signer = SignerWallet()
        signer.walletAddress = address
        signer.walletName = data.title
        signer.walletAvatar = data.avatar ?? "contactAvatar2"
        signers.append(signer)
    }

    func replaceSigner(at index: Int, _ data: SignerWallet) {
        signers[safe: index] = data
    }

    func deleteSigner(at index: Int) {
        signers.remove(at: index)
    }

    func isValidate() -> Bool {
        guard let thresholdCount = Int(thresholdCount) else {
            showSnackBar(.message(text: "Please enter correct signatories"))
            return false
        }
        if signers.count < 3 {
            showSnackBar(.message(text: "For safety minimum 3 signatories required"))
            return false
        }
        if thresholdCount < 2 {
            showSnackBar(.message(text: "May only select min 2 signatories"))
            return false
        }
        if thresholdCount > signers.count {
            showSnackBar(.message(text: "May only select max \(signers.count) signatories"))
            return false
        }
        return true
    }

    func bindDaoData() {
        daoModel.signers = signers
        daoModel.threshold = Int(thresholdCount)
    }
}

// MARK: - API
extension SelectMultiSigView.ViewModel {
    func checkAndAddSigner(address: String) {
        isLoading = true
        IdentityService.shared.checkWalletAddress(address: address.convertBech32ToEthereum())
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] result in
                guard let self = self else {
                    return
                }
                self.isLoading = false
                switch result {
                case .success(let result):
                    guard !(result.ownerid?.isEmpty ?? true) else {
                        showSnackBar(.message(text: "Please enter correct signer"))
                        return
                    }
                    self.addSigner(result)
                case .failure:
                    showSnackBar(.message(text: "Can not add signer"))
                }
            })
            .store(in: &cancellable)
    }
}
