//
//  ProfileModal+ViewModel.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 03/03/2022.
//

import SwiftUI

extension ProfileModal {
    class ViewModel: ObservableObject {
        // MARK: - Variables
        @Published var loadingUploadCloudinary = false
    }
}

extension ProfileModal.ViewModel {
    static let shared = ProfileModal.ViewModel()
}
