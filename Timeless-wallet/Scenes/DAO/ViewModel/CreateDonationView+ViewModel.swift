//
//  CreateDonationView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 26/01/22.
//

import SwiftUI

extension CreateDonationView {
    class ViewModel: ObservableObject {
        // MARK: - Variables
        let maxDaoNameChar = 40
        let maxDaoDescChar = 100
        var daoModel = CreateDaoModel()
        var placeholder: String?
        @Published var isDiscoverable = true
        @Published var daoName = ""
        @Published var daoDesc = ""
        // swiftlint:disable line_length
        @Published var charityThumb = "https://res.cloudinary.com/timeless/image/upload/v1643962926/1wallet_profile_avatar/gwyglazehb9vllle1sou.jpg"

        // MARK: - Init
        init(placeholder: String) {
            self.placeholder = placeholder
        }
    }
}

// MARK: - Computed
extension CreateDonationView.ViewModel {
    var remainingDaoNameChar: String {
        return "\(abs(maxDaoNameChar - (maxDaoNameChar - daoName.count)))/\(maxDaoNameChar)"
    }
    var remainingDaoDescChar: String {
        return "\(abs(maxDaoDescChar - (maxDaoDescChar - daoDesc.count)))/\(maxDaoDescChar)"
    }
}

// MARK: - Functions
extension CreateDonationView.ViewModel {
    func bindDaoData() {
        daoModel.daoName = daoName
        daoModel.description = daoDesc
        daoModel.isDiscoverable = isDiscoverable
        daoModel.charityThumb = charityThumb
    }

    func isValidate() -> Bool {
        if !daoName.isEmpty
            && !charityThumb.isEmpty
            && !daoDesc.isEmpty {
            return true
        } else {
            return false
        }
    }
}
