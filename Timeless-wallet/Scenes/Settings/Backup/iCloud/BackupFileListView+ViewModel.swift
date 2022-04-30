//
//  BackupFileListView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 10/01/2022.
//

import Foundation
import FilesProvider

extension BackupFileListView {
    class ViewModel: ObservableObject {
        @Published var backupFiles: [FileObject]
        @Published var selectedFile: FileObject

        init(backupFiles: [FileObject]) {
            self.backupFiles = backupFiles
            // Ensure the backup files exists before showing this screen
            let currentBackupFile = UserDefaults.standard.string(forKey: ASSettings.Backup.currentBackupFilePath.key)
            self.selectedFile = backupFiles.first { $0.path == currentBackupFile } ?? backupFiles.first!
        }
    }
}

extension BackupFileListView.ViewModel {
    func restore(_ file: FileObject) {
        hideConfirmationSheet()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            present(RestoreICloudBackupView(file: file))
        }
    }
}
