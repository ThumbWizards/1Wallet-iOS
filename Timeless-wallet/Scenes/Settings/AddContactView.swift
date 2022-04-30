//
//  AddContactView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 08/11/2021.
//

import SwiftUI
import SwiftMessages
import Combine

struct AddContactView: View {
    @StateObject var viewModel: ViewModel
    @ObservedObject var contactViewModel: ContactModalView.ViewModel
    // MARK: - Input parameters
    var onClose: (() -> Void)?
    var onSave: ((String) -> Void)?

    // MARK: - Properties
    @State private var keyboardHeight = CGFloat.zero
    @State private var showActionSheet = false
    @State private var showingImagePicker = false
    @State private var selectedImage: Image?
    @State private var selectedUIImage: UIImage?
    @State private var showingPickerTypeSelector = false
    @State private var sourceType = UIImagePickerController.SourceType.photoLibrary
    @State private var textFieldName: UITextField?
    @State private var textFieldUserName: UITextField?
    @State private var dismissCancellable: AnyCancellable?
    @State private var isEditing = false

    private var savePaddingBottom: CGFloat {
        if isEditing && keyboardHeight > 0 {
            return keyboardHeight
        } else {
            return UIView.hasNotch ? UIView.safeAreaBottom : 35
        }
    }
    private var isEnableSave: Bool {
        !viewModel.name.isBlank && viewModel.checkValidate
    }
    enum AddContactTextFieldType {
        case name
        case username
    }
    let limitName = 50
}

// MARK: - Body view
extension AddContactView {
    var body: some View {
        ZStack(alignment: .top) {
            Color.sheetBG
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Button(action: { onTapClose() }) {
                            Image.closeBackup
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                        .padding(.leading, 18.5)
                        Spacer()
                    }
                    Text(viewModel.editingContact == nil ? "Add Contact" : "Edit Contact")
                        .tracking(-0.3)
                        .foregroundColor(Color.white87)
                        .font(.system(size: 18, weight: .semibold))
                        .offset(y: 2)
                }
                .padding(.top, 30.5)
                .padding(.bottom, 40)
                Button(action: { onTapImagePicker() }) {
                    ZStack {
                        if selectedImage == nil {
                            if viewModel.editingContact == nil {
                                RoundedRectangle(cornerRadius: .infinity)
                                    .foregroundColor(Color.textFieldHNS)
                                    .frame(width: 76, height: 76)
                                    .overlay(
                                        Image.plus
                                            .resizable()
                                            .frame(width: 18, height: 18)
                                            .foregroundColor(Color.swipeBar)
                                    )
                            } else {
                                viewModel.editingContact?.avatarView(CGSize(width: 76, height: 76))
                            }
                        } else {
                            selectedImage?
                                .resizable()
                                .renderingMode(.original)
                                .scaledToFill()
                                .frame(width: 76, height: 76)
                                .cornerRadius(.infinity)
                        }
                    }
                }
                .padding(.bottom, 31)
                textField(.name)
                textField(.username)
                if viewModel.isShowNotAvailable {
                    HStack(spacing: 4) {
                        Image.exclamationMarkCircleFill
                        Text("Could not find the user/address")
                            .foregroundColor(Color.timelessRed)
                        Spacer()
                    }
                    .font(.system(size: 12, weight: .medium))
                    .padding(.leading, 50)
                    .padding(.vertical, 5)
                } else {
                    // swiftlint:disable line_length
                    Text("All addresses or accounts are saved locally by default. To save, please remember to backup the account.")
                        .foregroundColor(Color.allAddressText)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(size: 12))
                        .padding(.horizontal, 50)
                }
                Spacer()
                Button(action: { onTapSave() }) {
                    RoundedRectangle(cornerRadius: .infinity)
                        .frame(height: 41)
                        .foregroundColor(isEnableSave ? Color.timelessBlue : Color.disableSaveContact)
                        .padding(.horizontal, 42)
                        .overlay(
                            HStack(spacing: 6) {
                                Image.personTextRectangle
                                    .resizable()
                                    .foregroundColor(isEnableSave ? Color.white : Color.disableSaveContactText)
                                    .frame(width: 20, height: 16)
                                Text("Save as contact")
                                    .tracking(-0.4)
                                    .font(.system(size: 18))
                                    .foregroundColor(isEnableSave ? Color.white : Color.disableSaveContactText)
                            }
                        )
                }
                .disabled(!isEnableSave)
                .offset(y: -savePaddingBottom)
                .animation(.easeInOut(duration: 0.2), value: savePaddingBottom)
            }
        }
        .keyboardAppear(keyboardHeight: $keyboardHeight)
        .ignoresSafeArea(.keyboard)
        .actionSheet(isPresented: $showingPickerTypeSelector) {
            ActionSheet(title: Text("Let’s Assign a Profile Picture"),
                        buttons: [
                            .default(
                                Text("Pick from Library"),
                                action: {
                                    sourceType = .photoLibrary
                                    showingImagePicker = true
                                }
                            ),
                            .default(
                                Text("Take a Photo"),
                                action: {
                                    sourceType = .camera
                                    showingImagePicker = true
                                }
                            ),
                            .cancel(Text("Cancel"), action: { showingPickerTypeSelector = false }),
                        ])
        }
        .fullScreenCover(isPresented: $showingImagePicker) {
            ImagePicker(isVisible: $showingImagePicker, image: $selectedImage, uiImg: $selectedUIImage, sourceType: sourceType)
                .ignoresSafeArea()
        }
        .onAppear(perform: {
            if viewModel.preselectedAddress {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.textFieldName?.becomeFirstResponder()
                }
            }
        })
        .onChange(of: selectedUIImage, perform: { image in
            viewModel.uploadToCloudinary(image: image)
        })
        .onChange(of: viewModel.name, perform: { value in
            if value.count > limitName {
                viewModel.name = String(value.prefix(limitName))
            }
        })
        .onChange(of: viewModel.address) { _ in
            viewModel.checkValidate = false
        }
        .onTapGesture { UIApplication.shared.endEditing() }
        .onDisappear { onClose?() }
        .loadingOverlay(isShowing: viewModel.isLoading)
    }
}

// MARK: - Subview
extension AddContactView {
    private func textField(_ type: AddContactTextFieldType) -> some View {
        RoundedRectangle(cornerRadius: 7)
            .foregroundColor(Color.textfieldEmailBG)
            .frame(height: 41)
            .overlay(
                ZStack(alignment: .leading) {
                    Text(type == .name ? "Name (visible only to you)" : "Username or address")
                        .tracking(-0.05)
                        .font(.system(size: 16))
                        .foregroundColor(Color.placeHolderNameAddContact)
                        .padding(.leading, 20)
                        .opacity((type == .name ? viewModel.name : viewModel.address).isBlank ? 1 : 0)
                    TextField("", text: type == .name ? $viewModel.name : $viewModel.address, isEditing: $isEditing)
                        .font(.system(size: 16))
                        .foregroundColor(Color.white)
                        .disableAutocorrection(true)
                        .keyboardType(.alphabet)
                        .accentColor(Color.timelessBlue)
                        .padding(.horizontal, 16)
                        .padding(.trailing, type == .username ? 29 : 44)
                        .introspectTextField { textField in
                            if type == .name, self.textFieldName == nil {
                                self.textFieldName = textField
                            } else if type == .username, self.textFieldUserName == nil {
                                self.textFieldUserName = textField
                            }
                        }
                        .onTapGesture {
                            // AVOID KEYBOARD CLOSE
                        }
                    if type == .username {
                        HStack {
                            Spacer()
                            Button(action: { onTapQR() }) {
                                Image.qrcodeViewFinder
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .foregroundColor(Color.white)
                                    .frame(width: 21)
                                    .padding(.trailing, 13.5)
                                    .overlay(
                                        Color.almostClear
                                            .padding(.leading, -19.5)
                                            .padding(.trailing, -6)
                                            .padding(.vertical, -16)
                                    )
                            }
                        }
                    } else {
                        HStack {
                            Spacer()
                            Text("\(viewModel.name.count)/50")
                                .font(.sfProText(size: 16))
                                .foregroundColor(.hashtagLength)
                                .tracking(-0.39)
                                .padding(.trailing, 13.5)
                        }
                    }
                }
            )
            .background(
                Color.almostClear
                    .padding(.leading, -6)
                    .padding(.trailing, type == .name ? -6 : 54)
                    .padding(.vertical, -6)
                    .onTapGesture {
                        if type == .name {
                            textFieldName?.becomeFirstResponder()
                        } else {
                            textFieldUserName?.becomeFirstResponder()
                        }
                    }
            )
            .padding(.horizontal, 40)
            .padding(.bottom, type == .name ? 12 : 9)
    }
}

// MARK: - Methods
extension AddContactView {
    private func onTapClose() {
        dismiss()
    }

    private func onTapImagePicker() {
        showingPickerTypeSelector = true
    }

    private func onTapSave() {
        viewModel.insertContactList {
            dismissCancellable = dismiss()?.sink(receiveValue: { _ in
                if viewModel.editingContact == nil {
                    showSnackBar(.newContactCreated)
                } else {
                    showSnackBar(.contactSaved)
                }
                contactViewModel.sortData()
            })
        }
    }

    private func onTapQR() {
        let view = QRCodeReaderView()
        view.screenType = .moneyORAddToContact
        if let topVc = UIApplication.shared.getTopViewController() {
            view.modalPresentationStyle = .fullScreen
            view.onScanSuccess = { qrString in
                if let url = URL(string: qrString) {
                    viewModel.address = url.lastPathComponent
                } else {
                    viewModel.address = qrString
                }
            }
            topVc.present(view, animated: true)
        }
    }
}

enum AddContactError: Error {
    case usernameNotFound
    case addressNotValid
}
