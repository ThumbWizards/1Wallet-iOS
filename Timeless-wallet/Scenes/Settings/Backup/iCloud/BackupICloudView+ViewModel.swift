//
//  File.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 17/11/2021.
//

import Foundation
import FilesProvider
import SwiftUI
import Combine

extension BackupICloudView {
    class ViewModel: ObservableObject {
        @AppStorage(ASSettings.Backup.currentBackupFilePath.key)
        var currentBackupFilePath = ASSettings.Backup.currentBackupFilePath.defaultValue
        @AppStorage(ASSettings.General.appSetupState.key)
        private var appSetupState = ASSettings.General.appSetupState.defaultValue
        @Published var isLoading = false
        var dismissCancellable: AnyCancellable?
    }
}

extension BackupICloudView.ViewModel {
    func restoreBackup(file: FileObject, backupPassword: String, incorrectPass: @escaping (() -> Void)) {
        isLoading = true
        Backup.shared.appData(of: file.path, backupPassword: backupPassword) { [weak self] appData, error in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                if error != nil || appData == nil {
                    self.isLoading = false
                    if let err = error {
                        showSnackBar(err.code == 3 ? .errorMsg(text: "Incorrect password. Retry") : .error(err))
                        incorrectPass()
                    } else {
                        showSnackBar(.error(error))
                    }

                } else {
                    self.isLoading = false
                    self.dismissCancellable = dismiss()?.sink(receiveValue: { _ in
                        showConfirmation(.restoringBackupView(appData: appData!,
                                                              backupFile: file,
                                                              backupPassword: backupPassword),
                                         interactiveHide: false)
                    })
                }
            }
        }
    }

    func newBackup(backupPassword: String) {
        if Backup.shared.setBackupPassword(backupPassword) == errSecSuccess {
            Backup.shared.sync { [weak self] error in
                guard let self = self else {
                    return
                }
                DispatchQueue.main.async {
                    self.appSetupState = ASSettings.AppSetupState.done.rawValue
                    dismiss()
                    showSnackBar(.backupCompleted)
                }
            }
        } else {
            showSnackBar(.error())
        }
    }
}
extension BackupICloudView.ViewModel {
    static var shared = BackupICloudView.ViewModel()
}
