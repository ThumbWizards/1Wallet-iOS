//
//  Backup.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 03/11/2021.
//
import Foundation
import FilesProvider
import CryptoKit

class Backup {
    enum BackupError: Error {
        case missingBackupPassword
    }

    static var shared = Backup()

    static let queue = "Backup"

    static let backupFolder = "appBackup"

    @UserDefault(
        key: ASSettings.Backup.currentBackupFilePath.key,
        defaultValue: ASSettings.Backup.currentBackupFilePath.defaultValue
    )
    var currentBackupFilePath: String // Cache the backup file path to sync automatically in the future

    @UserDefault(
        key: ASSettings.General.appSetupState.key,
        defaultValue: ASSettings.General.appSetupState.defaultValue
    )
    var appSetupState: String

    @UserDefault(
        key: ASSettings.Backup.ubiquityIdentityToken.key,
        defaultValue: ASSettings.Backup.ubiquityIdentityToken.defaultValue
    )
    var ubiquityIdentityToken: Any

    var documentsProvider: CloudFileProvider?
    var backupFromSettings = false

    // iCloud provider could not run on the main thread
    func execute(requiredAuthentication: Bool = true, callback: @escaping (CloudFileProvider) -> Void) {
        func handler() {
            DispatchQueue(label: Backup.queue).async { [weak self] in
                guard let `self` = self else { return }
                if let iCloudToken = FileManager.default.ubiquityIdentityToken {
                    self.ubiquityIdentityToken = iCloudToken
                    if self.documentsProvider == nil {
                        self.documentsProvider = CloudFileProvider(containerId: AppConstant.iCloudContainerId)
                    }
                    if self.documentsProvider != nil {
                        callback(self.documentsProvider!)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.resetBackupState()
                        showSnackBar(.errorMsg(text: "Unable to connect with iCloud."))
                    }
                }
            }
        }
        if requiredAuthentication {
            Lock.shared.requireAuthetication { isAuthenticated in
                guard isAuthenticated else {
                    return
                }
                handler()
            }
        } else {
            handler()
        }
    }

    var backupPassword: Data? {
        return KeyChain.shared.retrieve(key: .backupPassword)
    }

    func setBackupPassword(_ password: String) -> OSStatus {
        return KeyChain.shared.store(key: .backupPassword, data: password.data(using: .utf8)!.sha256Data)
    }

    func loadAllBackupFiles(completionHandler: @escaping (_ files: [FileObject], _ error: Error?) -> Void) {
        execute(requiredAuthentication: false) { documentsProvider in
            documentsProvider.contentsOfDirectory(path: Backup.backupFolder,
                                                  completionHandler: completionHandler)
        }
    }

    func loadLatestBackupFile(completionHandler: @escaping (_ file: FileObject?, _ error: Error?) -> Void) {
        loadAllBackupFiles { files, error in
            completionHandler(files.max(by: {
                $0.modifiedDate ?? $0.creationDate ?? Date() > $1.modifiedDate ?? $1.creationDate ?? Date()
            }),
                              error)
        }
    }

    func deleteAllBackupFiles(completionHandler: SimpleCompletionHandler) {
        execute { [weak self] documentsProvider in
            guard let self = self else {
                return
            }
            documentsProvider.removeItem(path: Backup.backupFolder) { error in
                // We need to reset icloud prodiver once remove anything to avoid crashing when the old provider is still caching some out date data
                self.documentsProvider = CloudFileProvider(containerId: AppConstant.iCloudContainerId)
                if error == nil {
                    DispatchQueue.main.async {
                        self.currentBackupFilePath = ""
                    }
                }
                completionHandler?(error)
            }
        }
    }

    func deleteBackupFile(file: FileObject, completionHandler: SimpleCompletionHandler) {
        execute { [weak self] documentsProvider in
            guard let self = self else {
                return
            }
            documentsProvider.removeItem(path: file.path) { error in
                // We need to reset icloud prodiver once remove anything to avoid crashing when the old provider is still caching some out date data
                self.documentsProvider = CloudFileProvider(containerId: AppConstant.iCloudContainerId)
                if error == nil, file.path == self.currentBackupFilePath {
                    DispatchQueue.main.async {
                        self.currentBackupFilePath = ""
                    }
                }
                completionHandler?(error)
            }
        }
    }

    func sync(newBackup: Bool = true, successCallback: SimpleCompletionHandler) {
        execute(requiredAuthentication: newBackup) { [weak self] documentsProvider in
            guard let self = self else {
                return
            }
            // The backup password has to be stored in the keychain first.
            // We will use this one to encrypt the backup data automatically in the future
            guard let backupPassword = self.backupPassword else {
                successCallback?(BackupError.missingBackupPassword)
                return
            }
            var currentBackupFilePath = self.currentBackupFilePath
            if currentBackupFilePath.isEmpty || newBackup {
                // Todo: make backup file name more descriptive
                currentBackupFilePath = "/\(Backup.backupFolder)/\(Date().timeIntervalSince1970).backup"
            }

            let appData = AppData(keyChainVersion: KeyChain.latestVersion,
                                  allWallets: Wallet.allWallets,
                                  allWalletSeeds: Wallet.allWalletSeeds,
                                  allEffectiveTimes: Wallet.allEffectiveTimes,
                                  allWalletSignaturesV1: Wallet.allWalletSignatures,
                                  allStreamChatAccessTokens: Wallet.allStreamChatAccessTokens)

            // Encypt the data with the backup password
            // It means if the user want to restore this backup, they have to enter the password again to decrypt the data
            do {
                let encryptedData = try ChaChaPoly
                    .seal(try JSONEncoder().encode(appData),
                          using: SymmetricKey(data: backupPassword))
                documentsProvider.create(folder: Backup.backupFolder,
                                         at: "/") {[weak self] error in
                    guard let `self` = self else { return }
                    if error == nil {
                        documentsProvider.writeContents(path: currentBackupFilePath,
                                                        contents: encryptedData.combined,
                                                        atomically: false,
                                                        overwrite: true) { error in
                            if error == nil, self.currentBackupFilePath.isEmpty {
                                DispatchQueue.main.async {
                                    self.currentBackupFilePath = currentBackupFilePath
                                }
                            }
                            successCallback?(error)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.resetBackupState()
                            showSnackBar(.error(error))
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.resetBackupState()
                    showSnackBar(.error(error))
                }
            }
        }
    }

    func resetBackupState() {
        self.currentBackupFilePath = ""
        self.appSetupState = ASSettings.AppSetupState.backup.rawValue
    }

    func appData(of path: String, backupPassword: String, completionHandler: @escaping ((AppData?, Error?) -> Void)) {
        execute { documentsProvider in
            documentsProvider.contents(path: path,
                                       completionHandler: { contents, iError in
                guard let contents = contents else {
                    completionHandler(nil, iError)
                    return
                }
                // Decrypt the data with the password which has been entered by the user
                // We will not use the cached backup password from from key chain for this case, always required user to enter their password to make it more security
                // swiftlint:disable force_try
                let sealedBoxRestored = try! ChaChaPoly.SealedBox(combined: contents)
                do {
                    let decryptedData = try ChaChaPoly
                        .open(sealedBoxRestored,
                              using: SymmetricKey(data: backupPassword.data(using: .utf8)!.sha256Data))
                    completionHandler(try! JSONDecoder().decode(AppData.self, from: decryptedData), iError)
                } catch {
                    completionHandler(nil, error)
                }
            })
        }
    }

    func showBackupFileListView() {
        loadAllBackupFiles { [weak self] files, error in
            guard self != nil else {
                return
            }
            guard error == nil else {
                DispatchQueue.main.async {
                    showSnackBar(.error(error))
                }
                return
            }
            guard !files.isEmpty else {
                DispatchQueue.main.async {
                    showSnackBar(.backupDoesNotExist)
                }
                return
            }
            var latestFile: FileObject?
            var backupFiles: [FileObject] = []
            // Show all of the backup files in the setting flow
            if files.count == 1, let file = files.first {
                latestFile = file
            } else {
                backupFiles = files.sorted {
                    $0.modifiedDate ?? $0.creationDate ?? Date() > $1.modifiedDate ?? $1.creationDate ?? Date()
                }

            }
            DispatchQueue.main.async {
                if let file = latestFile {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        present(RestoreICloudBackupView(file: file))
                    }
                } else {
                    showConfirmation(.backupFileList(backupFiles: backupFiles))
                }
            }
        }
    }
}
