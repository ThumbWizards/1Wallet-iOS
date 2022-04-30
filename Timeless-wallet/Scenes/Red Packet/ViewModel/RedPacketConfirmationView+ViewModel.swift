//
//  RedPacketConfirmationView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 07/12/21.
//

import StreamChatUI
import Combine
import SwiftUIX
import web3swift
import BigInt
import StreamChat

extension RedPacketConfirmationView {
    class ViewModel: ObservableObject {
        // MARK: - Variables
        var redPacket: RedPacket
        private var giftPacketCancellable: AnyCancellable?
        private var topupCancellable: AnyCancellable?
        private var cancellables = Set<AnyCancellable>()
        @Published var isLoading = false
        @Published var btn1State: ButtonState = .confirmSend
        @Published var btn2State: ButtonState = .cancel

        // MARK: - Init
        init(redPacket: RedPacket) {
            self.redPacket = redPacket
        }
    }
}

extension RedPacketConfirmationView.ViewModel {
    enum ButtonState {
        case confirmSend
        case confirmSendDisable
        case cancel
        case cancelDisable
        case retry
        case retryCancel
    }
}

// MARK: - Functions
// swiftlint:disable shorthand_operator
extension RedPacketConfirmationView.ViewModel {
    private func reqRedPacket() -> ReqDropGiftPacket {
        var amount = redPacket.amount ?? 0
        // max amount
        amount = amount - Float((redPacket.participantsCount ?? 0)) + 1
        let maxAmount = String(Web3Service.shared.amountToWeiUnit(
            amount: Double(amount).rounded(toPlaces: redPacket.fractionDigits),
            weiUnit: OneWalletService.weiUnit))
        // min amount
        let minAmount = String(Web3Service.shared.amountToWeiUnit(
            amount: 1,
            weiUnit: OneWalletService.weiUnit))
        // request params
        let req = ReqDropGiftPacket()
        req.title = "Red packet drop!"
        req.minAmount = minAmount
        req.maxAmount = maxAmount
        req.recipientsCap = redPacket.participantsCount
        req.endTime = Date().toRedPacketExpireDate()
        req.chatRoomId = redPacket.channelId
        req.creatorAddress = Wallet.currentWallet?.address
        return req
    }

    private func dropGiftPacket(completion: @escaping ((Error?, GiftPacketDrop?) -> Void)) {
        let request = reqRedPacket()
        giftPacketCancellable = IdentityService.shared.dropGiftPacket(req: request)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let redPacket):
                    self.bindRedPacketData(packet: redPacket)
                    completion(nil, redPacket)
                case .failure(let error):
                    self.isLoading = false
                    showSnackBar(.error(error))
                    self.handleBtnState(.retry, .retryCancel)
                    completion(error, nil)
                }
            }
    }

    private func topupPacket(response: GiftPacketDrop) {
        guard let amount = redPacket.amount,
              let giftAddress = EthereumAddress(response.data?.poolAddress ?? ""),
              let currentWalletData = OneWalletService.shared.getCurrentUserWalletData(),
              let giftPacketContract = Web3Service.shared.giftPacketContract(at: giftAddress) else {
                  showSnackBar(.somethingWentWrongRandomText)
                  return
              }
        let packetTotalAmount = Web3Service.shared.amountToWeiUnit(
            amount: Double(amount),
            weiUnit: OneWalletService.weiUnit)
        let parameters = [response.hexPacketID, response.signature]  as [AnyObject]
        topupCancellable = OneWalletService.shared.callExternalMethodWithProgress(
            wallet: currentWalletData,
            amount: packetTotalAmount,
            contract: giftPacketContract,
            method: "topupPacket",
            parameters: parameters)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else {
                        return
                    }
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self.didFailTopupPacket(error: error)
                    }
                },
                receiveValue: { [weak self] txProgress in
                    guard let self = self else { return }
                    self.transactionStatusHasChanged(
                        progress: txProgress,
                        currentWallet: currentWalletData.address.address)
                })
    }

    private func transactionStatusHasChanged(progress: OneWalletService.CommitRevealProgress, currentWallet: String) {
        switch progress {
        case .committing, .verifyingCommit, .pendingReveal:
            self.handleBtnState(.cancel, .confirmSendDisable)
        case .revealing:
            self.handleBtnState(.cancelDisable, .confirmSendDisable)
        case .done(txId: let txId):
            self.handleBtnState(.cancelDisable, .confirmSendDisable)
            self.getTxStatus(txId ?? "", walletAddress: currentWallet, isOneTransfer: false) { status in
                if status == .ok {
                    self.isLoading = false
                    self.refreshWalletBalance()
                    hideConfirmationSheet()
                    self.sendRedPacketToChannel()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismissAll()
                        NotificationCenter.default.post(name: .dismissRedPacketViews, object: nil)
                    }
                } else {
                    self.isLoading = false
                    showSnackBar(.walletTransactionFailed)
                    self.handleBtnState(.retry, .retryCancel)
                }
            }
        default:
            break
        }
    }

    private func didFailTopupPacket(error: OneWalletService.CommitRevealError) {
        self.isLoading = false
        if error == .noInternet {
            showSnackBar(.internetConnectionError)
        } else if error == .transactionFail {
            showSnackBar(.walletTransactionFailed)
        } else {
            showSnackBar(.error(error))
        }
        handleBtnState(.retry, .retryCancel)
    }

    /// get transaction status from receipt logs
    private func getTxStatus(_ txID: String, walletAddress: String, isOneTransfer: Bool, status: @escaping ((TransactionReceipt.TXStatus) -> Void)) {
        OneWalletService.shared.getTxStatus(txID, walletAddress: walletAddress, isOneTransfer: isOneTransfer)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure:
                        status(.failed)
                    default:
                        break
                    }
                },
                receiveValue: { txStatus in
                    status(txStatus)
                })
            .store(in: &cancellables)
    }

    private func handleBtnState(_ btn1: ButtonState, _ btn2: ButtonState) {
        btn1State = btn1
        btn2State = btn2
    }

    private func bindRedPacketData(packet: GiftPacketDrop) {
        redPacket.title = packet.data?.title
        redPacket.minWeiAmount = packet.data?.minAmount
        redPacket.maxWeiAmount = packet.data?.maxAmount
        var cardMaxAmount = redPacket.amount ?? 0
        cardMaxAmount = cardMaxAmount - Float((redPacket.participantsCount ?? 0)) + 1
        redPacket.minOne = String(format: "%.1f", cardMaxAmount)
        redPacket.maxOne = String(format: "%.1f", redPacket.amount ?? 0)
        redPacket.endTime = packet.data?.endTime
        redPacket.packetId = packet.data?.id
        redPacket.packetAddress = packet.data?.poolAddress
    }

    private func cancelNetworkCall() {
        giftPacketCancellable?.cancel()
        topupCancellable?.cancel()
    }

    func sendGiftPacket() {
        guard !isLoading else { return }
        isLoading = true
        withAnimation {
            handleBtnState(.cancel, .confirmSendDisable)
        }
        dropGiftPacket { [weak self] error, giftPacket in
            guard let self = self,
                  error == nil,
                  let giftPacket = giftPacket else {
                return
            }
            self.topupPacket(response: giftPacket)
        }
    }

    func cancelTransaction() {
        cancelNetworkCall()
        showSnackBar(.transactionCancelled)
        hideConfirmationSheet()
        isLoading = false
    }

    private func refreshWalletBalance() {
        WalletInfo.shared.refreshWalletData()
    }

    private func sendRedPacketToChannel() {
        guard let strChannelId = redPacket.channelId else {
            showSnackBar(.somethingWentWrongRandomText)
            return
        }
        do {
            let channelId = try ChannelId(cid: strChannelId)
            ChatClient.shared.channelController(for: channelId).createNewMessage(
                    text: "Red Packet",
                    pinning: nil,
                    attachments: [],
                    extraData: ["redPacketPickup": .dictionary(redPacket.toDictionary())],
                    completion: nil)
        } catch {}
    }
}
