//
//  DaoCreateAndShareView.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 02/02/22.
//

import SwiftUI

struct DaoCreateAndShareView {
    // MARK: - Variables
    @StateObject var viewModel: ViewModel
}

extension DaoCreateAndShareView: View {
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Color.primaryBackground
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    ScrollView {
                        headerView
                            .padding(15)
                        daoImageView
                            .padding(.leading, 20)
                        daoDescriptionView
                            .padding(.bottom, 11)
                        signatoriesView
                            .padding(.bottom, UIView.hasNotch ? 60 : 72)
                    }
                    .padding(.top, 1)
                }
                saveButton
                    .padding(.bottom, UIView.hasNotch ? 0 : 12)
            }
            .hideNavigationBar()
            .loadingOverlay(isShowing: viewModel.isLoading)
        }
    }
}

// MARK: - Functions
extension DaoCreateAndShareView {
    private func onTapBack() {
        dismiss()
        pop()
    }

    private func createSafeTapAction() {
        viewModel.createSafe()
    }
}

// MARK: - Subviews
extension DaoCreateAndShareView {
    private var headerView: some View {
        HStack {
            Spacer()
            Button(action: { onTapBack() }) {
                Image.closeBackup
            }
        }
    }

    private var daoImageView: some View {
        HStack(spacing: 8) {
            charityImage(.init(
                width: viewModel.imageRatio,
                height: viewModel.imageRatio),
                         path: viewModel.daoModel.charityThumb ?? "")
                .frame(width: viewModel.imageRatio,
                       height: viewModel.imageRatio)
                .cornerRadius(8)
                .clipped()
            VStack {
                Spacer()
                VStack(alignment: .leading) {
                    Text("Smart Contract")
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.white)
                        .font(.sfProText(size: 17))
                    Button(action: { viewModel.daoModel.masterWalletAddress?.address.openWalletExplorer() }) {
                        Text("\(viewModel.daoTrimmedAddress) \(Image.arrowUpRightSquare)")
                            .foregroundColor(.descriptionNFT.opacity(0.6))
                            .font(.sfProText(size: 15))
                    }
                }
                .offset(y: -14)
            }
            Spacer()
        }
    }
    
    private func charityImage(_ size: CGSize, path: String) -> AnyView {
        let image = MediaResourceModel(path: path,
                                       altText: nil,
                                       pathPrefix: nil,
                                       mediaType: nil,
                                       thumbnail: nil)
        return MediaResourceView(for: MediaResource(for: image,
                                                       targetSize: TargetSize(width: Int(size.width),
                                                                              height: Int(size.height))),
                                    placeholder: ProgressView()
                                        .progressViewStyle(.circular)
                                        .eraseToAnyView(),
                                    isPlaying: .constant(true))
            .scaledToFill()
            .frame(size)
            .eraseToAnyView()
    }

    private var daoDescriptionView: some View {
        VStack(alignment: .leading) {
            Text(viewModel.daoModel.daoName ?? "-")
                .font(.sfProTextSemibold(size: 18))
                .multilineTextAlignment(.leading)
                .foregroundColor(.white)
                .padding(.bottom, 7)
                .padding(.top, 12)
            Group {
                Text("Minimum contribution: \(viewModel.daoModel.minimumContribution) ONE")
                    .tracking(-0.19)
                Text("Expires: \(viewModel.daoModel.strExpireDate)")
                    .tracking(-0.19)
            }
            .font(.sfProText(size: 12))
            .foregroundColor(.white.opacity(0.6))
            Text(viewModel.daoModel.description ?? "")
                .tracking(-0.19)
                .font(.sfProText(size: 12))
                .multilineTextAlignment(.leading)
                .foregroundColor(.white.opacity(0.4))
                .padding(.top, 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }

    private var signatoriesView: some View {
        VStack(alignment: .leading) {
            Text("Multisignatories (\(viewModel.daoModel.threshold ?? 0) of \(viewModel.daoModel.signers.count) required)")
                .foregroundColor(.sectionContactText)
                .font(.sfProText(size: 14))
                .padding(.top, 16)

            ForEach(viewModel.daoModel.signers.indices, id: \.self) { index in
                let indexData = viewModel.daoModel.signers[index]
                MultisigWalletView(
                    walletAddress: indexData.walletAddress?.address,
                    walletName: indexData.walletName,
                    walletAvatar: indexData.walletAvatar,
                    type: .walletLink,
                    walletLinkTapped: {
                        indexData.walletAddress?.address.openWalletExplorer()
                    })
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }

    private var saveButton: some View {
        Button(action: { createSafeTapAction() }) {
            RoundedRectangle(cornerRadius: .infinity)
                .foregroundColor(Color.timelessBlue)
                .frame(height: 41)
                .padding(.horizontal, 42)
                .overlay(
                    Text("Create & Share")
                        .foregroundColor(Color.white)
                        .font(.system(size: 17))
                )
        }
    }
}

struct DaoCreateAndShareView_Previews: PreviewProvider {
    static var previews: some View {
        DaoCreateAndShareView(viewModel: .init(CreateDaoModel()))
    }
}
