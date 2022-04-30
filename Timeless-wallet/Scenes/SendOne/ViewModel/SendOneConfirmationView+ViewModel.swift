//
//  PaymentConfirmationVIew+ViewModel.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 01/12/21.
//

import Foundation
import web3swift
import BigInt
import Combine
import StreamChatUI
import StreamChat
import SwiftUI

extension SendOneConfirmationView {
    class ViewModel: ObservableObject {
        // MARK: - Variables
        @Published var sendOneWalletData: SendOneWallet
        @Published var canCancelTransaction = true
        @Published var isTransactionInProgress = false
        @Published var showDestinationAvatar = false
        @Published var loadRecipientName = false

        var checkTLUserCancellable: AnyCancellable?
        var walletTransaction: TransferTransaction?
        var screenType: ScreenType?
        var daoChannel: ChatChannelController?
        var isDirectSend = false
        var transferOne: TransferOne?
        var destinationAddressStr: String? {
            isDirectSend ? transferOne?.destinationAddress?.address : sendOneWalletData.recipientAddress
        }
        var destinationAddress: EthereumAddress? {
            if isDirectSend {
                return EthereumAddress(transferOne?.destinationAddress?.address.convertBech32ToEthereum() ?? "")
            } else {
                return EthereumAddress(sendOneWalletData.recipientAddress?.convertBech32ToEthereum() ?? "")
            }
        }

        var transferAmount: Float? {
            if isDirectSend {
                return transferOne?.transferAmount
            } else {
                return sendOneWalletData.transferAmount
            }
        }

        var strFormattedAmount: String? {
            if isDirectSend {
                return transferOne?.strFormattedAmount
            } else {
                return sendOneWalletData.strFormattedAmount
            }
        }

        var sendFromName: String? {
            if isDirectSend {
                return Wallet.currentWallet?.name
            } else {
                return sendOneWalletData.myName ?? "-"
            }
        }

        var sendFromAddress: String? {
            if isDirectSend {
                return Wallet.currentWallet?.address
            } else {
                return sendOneWalletData.myWalletAddress ?? "-"
            }
        }

        var fractionDigits: Int {
            if isDirectSend {
                return transferOne?.fractionDigits ?? 0
            } else {
                return sendOneWalletData.fractionDigits
            }
        }

        var token: Web3Service.Erc20Token?
        var parameters: [AnyObject]?

        // MARK: - Initializer
        init(walletData: SendOneWallet,
             screenType: ScreenType,
             channel: ChatChannelController?,
             token: Web3Service.Erc20Token? = nil,
             parameters: [AnyObject]? = nil) {
            self.sendOneWalletData = walletData
            self.screenType = screenType
            self.daoChannel = channel
            self.token = token
            self.parameters = parameters
        }

        init(transferOne: TransferOne?) {
            self.transferOne = transferOne
            self.isDirectSend = true
            self.sendOneWalletData = .init()
        }
    }
}

extension SendOneConfirmationView.ViewModel {
    func checkTLUser() {
        withAnimation(.easeInOut(duration: 0.2)) {
            loadRecipientName = true
        }
        checkTLUserCancellable = IdentityService.shared
            .checkWalletAddress(address: (destinationAddressStr ?? "").convertBech32ToEthereum())
            .sink(receiveValue: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let wallet):
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if let title = wallet.title, !title.isEmpty {
                            self.sendOneWalletData.recipientName = title
                            self.showDestinationAvatar = true
                        } else {
                            self.sendOneWalletData.recipientName = ""
                            self.showDestinationAvatar = false
                        }
                    }
                case .failure:
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.sendOneWalletData.recipientName = ""
                        self.showDestinationAvatar = false
                    }
                }
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.loadRecipientName = false
                }
            })
    }

    func sendOne() {
        guard let destinationAddress = destinationAddress,
                let amount = transferAmount else {
                  showSnackBar(.error())
                  hideConfirmationSheet()
                  return
              }
        isTransactionInProgress = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let `self` = self else { return }
            self.walletTransaction = TransferTransaction(
                destinationWalletAddress: destinationAddress,
                amount: Double(amount).rounded(toPlaces: self.fractionDigits),
                token: self.token,
                parameters: self.parameters,
                delegate: self)
            self.walletTransaction?.start()
        }
    }

    func cancelTransaction() {
        guard let transactionStatus = walletTransaction?.transactionStatus else {
            showSnackBar(.transactionCancelled)
            hideConfirmationSheet()
            return
        }
        switch transactionStatus {
        case .committing, .verifyingCommit, .pendingReveal, .none:
            walletTransaction?.abort()
        case .revealing, .done:
            break
        }
    }

    private func refreshWalletBalance() {
        WalletInfo.shared.refreshWalletData()
    }

    private func goToDaoGroup() {
        guard let userId = ChatClient.shared.currentUserId else {
            return
        }
        if TabBarView.ViewModel.shared.selectedTab != 2 {
            TabBarView.ViewModel.shared.selectedTab = 2
        }
        daoChannel?.addMembers(userIds: [userId], completion: { [weak self] error in
            guard let self = self else {
                return
            }
            guard error == nil else {
                showSnackBar(.errorMsg(text: "Error while adding you to the channel!"))
                return
            }
            var userInfo = [AnyHashable: Any]()
            userInfo["channelController"] = self.daoChannel
            NotificationCenter.default.post(name: .pushToDaoChatMessageScreen, object: nil, userInfo: userInfo)
        })
    }
    
    func sendOneMessage() {
        guard let channelId = self.sendOneWalletData.channelId else {
            return
        }
        ChatClient.shared.channelController(for: channelId)
            .createNewMessage(
            text: "Sent ONE",
            pinning: nil,
            attachments: [],
            extraData: ["oneWalletTx": .dictionary(sendOneWalletData.toDictionary())],
            completion: nil)
    }
}

// MARK: - Enums
extension SendOneConfirmationView.ViewModel {
    enum ScreenType {
        case send
        case daoTransfer
    }
}

// MARK: - Wallet transfer delegates
extension SendOneConfirmationView.ViewModel: TransferTransactionDelegate {
    func didStartTransaction(instance: TransferTransaction) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.canCancelTransaction = true
            self.isTransactionInProgress = true
        }
    }

    func didCompleteTransaction(instance: TransferTransaction, transactionId: String?) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if self.isDirectSend {
                WalletInfo.shared.refreshWalletData()
                NotificationCenter.default.post(name: .dismissSendOneViews, object: nil)
                self.sendOneMessage()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    UIApplication.shared.startConfettiAnimation()
                }
                hideConfirmationSheet()
                showSnackBar(.message(text:
                                        "🎊 Sent \(self.strFormattedAmount ?? "") \(self.transferAmount ?? 0 <= 1 ? "ONE" : "ONES")",
                                      hideIcon: true))
            } else {
                if self.screenType == .daoTransfer {
                    self.sendOneWalletData.txId = transactionId
                    WalletInfo.shared.refreshWalletData()
                    NotificationCenter.default.post(name: .dismissSendOneViews, object: nil)
                    self.sendOneMessage()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        UIApplication.shared.startConfettiAnimation()
                    }
                    hideConfirmationSheet()
                    showConfirmation(.sendOneSuccessful(walletData: self.sendOneWalletData,
                                                        symbol: self.token?.symbol ?? "ONE"))
                    self.goToDaoGroup()
                } else {
                    self.sendOneWalletData.txId = transactionId
                    self.refreshWalletBalance()
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else { return }
                        self.sendOneWalletData.txId = transactionId
                        NotificationCenter.default.post(name: .dismissSendOneViews, object: nil)
                        self.sendOneMessage()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            UIApplication.shared.startConfettiAnimation()
                        }
                        hideConfirmationSheet()
                        showConfirmation(.sendOneSuccessful(walletData: self.sendOneWalletData,
                                                            symbol: self.token?.symbol ?? "ONE"))
                    }
                }
            }
        }
    }

    func didFailTransaction(instance: TransferTransaction, error: OneWalletService.CommitRevealError) {
        DispatchQueue.main.async {
            if error == .noInternet {
                showSnackBar(.internetConnectionError)
            } else {
                showSnackBar(.walletTransactionFailed)
            }
            hideConfirmationSheet()
        }
    }

    func transactionStatusHasChanged(instance: TransferTransaction, status: OneWalletService.CommitRevealProgress) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            switch status {
            case .committing, .verifyingCommit, .pendingReveal, .none:
                self.canCancelTransaction = true
            case .revealing, .done:
                self.canCancelTransaction = false
            }
        }
    }

    func transactionAborted(instance: TransferTransaction) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.canCancelTransaction = true
            self.isTransactionInProgress = false
            showSnackBar(.transactionCancelled)
        }
    }
}
