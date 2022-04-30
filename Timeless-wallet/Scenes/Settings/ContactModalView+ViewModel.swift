//
//  ContactModalView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 03/12/21.
//

import Combine
import StreamChat
import StreamChatUI
import SwiftUI

extension ContactModalView {
    class ViewModel: ObservableObject {
        @UserDefaultCodable(
            key: ASSettings.Contact.contactList.key,
            defaultValue: nil
        )
        var contacts: [ContactModel]?
        var screenType: ScreenType
        @Published var searchingText: String = ""
        @Published var sectionData: [ContactSectionData]?
        @Published var searchedResults: [ContactSectionData]?
        @Published var isLoading = false
        @Published var onlineContactsCount: Int?
        // MARK: - Variables
        private var currentNetworkCalls = Set<AnyCancellable>()
        private(set) var searchingCancellable: AnyCancellable?
        var oneWallet = SendOneWallet()
        var pushPaymentView: (() -> Void)?
        var contactUids: [String] = []
        var getStreamUsersUids: [String] = []

        init(screenType: ScreenType) {
            self.screenType = screenType
            searchingCancellable = AnyCancellable(
                $searchingText
                    .debounce(for: 0.3, scheduler: DispatchQueue.global())
                    .removeDuplicates()
                    .sink { text in self.search(for: text) }
            )
            self.sortData()
        }
    }
}

// MARK: - enum
extension ContactModalView.ViewModel {
    enum ScreenType {
        case send
        case contact
        case addSigner
    }
}

extension ContactModalView.ViewModel {
    // MARK: - Functions
    func sendOneWalletTapAction(_ userInfo: [AnyHashable: Any]) {
        guard let channelId = userInfo["channelId"] as? ChannelId else {
            return
        }
        let channelController = ChatClient.shared.channelController(for: channelId)
        let memberListController = channelController.client.memberListController(query: .init(cid: channelId))
        memberListController.synchronize { [weak self] error in
            guard error == nil, let weakSelf = self else { return }
            let chatMembers = memberListController.members.filter({ (member: ChatChannelMember) -> Bool in
                return member.id != memberListController.client.currentUserId
            })
            if chatMembers.count > 1 {
                // more than 2 people including me
            } else {
                //1-1 chat
                weakSelf.handleOneToOneChat(members: chatMembers)
            }
        }
    }

    func handleOneToOneChat(members: [ChatChannelMember]) {
        guard let recipient = members.first else {
            return
        }
        bindWalletData(recipient)
        pushPaymentView?()
    }

    func bindWalletData(_ recipient: ChatChannelMember) {
        oneWallet.myName = ChatClient.shared.currentUserController().currentUser?.name
        oneWallet.myWalletAddress = ChatClient.shared.currentUserId
        oneWallet.recipientName = recipient.name
        oneWallet.recipientAddress = recipient.id
        oneWallet.recipientImageUrl = recipient.imageURL
        oneWallet.myImageUrl = ChatClient.shared.currentUserController().currentUser?.imageURL
    }

    func sortData() {
        self.isLoading = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let weakSelf = self else { return }
            guard weakSelf.contacts != nil else {
                DispatchQueue.main.async {
                    weakSelf.sectionData = []
                    weakSelf.contactUids = []
                    weakSelf.isLoading = false
                }
                return
            }
            var dataSort = weakSelf.contacts!
            weakSelf.contactUids = dataSort.map { $0.walletAddress }
            var countSymbol = 0
            var sectionList: [String] = []
            var sectionData: [ContactSectionData] = []
            for index in 0 ..< dataSort.count {
                if !String(dataSort[index].name.prefix(1)).isAlphabet {
                    countSymbol += 1
                }
            }
            dataSort = dataSort.sorted { $0.name < $1.name }
            if !dataSort.isEmpty && countSymbol != dataSort.count {
                while !String(dataSort[0].name.prefix(1)).isAlphabet {
                    for (index, item) in dataSort.enumerated() where !String(item.name.prefix(1)).isAlphabet {
                        let element = dataSort.remove(at: index)
                        dataSort.insert(element, at: dataSort.count)
                        break
                    }
                }
            }
            for item in dataSort where !sectionList.contains(String(item.name.prefix(1).uppercased())) {
                sectionList.append(String(item.name.prefix(1).uppercased()))
            }
            for (index, item) in sectionList.enumerated() where !item.isAlphabet {
                sectionList.removeSubrange(index...sectionList.count - 1)
                sectionList.append("#")
                break
            }
            for index in 0 ..< sectionList.count {
                sectionData.append(ContactSectionData(sectionName: sectionList[index], data: []))
                for idx in 0 ..< dataSort.count {
                    if sectionData[index].sectionName.isAlphabet {
                        if sectionData[index].sectionName == dataSort[idx].name.prefix(1).uppercased() {
                            sectionData[index].data.append(dataSort[idx])
                        }
                    } else if !String(dataSort[idx].name.prefix(1)).isAlphabet {
                        sectionData[index].data.append(dataSort[idx])
                    }
                }
            }
            DispatchQueue.main.async {
                weakSelf.sectionData = sectionData
                weakSelf.isLoading = false
                weakSelf.getContactActiveStatus()
            }
        }
    }

    func deleteContact(_ contact: ContactModel) {
        guard self.contacts != nil else {
            return
        }
        if let index = self.contacts!.firstIndex(where: { $0 == contact }) {
            self.contacts!.remove(at: index)
            sortData()
        }
    }

    private func fetchMyWalletAddress() -> String? {
        return Wallet.currentWallet?.address
    }

    private func search(for keySearch: String) {
        guard !keySearch.isBlank,
              !(self.sectionData?.isEmpty ?? false) else {
                  DispatchQueue.main.async {
                      self.searchedResults = nil
                  }
                  return
              }
        let keySearch = keySearch.lowercased()
        var result = [ContactSectionData]()
        var temp = self.sectionData ?? []
        for index in 0...temp.count - 1 {
            let filteredItems = temp[index].data.filter {
                ($0.name.lowercased().contains(keySearch) || $0.walletAddress.lowercased().contains(keySearch))
                && getStreamUsersUids.contains($0.walletAddress)
            }
            if !filteredItems.isEmpty {
                temp[index].data = filteredItems
                result.append(temp[index])
            }
        }
        DispatchQueue.main.async {
            self.searchedResults = result
        }
    }

    func getContactActiveStatus() {
        let controller = ChatClient.shared.userListController(query: .init(filter: .in(.id, values: contactUids )))
        controller.synchronize { [weak self] error in
            guard let self = self else {
                return
            }
            if error == nil {
                withAnimation {
                    self.onlineContactsCount = controller.users.filter({ $0.isOnline }).count
                }
                self.getStreamUsersUids = controller.users.map { $0.id }
            }
        }
    }
}
