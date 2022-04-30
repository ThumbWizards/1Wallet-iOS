//
//  CreateDonationView.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 26/01/22.
//

import SwiftUI

struct CreateDonationView {
    // MARK: - Variables
    @State private var keyboardHeight = CGFloat.zero
    @State private var paddingKeyboard = CGFloat.zero
    @FocusState private var focusedField: FocusedField?
    @State private var delayForNextButton = false
    @StateObject var viewModel: ViewModel
    @ObservedObject private var walletInfo = WalletInfo.shared
    enum FocusedField {
        case name, description
    }
}

extension CreateDonationView: View, KeyboardReadable {
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                Color.primaryBackground
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    titleView
                        .padding(.vertical, 17)
                        .padding(.horizontal, 16)
                    Spacer()
                        .frame(height: 10)
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            if viewModel.charityThumb.isEmpty {
                                charityPlaceholderView
                                    .padding(.bottom, 10)
                            } else {
                                charityThumbView
                                    .padding(.bottom, 10)
                            }
                            discoverableToggle
                                .padding(.bottom, 42)
                            daoTextField(placeholder: viewModel.placeholder ?? "",
                                         text: $viewModel.daoName.max(viewModel.maxDaoNameChar),
                                         charLimit: viewModel.remainingDaoNameChar,
                                         onCommit: {
                                focusedField = .description
                            })
                                .submitLabel(.next)
                                .focused($focusedField, equals: .name)
                                .padding(.bottom, 12)
                            daoTextField(placeholder: "Brief DAO intro",
                                         text: $viewModel.daoDesc.max(viewModel.maxDaoDescChar),
                                         charLimit: viewModel.remainingDaoDescChar,
                                         onCommit: {
                                focusedField = nil
                                delayForNextButton = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    delayForNextButton = false
                                }
                            })
                                .submitLabel(.done)
                                .focused($focusedField, equals: .description)
                        }
                        .offset(y: -paddingKeyboard)
                    }
                    .ignoresSafeArea(.keyboard)
                }
                .keyboardAppear(keyboardHeight: $keyboardHeight)
                .onChange(of: focusedField) { _ in getPaddingKeyboard(keyboardHeight) }
                if viewModel.isValidate() && keyboardHeight == 0 {
                    HStack {
                        Spacer()
                        nextView
                            .padding(.trailing, 15)
                            .padding(.bottom, 15)
                    }
                    .padding(.bottom, UIView.hasNotch ? 0 : 12)
                    .hidden(delayForNextButton)
                }
            }
            .hideNavigationBar()
        }
    }
}

// MARK: - Subviews
extension CreateDonationView {
    private var titleView: some View {
        ZStack {
            HStack {
                Button(action: { onTapBack() }) {
                    Image.closeBackup
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 30)
                }
                .zIndex(1)
                Spacer()
                WalletAvatar(wallet: walletInfo.currentWallet,
                             frame: CGSize(width: 30, height: 30))
                    .onTapGesture(perform: {
                        showConfirmation(.avatar())
                    })
            }
            VStack(spacing: 3.5) {
                Text("DAO")
                    .tracking(0)
                    .foregroundColor(Color.white87)
                    .font(.system(size: 18, weight: .semibold))
                Text("Easy Setup")
                    .tracking(-0.2)
                    .foregroundColor(Color.subtitleSheet)
                    .font(.system(size: 14, weight: .medium))
            }
        }
    }

    private var charityThumbView: some View {
        charityImage(.init(width: 179, height: 179),
                     path: viewModel.charityThumb)
            .cornerRadius(8)
            .clipped()
            .overlay(
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.3))
                    Image.cameraFill
                }
                    .frame(width: 40, height: 40)
                    .padding(8)
                    .onTapGesture(perform: {
                        present(CharityListView(charityThumb: { image in
                            viewModel.charityThumb = image
                        }))
                    }),
                alignment: .topTrailing)
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

    private var charityPlaceholderView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.formForeground)
            .frame(width: 179, height: 179)
            .overlay(
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.3))
                    Text("Select a\ncharity")
                        .font(.sfProText(size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                }
                    .frame(width: 123, height: 123)
                    .onTapGesture(perform: {
                        present(CharityListView(charityThumb: { image in
                            viewModel.charityThumb = image
                        }))
                    }),
                alignment: .center)
    }

    private var discoverableToggle: some View {
        VStack {
            HStack {
                Text("Discoverable")
                    .font(.sfProText(size: 14))
                Toggle("", isOn: $viewModel.isDiscoverable).labelsHidden()
                    .tint(.timelessBlue)
            }
            Text("allows anyone to discover the DAO")
                .font(.sfProText(size: 12))
                .foregroundColor(.daoDiscoverableDesc)
        }
    }

    private func daoTextField(placeholder: String,
                              text: Binding<String>,
                              charLimit: String,
                              onCommit: @escaping (() -> Void)) -> AnyView {
        return HStack {
            TextField(placeholder,
                      text: text,
                      onCommit: onCommit)
                .accentColor(.timelessBlue)
                .frame(maxWidth: .infinity)
                .padding(.leading, 8)
            Text(charLimit)
                .font(.sfProText(size: 16))
                .foregroundColor(.hashtagLength)
                .tracking(-0.39)
                .padding(.trailing, 8)
        }
        .frame(height: 41)
        .background(Color.reviewButtonBackground.opacity(0.3))
        .padding(.horizontal, 16)
        .eraseToAnyView()
    }

    private var nextView: some View {
        HStack(spacing: 8) {
            Text("Multisig Setup")
                .tracking(-0.41)
                .font(.sfProTextSemibold(size: 17))
                .foregroundColor(.white)
            Button {
                presentMultisigView()
            } label: {
                Image.nextCircle
                    .resizable()
                    .tint(.white)
                    .frame(width: 40, height: 40)
            }
            .disabled(viewModel.charityThumb.isEmpty)
        }
    }
}

// MARK: - Functions
extension CreateDonationView {
    private func onTapBack() {
        focusedField = nil
        UIApplication.shared.endEditing()
        dismiss()
        pop()
    }

    private func presentMultisigView() {
        viewModel.bindDaoData()
        present(SelectMultiSigView(viewModel: .init(viewModel.daoModel)))
    }

    private func getPaddingKeyboard(_ value: CGFloat) {
        let keyboardTop = UIScreen.main.bounds.height - value
        let focusedTextInputBottom = (UIResponder.currentFirstResponder?.globalFrame?.maxY ?? 0) + 13 + paddingKeyboard
        withAnimation(.easeInOut(duration: 0.2)) {
            if focusedTextInputBottom > keyboardTop {
                paddingKeyboard = focusedTextInputBottom - keyboardTop + 6
            } else {
                paddingKeyboard = 0
            }
        }
    }
}

struct CreateDonationView_Previews: PreviewProvider {
    static var previews: some View {
        CreateDonationView(viewModel: .init(placeholder: ""))
    }
}
