//
//  RestoringBackupView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 12/01/2022.
//

import SwiftUI
import FilesProvider

extension RestoringBackupView {
    class ViewModel: ObservableObject {
        @AppStorage(ASSettings.Backup.currentBackupFilePath.key)
        var currentBackupFilePath = ASSettings.Backup.currentBackupFilePath.defaultValue
        @AppStorage(ASSettings.General.appSetupState.key)
        private var appSetupState = ASSettings.General.appSetupState.defaultValue

        var appData: AppData
        var backupFile: FileObject
        var backupPassword: String

        init(appData: AppData, backupFile: FileObject, backupPassword: String) {
            self.appData = appData
            self.backupFile = backupFile
            self.backupPassword = backupPassword
        }
    }
}

extension RestoringBackupView.ViewModel {
    func restore() {
        // We have to clean up all of the exist data first before restoring
        // It means we need to make sure that the user has been backed up their data first to avoid losing wallet data
        if Backup.shared.backupFromSettings {
            IdentityService.shared.logout()
        }

        // Restore start
        appData.restore()
        currentBackupFilePath = backupFile.path
        _ = Backup.shared.setBackupPassword(backupPassword)

        // Restore completed, refresh app state
        hideConfirmationSheet()
        appSetupState = ASSettings.AppSetupState.done.rawValue
        CryptoHelper.shared.viewModel.onboardWalletState = .imported
        showSnackBar(.restoreCompleted)
    }
}
