//
//  BackupFileListView.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 10/01/2022.
//

import SwiftUI
import FilesProvider

struct BackupFileListView {
    @ObservedObject var viewModel: ViewModel
}

// MARK: - Body view
extension BackupFileListView: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                headerView
                listBackupFiles
            }
            .height(480)
            buttonClose
        }
    }
}

extension BackupFileListView {
    private var headerView: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Choose a Backup")
                    .tracking(-0.3)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(Color.white)
                Text("Restore your account settings")
                    .font(.system(size: 14))
                    .foregroundColor(Color.white.opacity(0.7))
                    .padding(.top, 12)
            }
            Spacer()
        }
        .padding(.top, 36.33)
        .padding(.horizontal, 21.5)
        .padding(.bottom, 17)
    }

    private var listBackupFiles: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 9.5) {
                ForEach(viewModel.backupFiles, id: \.hashIdentifiable) { file in
                    Button(action: {
                        withAnimation(.easeInOut) {
                            viewModel.selectedFile = file
                            viewModel.restore(file)
                        }
                    }) {
                        HStack {
                            backupFileIcon(file: file)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(file.name.trimStringByCount(count: 14))
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.white87)
                                    .lineLimit(1)
                                // swiftlint:disable line_length
                                Text("backup date: \(Formatters.Date.MMMdyyyy.string(from: file.modifiedDate ?? file.creationDate ?? Date()))")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.white60)
                            }
                            Spacer()
                            Image.checkmark
                                .font(.system(size: 12))
                                .foregroundColor(Color.checkMarkAccount)
                                .opacity(viewModel.selectedFile == file ? 1 : 0)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        // Todo: remove hardcode Color, apply to whole app
                        .background(Color.keyboardAccessoryBG)
                        .cornerRadius(10)
                        .overlay(viewModel.selectedFile == file ?
                                 RoundedRectangle(cornerRadius: 8).stroke(Color.checkMarkAccount,
                                                                          lineWidth: 1)
                                    .eraseToAnyView() :
                                    EmptyView().eraseToAnyView())
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.top, 15)
            .padding(.bottom, 46)
        }
    }

    private var buttonClose: some View {
        Button(action: { onTapClose() }) {
            Image.closeSmall
                .resizable()
                .frame(width: 25, height: 25)
        }
        .padding(.top, 35)
        .padding(.trailing, 27)
    }

    @ViewBuilder
    private func backupFileIcon(file: FileObject) -> some View {
        if file.name.contains("google") {
            Image.googleSignIn
                .resizable()
                .frame(width: 43, height: 43)
                .cornerRadius(.infinity)
        } else if file.name.contains("apple") {
            Image.appleSignIn
                .resizable()
                .frame(width: 43, height: 43)
                .cornerRadius(.infinity)
        } else if file.name.contains("facebook") {
            Image.facebookSignIn
                .resizable()
                .frame(width: 43, height: 43)
                .cornerRadius(.infinity)
        } else {
            let defaultAvatar = MediaResourceModel(
                path: "https://res.cloudinary.com/timeless/image/upload/v1/app/Wallet/bowie.jpg",
                altText: nil,
                pathPrefix: nil,
                mediaType: "jpg",
                thumbnail: nil
            )
            MediaResourceView(for: MediaResource(for: defaultAvatar,
                                                    targetSize: TargetSize(width: 143,
                                                                           height: 143)),
                                 placeholder: ProgressView()
                                    .progressViewStyle(.circular)
                                    .eraseToAnyView(),
                                 isPlaying: .constant(true))
                .scaledToFill()
                .frame(width: 43, height: 43)
                .cornerRadius(.infinity)
        }
    }
}

extension BackupFileListView {
    private func onTapClose() {
        hideConfirmationSheet()
    }
}
