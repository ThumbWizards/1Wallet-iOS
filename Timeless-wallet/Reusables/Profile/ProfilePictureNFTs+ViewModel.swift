//
//  ProfilePictureNFTs+ViewModel.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 2/11/22.
//

import SwiftUI

enum ConnectStatus {
    case noconnect
    case connected
}

extension ProfilePictureNFTsModal {
    class ViewModel: ObservableObject {
        @Published var connectStatus: ConnectStatus = .noconnect
        static let shared = ViewModel()
    }
}
