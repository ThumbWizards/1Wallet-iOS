//
//  DaoShareView.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 02/02/22.
//

import SwiftUI

struct DaoShareView {
    // MARK: - Variables
    @StateObject var viewModel: ViewModel
    @State private var qrCodeCGImage: CGImage?
}

extension DaoShareView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                headerView
                VStack(spacing: 0) {
                    charityImage
                        .padding(.bottom, 12)
                        .padding(.top, 26)
                    daoDescription
                        .padding(.bottom, 30)
                        .padding(.horizontal, 20)
                    qrCodeView
                        .padding(.bottom, 30)
                    Button(action: {
                        onShare()
                    }) {
                        ZStack {
                            Color.myQRShareBtn
                            HStack(spacing: 9) {
                                Image.shareImageIcon
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 17, weight: .semibold))
                                    .frame(width: 18, height: 19)
                                Text("Share")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 17, weight: .semibold))
                            }
                        }
                    }
                    .frame(width: 195, height: 49)
                    .cornerRadius(10)
                    .padding(.bottom, 31)
                    .disabled(qrCodeCGImage == nil)
                    .opacity(qrCodeCGImage == nil ? 0.3 : 1)
                }
                .width(UIScreen.main.bounds.width - 50)
                .background(Color.searchBackground)
                .cornerRadius(12)
                .padding(.bottom, 8)
                Text("QR prompts invitation modal")
                    .tracking(-0.7)
                    .font(.system(size: 16))
                    .foregroundColor(Color.white)
                    .opacity(0.4)
            }
            .minHeight(UIScreen.main.bounds.height)
            .offset(y: 13)
        }
        .background(Color.black)
        .ignoresSafeArea()
        .hideNavigationBar()
        .onAppear {
            guard qrCodeCGImage == nil else {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    qrCodeCGImage = QRCodeHelper
                        .generateQRCodeCFImage(from: viewModel.chatData.daoJoinLink ?? "")
                }
            }
        }
    }
}

// MARK: - Function
extension DaoShareView {
    func onTapClose() {
        dismiss()
        pop()
    }

    private func onShare() {
        guard let cgImage = qrCodeCGImage else {
            return
        }
        let image = UIImage(cgImage: cgImage)
        let activityViewController = UIActivityViewController(
            activityItems: [image,
                            MyActivityItemSource(
                                title: "Join Group",
                                text: viewModel.chatData.daoJoinLink ?? "")],
            applicationActivities: nil
        )
        present(activityViewController)
    }

    private func copyShareLink() {
        UIPasteboard.general.string = viewModel.chatData.daoJoinLink ?? ""
        showSnackBar(.coppied)
    }
}

// MARK: - Subviews
extension DaoShareView {
    private var headerView: some View {
        ZStack {
            HStack {
                Button(action: { onTapClose() }) {
                    Image.closeBackup
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 30)
                }
                .padding(.leading, 24)
                .offset(y: 2)
                Spacer()
            }
        }
        .padding(.bottom, 12)
    }

    private var charityImage: some View {
        charityImage(.init(width: 132, height: 132),
                     path: viewModel.getCharityThumb())
            .frame(width: 132, height: 132)
            .cornerRadius(8)
    }

    private var daoDescription: some View {
        VStack {
            Text(viewModel.chatData.daoName ?? "")
                .font(.sfProTextSemibold(size: 18))
                .foregroundColor(.white.opacity(0.8))
                .padding(.bottom, 4)
            HStack(spacing: 3) {
                Button {
                    UIPasteboard.general.string = (viewModel.chatData.safeAddress ?? "").convertToWalletAddress()
                    showSnackBar(.coppied)
                } label: {
                    Text("\(viewModel.daoTrimmedAddress)")
                }

                Button {
                    (viewModel.chatData.safeAddress ?? "").openWalletExplorer()
                } label: {
                    Image.arrowUpRightSquare
                }
            }
            .foregroundColor(.descriptionNFT.opacity(0.87))
            .font(.sfProText(size: 15))
            .padding(.bottom, 7)
            Group {
                Text("Minimum contribution: \(viewModel.chatData.minimumContribution ?? "0") ONE")
                    .tracking(-0.19)
                Text("Expires: \(viewModel.chatData.daoExpireDate ?? "")")
                    .tracking(-0.19)
            }
            .font(.sfProText(size: 12))
            .foregroundColor(.white.opacity(0.8))

            Text(viewModel.chatData.daoDescription ?? "")
                .tracking(-0.19)
                .font(.sfProText(size: 12))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(.white.opacity(0.4))
                .padding(.top, 6)
        }
    }

    private var qrCodeView: some View {
        ZStack {
            if let qrCodeCGImage = qrCodeCGImage {
                Image(cgImage: qrCodeCGImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .padding(4)
            }
        }
        .frame(width: 160, height: 160)
        .background(qrCodeCGImage == nil ? Color.primaryBackground.opacity(0.3) : Color.white)
        .cornerRadius(10)
        .loadingOverlay(isShowing: qrCodeCGImage == nil)
        .onTapGesture {
            copyShareLink()
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
}
