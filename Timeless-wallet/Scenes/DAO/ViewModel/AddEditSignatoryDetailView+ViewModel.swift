//
//  AddEditSignatoryDetailView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 01/02/22.
//

import Foundation
import web3swift
import Combine

extension AddEditSignatoryDetailView {
    class ViewModel: ObservableObject {
        // MARK: - Variables
        @Published var walletAlias = ""
        @Published var walletAddress = ""
        @Published var isLoading = false
        var avatar: String?
        var screenType: ScreenType
        var signersDetail: SignerWallet?
        var cancellable = Set<AnyCancellable>()
        var isEnableSave: Bool {
            if !walletAlias.isEmpty && walletAddress.isOneWalletAddress {
                return true
            } else {
                return false
            }
        }
        var headerSubTitle: String {
            if screenType == .add {
                return "Add Signatory Detail"
            } else {
                return "Edit Signatory Detail"
            }
        }
        
        // MARK: - Init
        init(screenType: ScreenType, signersDetail: SignerWallet? = nil) {
            self.screenType = screenType
            self.signersDetail = signersDetail
            walletAlias = signersDetail?.walletName ?? ""
            walletAddress = signersDetail?.walletAddress?.address ?? ""
        }
    }
}

// MARK: - enums
extension AddEditSignatoryDetailView.ViewModel {
    enum ScreenType {
        case add
        case edit
    }
}

// MARK: - Functions
extension AddEditSignatoryDetailView.ViewModel {
    func checkAndAddSigner(completion: @escaping ((Bool) -> Void)) {
        isLoading = true
        IdentityService.shared.checkWalletAddress(address: walletAddress.convertBech32ToEthereum())
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
                    completion(true)
                case .failure:
                    showSnackBar(.somethingWentWrongRandomText)
                    completion(false)
                }
            })
            .store(in: &cancellable)
    }
}
