//
//  ManageICloudBackupView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 05/11/2021.
//

import SwiftUI
import SwiftUIX
import SwiftMessages

struct ManageICloudBackupView: View {
    @ObservedObject private var viewModel = BackupICloudView.ViewModel.shared
}

// MARK: - Body view
extension ManageICloudBackupView {
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: .infinity)
                .frame(width: 40, height: 5)
                .foregroundColor(Color.swipeBar)
                .padding(.top, 12)
                .padding(.bottom, 35)
            Image.backUpLock
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 43)
                .padding(.bottom, 28)
            Text("Manage Backups")
                .tracking(-0.1)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.white)
                .padding(.bottom, 12)
            HStack(spacing: 0) {
                Text("Your wallet was securely backed up.\nYou can either try restoring from backup or")
                    .tracking(-0.2)
                + Text(" permanently ")
                    .tracking(-0.2)
                    .foregroundColor(Color.timelessRed)
                + Text("remove them from iCloud.")
                    .tracking(-0.2)
            }
            .lineSpacing(5)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            .foregroundColor(Color.subtitleConfirmationSheet)
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, 60)
            Spacer()
            Button(action: {
                hideConfirmationSheet()
                Backup.shared.backupFromSettings = true
                Backup.shared.showBackupFileListView()
            }) {
                RoundedRectangle(cornerRadius: .infinity)
                    .frame(height: 41)
                    .foregroundColor(Color.confirmationSheetCancelBG)
                    .padding(.horizontal, 39)
                    .overlay(
                        Text("Restore from iCloud Backups")
                            .tracking(-0.4)
                            .font(.system(size: 18))
                            .foregroundColor(Color.confirmationSheetCancelBtn)
                    )
            }
            .padding(.bottom, 11)
            Button(action: { onTapDelete() }) {
                RoundedRectangle(cornerRadius: .infinity)
                    .frame(height: 41)
                    .foregroundColor(Color.confirmationSheetCancelBG)
                    .padding(.horizontal, 39)
                    .overlay(
                        Text("Delete All iCloud Backups")
                            .tracking(-0.4)
                            .font(.system(size: 18))
                            .foregroundColor(Color.confirmationSheetCancelBtn)
                    )
            }
            .padding(.bottom, 45)
        }
        .height(440)
    }
}

// MARK: - Methods
extension ManageICloudBackupView {
    private func onTapDelete() {
        hideConfirmationSheet()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let controller = UIAlertController(
                title: "",
                message: "Are you sure you want to permanently remove your iCloud wallet backups?",
                preferredStyle: .actionSheet
            )

            controller.addAction(
                UIAlertAction(
                    title: "Yes, Permanently Remove",
                    style: .destructive,
                    handler: { _ in
                        Backup.shared.deleteAllBackupFiles { error in
                            DispatchQueue.main.async {
                                if error != nil {
                                    showSnackBar(.error(error))
                                }
                            }
                        }
                    }
                )
            )

            controller.addAction(
                UIAlertAction(
                    title: "Cancel",
                    style: .cancel,
                    handler: { _ in
                        controller.dismiss()
                    }
                )
            )

            present(controller)
        }
    }
}
