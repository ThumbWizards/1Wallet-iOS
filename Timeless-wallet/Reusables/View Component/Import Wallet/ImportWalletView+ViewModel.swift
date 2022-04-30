//
//  ImportWalletView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 16/11/2021.
//

import Foundation
import SwiftUI
import SwiftMessages

extension ImportWalletView {
    class ViewModel: ObservableObject {
    }
}

extension ImportWalletView.ViewModel {
    func restoreFromIcloud() {
        hideConfirmationSheet()
        Backup.shared.showBackupFileListView()
    }
}
