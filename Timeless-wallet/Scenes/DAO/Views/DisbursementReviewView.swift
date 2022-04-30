//
//  DisbursementReviewView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 03/02/22.
//

import SwiftUI

struct DisbursementReviewView {
    // MARK: - Variables
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @State private var isChecked = false
    @AppStorage(ASSettings.Setting.requireForTransaction.key)
    private var requireForTransaction = ASSettings.Setting.requireForTransaction.defaultValue
    @AppStorage(ASSettings.Settings.lockMethod.key)
    private var lockMethod = ASSettings.Settings.lockMethod.defaultValue
    private var appLockEnable: Bool {
        Lock.shared.passcode != nil && lockMethod != ASSettings.LockMethod.none.rawValue && requireForTransaction
    }
    @StateObject var viewModel: ViewModel
}

// MARK: - Body view
extension DisbursementReviewView: View {
    var body: some View {
        ZStack(alignment: .top) {
            Color.sheetBG
            VStack(spacing: 0) {
                header
                reviewView
                Spacer()
                footerView
            }
            .padding(.horizontal, 15)
            .padding(.top, 10 + UIView.safeAreaTop)
        }
        .onReceive(viewModel.$didGetTxData, perform: { value in
            if value {
                dismissAll()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showConfirmation(.disbursementConfirm(
                        wallet: viewModel.addressPreview,
                        type: .initiate,
                        daoName: viewModel.disbursementModel.getDaoName(),
                        daoUrl: viewModel.disbursementModel.getCharityThumb())
                    )
                }
            }
        })
        .loadingOverlay(isShowing: viewModel.isLoading)
        .ignoresSafeArea()
    }
}


extension DisbursementReviewView {
    private var header: some View {
        ZStack {
            HStack {
                Spacer()
                Button(action: { onTapClose() }) {
                    Image.closeBackup
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 30)
                }
                .padding(.leading, 24)
                .offset(y: 2)
            }
        }
    }

    private var reviewView: some View {
        VStack(spacing: 15) {
            VStack(spacing: 15) {
                charityImage(.init(
                    width: UIView.hasNotch ? 178 : 130, height: UIView.hasNotch ? 178 : 130
                ),
                path: viewModel.disbursementModel.charityThumb ?? "")
                Text(viewModel.disbursementModel.daoName ?? "")
                    .font(.sfProTextSemibold(size: 18))
                    .foregroundColor(Color.white)
            }
            .padding(.bottom, (UIView.hasNotch ? 25 : 15))
            VStack(alignment: .leading) {
                HStack {
                    Image.harmonyLogo
                        .resizable()
                        .frame(width: 30, height: 30)
                    Text("\(viewModel.oneAmount) ONE")
                        .font(.sfProText(size: 20))
                        .foregroundColor(Color.white)
                    Text("\(viewModel.usdAmount) USD")
                        .font(.sfProText(size: 20))
                        .foregroundColor(Color.white.opacity(0.2))
                }
                .padding(.leading, 10)
                Image.downArrow
                    .font(.sfProText(size: 18))
                    .foregroundColor(Color.white)
                    .padding(UIView.hasNotch ? 10 : 5)
                VStack {
                    HStack(alignment: .center, spacing: 0) {
                        VStack(spacing: 3) {
                            Text("Recipient wallet address")
                                .font(.sfProText(size: 15))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(viewModel.addressPreview)
                                .font(.sfProText(size: 12))
                                .foregroundColor(Color.paymentTitleFont.opacity(0.6))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.leading, 15)
                        Image.arrowUpRightSquare
                            .font(.sfProText(size: 15))
                            .foregroundColor(Color.descriptionNFT.opacity(0.5))
                            .padding(.trailing, 15)
                            .onTapGesture {
                                if let explorer = URL(string: "\(Constants.harmony.baseWalletAddress)\(viewModel.address)") {
                                    if UIApplication.shared.canOpenURL(explorer) {
                                        UIApplication.shared.open(explorer)
                                    }
                                }
                            }
                    }
                    .frame(height: 68)
                    .background(Color.paymentCard)
                    .cornerRadius(8)
                    .onTapGesture {
                        showSnackBar(.coppiedAddress)
                        UIPasteboard.general.string = viewModel.address
                    }
                    Text(viewModel.disbursementModel.purpose ?? "")
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.sfProText(size: 13))
                        .foregroundColor(Color.white40)
                        .padding(.horizontal, 15)
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
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

    private var footerView: some View {
        VStack {
            HStack(alignment: .top) {
                Group {
                    isChecked ? Image.squareFill : Image.squareBox
                }
                .font(.sfProText(size: 13))
                .foregroundColor(.white)
                .padding(.top, 3)
                // swiftlint:disable line_length
                Text("I have thoroughly reviewed the transaction and understand that the approved signatories will be notified for the required confirmations.")
                    .font(.sfProText(size: 13))
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(Color.white60)
            }
            .onTapGesture(perform: {
                isChecked.toggle()
            })
            Text("Submit Transaction")
                .font(.sfProText(size: 17))
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.timelessBlue)
                .clipShape(Capsule())
                .contentShape(Rectangle())
                .opacity(!isChecked ? 0.5 : 1)
                .onTapGesture {
                    guard isChecked else { return }
                    onSubmitClick()
                }
                .padding(.top, 15)
        }
        .onTapGesture(perform: {
            isChecked.toggle()
        })
        .padding(.horizontal, 15)
        .padding(.bottom, (UIView.hasNotch ? 50 : 30))
    }

}

// MARK: - Methods
extension DisbursementReviewView {
    private func onTapClose() {
        presentationMode.wrappedValue.dismiss()
    }

    private func onSubmitClick() {
        if appLockEnable {
            requestAuthentication { _ in
                showConfirmationReview()
            }
        } else {
            showConfirmationReview()
        }
    }

    private func showConfirmationReview() {
        viewModel.submitTransaction()
    }

    func requestAuthentication(for action: @escaping (Bool) -> Void) {
        present(BiometricView(
            callback: action).hideNavigationBar(),
                presentationStyle: .overFullScreen
        )
    }

}
