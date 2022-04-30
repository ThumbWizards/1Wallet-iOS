//
//  TabbarViewModel+GiftPacket.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 28/03/22.
//

import UIKit
import web3swift
import BigInt
import GetStream
import StreamChatUI
import StreamChat

// MARK: - gift card
extension TabBarView.ViewModel {
    func observeGiftPacket() {
        NotificationCenter.default.removeObserver(self, name: .sendGiftPacketTapAction, object: nil)
        NotificationCenter.default.removeObserver(self, name: .pickUpGiftPacket, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sendGiftPacketTapAction(_:)),
            name: .sendGiftPacketTapAction,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(pickupGiftPacket(_:)),
            name: .pickUpGiftPacket,
            object: nil)
    }

    private func bindRedPacket(channelUsers: Int, cid: ChannelId) {
        redPacket.myName = ChatClient.shared.currentUserController().currentUser?.name
        redPacket.myWalletAddress = ChatClient.shared.currentUserId
        redPacket.myImageUrl = ChatClient.shared.currentUserController().currentUser?.imageURL
        redPacket.channelUsers = channelUsers
        redPacket.channelId = cid.description
    }

    @objc private func sendGiftPacketTapAction(_ notification: NSNotification) {
        guard NetworkHelper.shared.reachability?.connection != Reachability.Connection.none else {
            showSnackBar(.internetConnectionError)
            return
        }
        guard let channelId = notification.userInfo?["channelId"] as? ChannelId else {
            return
        }
        let controller = ChatClient.shared.memberListController(query: .init(cid: channelId))
        controller.synchronize { [weak self] error in
            guard error == nil, let weakSelf = self else { return }
            let chatMembers = controller.members.filter({ (member: ChatChannelMember) -> Bool in
                return member.id != controller.client.currentUserId
            })
            guard !chatMembers.isEmpty else {
                showSnackBar(.message(text: "Channel must contain more than one user to enable GiftPacket feature"))
                return
            }
            weakSelf.handleGiftPacketChat(members: chatMembers, cid: channelId)
        }
    }

    private func handleGiftPacketChat(members: [ChatChannelMember], cid: ChannelId) {
        bindRedPacket(channelUsers: members.count, cid: cid)
        let paymentVC = SendPaymentVC(redPacket: redPacket)
        present(paymentVC, animated: true)
    }

    @objc private func pickupGiftPacket(_ notification: NSNotification) {
        guard let extraData = notification.userInfo as? [String: RawJSON],
              let packetId = extraData.redPacketID else {
            return
        }
        UIApplication.shared.getTopViewController()?.displayAnimatedActivityIndicatorView()
        IdentityService.shared.claimGiftPacket(packetId: packetId)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    UIApplication.shared.getTopViewController()?.hideAnimatedActivityIndicatorView()
                    if error == .packetNotExist {
                        showSnackBar(.errorMsg(text: "Packet does not exist"))
                    } else if error == .packetExpired {
                        showSnackBar(.redPacketExpiredRandomText)
                    } else if error == .packetFullyClaimed {
                        showSnackBar(.redPacketMissedRandomText)
                    } else if error == .noInternet {
                        showSnackBar(.internetConnectionError)
                    } else {
                        showSnackBar(.somethingWentWrongRandomText)
                    }
                default:
                    break
                }
            }, receiveValue: { value in
                self.claimGiftPacket(response: value, extraData: extraData)
            })
            .store(in: &currentNetworkCalls)
    }

    private func giftPacketClaimed(packetId: String, claimId: String, txId: String) {
        let req = ReqGiftCardClaimed()
        req.walletAddress = Wallet.currentWallet?.address
        req.claimId = claimId
        req.txId = txId

        IdentityService.shared.claimGiftPacketSuccessful(req: req, packetId: packetId)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: RunLoop.main)
            .sink { _ in
            }
            .store(in: &currentNetworkCalls)
    }

    // swiftlint:disable function_body_length
    private func claimGiftPacket(response: ClaimGiftPacket, extraData: [String: RawJSON]) {
        guard let giftAddress = EthereumAddress(response.data?.packetAddress ?? ""),
              let giftPacketContract = Web3Service.shared.giftPacketContract(at: giftAddress),
              let hexPacketId = response.hexPacketID,
              let signature = response.signature,
              let amount = BigUInt(response.data?.amount ?? ""),
              let currentWalletData = OneWalletService.shared.getCurrentUserWalletData() else {
                  UIApplication.shared.getTopViewController()?.hideAnimatedActivityIndicatorView()
                  return
              }
        let parameter = [hexPacketId, amount, signature] as [AnyObject]
        OneWalletService.shared.callExternalMethodWithProgress(
            wallet: currentWalletData,
            amount: 0,
            contract: giftPacketContract,
            method: "claimPacket",
            parameters: parameter)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        UIApplication.shared.getTopViewController()?.hideAnimatedActivityIndicatorView()
                    case .failure:
                        UIApplication.shared.getTopViewController()?.hideAnimatedActivityIndicatorView()
                        showSnackBar(.somethingWentWrongRandomText)
                    }
                },
                receiveValue: { [weak self] txProgress in
                    guard let self = self else {
                        return
                    }
                    switch txProgress {
                    case .done(txId: let txId):
                        self.getTxStatus(txId ?? "",
                            walletAddress: currentWalletData.address.address,
                            isOneTransfer: false) { [weak self] txStatus in
                                guard let self = self else {
                                    return
                                }
                                switch txStatus {
                                case .ok:
                                    showSnackBar(.redPacketClaimed)
                                    self.giftPacketClaimed(
                                        packetId: response.data?.packetID ?? "",
                                        claimId: response.data?.id ?? "",
                                        txId: txId ?? "")
                                case .failed:
                                    showSnackBar(.message(text: "gift packet claim failed!"))
                                case .notYetProcessed:
                                    showSnackBar(.message(text: "gift packet claim failed!"))
                                }
                            }
                    default:
                        break
                    }
                })
            .store(in: &currentNetworkCalls)
    }

    private func getTxStatus(
        _ txID: String,
        walletAddress: String,
        isOneTransfer: Bool,
        status: @escaping ((TransactionReceipt.TXStatus) -> Void)) {
        OneWalletService.shared.getTxStatus(
            txID,
            walletAddress: walletAddress,
            isOneTransfer: isOneTransfer)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure:
                        status(.failed)
                    }
                },
                receiveValue: { txStatus in
                    status(txStatus)
                })
            .store(in: &currentNetworkCalls)
    }
}
