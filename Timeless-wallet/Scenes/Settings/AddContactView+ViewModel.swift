//
//  AddContactView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 1/24/22.
//

import Foundation
import SwiftUI
import Combine

extension AddContactView {
    class ViewModel: ObservableObject {
        @UserDefaultCodable(
            key: ASSettings.Contact.contactList.key,
            defaultValue: nil
        )
        var contacts: [ContactModel]?

        var editingContact: ContactModel?
        var preselectedAddress = false

        @Published var name = ""
        @Published var address = ""
        @Published var addressByUser: String?
        @Published var imageUrl: String?
        @Published var isLoading = false
        @Published var checkWalletCancellable: AnyCancellable?
        @Published var isShowNotAvailable = false
        @Published var checkValidate = false
        private var subscriptions = Set<AnyCancellable>()

        init(_ editingContact: ContactModel? = nil) {
            if editingContact != nil {
                self.editingContact = editingContact
                self.name = editingContact?.name ?? ""
                self.address = editingContact?.walletAddress ?? ""
                self.imageUrl = editingContact?.avatar
            }
            initAddressValue()
        }

        init(address: String) {
            self.address = address
            self.preselectedAddress = true
            initAddressValue()
        }
    }
}

struct ContactSectionData: Hashable {
    var sectionName: String
    var data: [ContactModel]
}

extension AddContactView.ViewModel {
    private func initAddressValue() {
        $address
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .sink { [weak self] name in
                guard let weakSelf = self else { return }
                let checkWalletAddress = name.isOneWalletAddress
                if name.isBlank || checkWalletAddress {
                    weakSelf.checkValidate = checkWalletAddress
                    withAnimation(.easeInOut(duration: 0.2)) {
                        weakSelf.isShowNotAvailable = false
                    }
                    return
                }
                withAnimation(.easeInOut(duration: 0.2)) {
                    weakSelf.isShowNotAvailable = true
                }
                weakSelf.checkValidate = false
                weakSelf.checkWalletCancellable = IdentityService.shared.checkWalletTitle(walletName: name)
                    .sink(receiveValue: { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .success(let result):
                            if let available = result.available, !available {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    self.isShowNotAvailable = false
                                }
                                self.checkValidate = true
                                self.addressByUser = result.address
                            }
                        case .failure(let error):
                            showSnackBar(.error(error))
                        }
                    })
            }
            .store(in: &subscriptions)
    }

    func uploadToCloudinary(image: UIImage?) {
        guard let contactImage = image else { return }
        isLoading = true
        CloudinaryService.shared.uploadImage(image: contactImage) { [weak self] imageUrl, error in
            guard let self = self else {
                return
            }
            self.isLoading = false
            guard error == nil, let imageUrl = imageUrl else {
                showSnackBar(.error(error))
                return
            }
            self.imageUrl = imageUrl
        }
    }

    func insertContactList(completion: @escaping (() -> Void)) {
        if editingContact != nil,
           let editingIndex = self.contacts?.firstIndex(of: editingContact!) {
            editingContact?.name = name
            editingContact?.walletAddress = addressByUser != nil ? addressByUser! : address
            editingContact?.avatar = imageUrl
            editingContact?.updated = Date()
            self.contacts?[editingIndex] = editingContact!
            completion()
            return
        }

        if self.contacts == nil {
            var tempModel = [ContactModel]()
            tempModel.append(ContactModel(name: name,
                                          walletAddress: addressByUser != nil ? addressByUser! : address,
                                          avatar: imageUrl,
                                          created: Date(),
                                          updated: Date()))
            self.contacts = tempModel
        } else {
            self.contacts!.append(ContactModel(name: name,
                                            walletAddress: addressByUser != nil ? addressByUser! : address,
                                            avatar: imageUrl,
                                            created: Date(),
                                            updated: Date()))
        }
        completion()
    }
}
