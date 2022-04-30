//
//  DaoCreateAndShareView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 02/02/22.
//

import UIKit
import StreamChat
import StreamChatUI
import web3swift
import Combine

extension DaoCreateAndShareView {
    class ViewModel: ObservableObject {
        // MARK: - Variables
        var daoModel: CreateDaoModel
        var hashTagSpacing = 5.0
        @Published var isLoading = false
        var cancellables = Set<AnyCancellable>()

        // MARK: - Init
        init(_ daoModel: CreateDaoModel) {
            self.daoModel = daoModel
            self.daoModel.expireDate = Date().withAddedHours(hours: 48)
            self.daoModel.masterWalletAddress = MultisigService.shared.gnosisSafeProxyFactoryAddress
        }
    }
}

// MARK: - Computed
extension DaoCreateAndShareView.ViewModel {
    var daoTrimmedAddress: String {
        return (daoModel.masterWalletAddress?.address ?? "").convertToWalletAddress().trimStringByCount(count: 10)
    }
    var imageRatio: CGFloat {
        return (UIScreen.main.bounds.width * 175) / 375
    }
}

// MARK: - Functions
extension DaoCreateAndShareView.ViewModel {
    func createSafe() {
        let groupId = String(UUID().uuidString)
        callCreateSafe(chatRoomId: groupId) { [weak self] safeAddress in
            guard let self = self, let safeAddress = safeAddress?.address else {
                showSnackBar(.errorMsg(text: "Error when creating safe"))
                return
            }
            self.createDaoChatGroup(groupId: groupId, safeAddress: safeAddress)
        }
    }

    private func createDaoChatGroup(groupId: String, safeAddress: String) {
        daoModel.chatExtraData(groupId: groupId, safeAddress: safeAddress) { [weak self] extraData in
            guard let self = self,
                  let extraData = extraData else {
                return
            }
            do {
                self.isLoading = true
                let channelController = try ChatClient.shared.channelController(
                    createChannelWithId: .init(type: .dao, id: groupId),
                    name: self.daoModel.daoName ?? "-",
                    members: Set(self.daoModel.signers.compactMap { $0.walletAddress?.address }),
                    extraData: extraData)
                channelController.synchronize { [weak self] error in
                    self?.isLoading = false
                    guard error == nil, let self = self else {
                        showSnackBar(.errorMsg(text: "Error when creating the channel"))
                        return
                    }
                    showSnackBar(.message(text: "Safe created successfully."))
                    self.navigateToChatScreen(channelController)
                }
            } catch {
                self.isLoading = false
                showSnackBar(.errorMsg(text: "Error when creating the channel"))
            }
        }
    }

    private func callCreateSafe(chatRoomId: String, completion: @escaping ((EthereumAddress?) -> Void)) {
        guard let walletData = OneWalletService.shared.getCurrentUserWalletData() else {
            return
        }
        isLoading = true
        let owners: [EthereumAddress] = daoModel.signers.compactMap { $0.walletAddress}
        MultisigService.shared.createSafe(
            wallet: walletData,
            owners: owners,
            threshold: daoModel.threshold ?? 0,
            chatRoomId: chatRoomId,
            metadata: daoModel.getMetadata())
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] complete in
                guard let self = self else {
                    return
                }
                switch complete {
                case .failure(let error):
                    self.isLoading = false
                    showSnackBar(.error(error))
                    completion(nil)
                case .finished:
                    self.isLoading = false
                }
            }, receiveValue: { safeAddress in
                completion(safeAddress)
            })
            .store(in: &cancellables)
    }

    private func navigateToChatScreen(_ controller: ChatChannelController) {
        // dismiss views
        dismissAll()
        TabBarView.ViewModel.shared.selectedTab = 2
        // add welcome message
        var extraData = [String: RawJSON]()
        var signers: [RawJSON] = []
        signers = daoModel.signers.map({
            var signer: [String: RawJSON] = [:]
            signer["signerName"] = .string($0.walletName ?? "")
            signer["signerUserId"] = .string($0.walletAddress?.address ?? "")
            return .dictionary(signer)
        })
        extraData["adminMessage"] = .array(signers)
        controller.createNewMessage(
            text: "",
            pinning: nil,
            attachments: [],
            extraData: ["adminMessage": .dictionary(extraData),
                        "messageType": .string("daoAddInitialSigners")],
            completion: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let controller = ChatClient.shared.channelController(
                for: .init(
                    type: .privateMessaging,
                    id: controller.cid?.id ?? ""))
            var userInfo = [AnyHashable: Any]()
            userInfo["channelController"] = controller
            NotificationCenter.default.post(name: .pushToDaoChatMessageScreen, object: nil, userInfo: userInfo)
        }
    }
}
