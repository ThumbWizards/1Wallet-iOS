//
//  ContactModalView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 11/11/2021.
//

import SwiftUI
import StreamChat
import StreamChatUI
import web3swift

struct ContactModalView {
    // MARK: - Input Parameters
    @StateObject var viewModel: ViewModel
    var addSignerDetail: ((SignerWallet) -> Void)?
    var onContactSelect: ((ContactModel) -> Void)?

    // MARK: - Properties
    @AppStorage(ASSettings.Contact.expandFullWallet.key)
    private var expandFullWallet = ASSettings.Contact.expandFullWallet.defaultValue
    @State private var keyboardHeight = CGFloat.zero
    @State private var searchStr = ""
    @State private var renderUI = false
    @State private var scrollValue: ScrollViewProxy?
    @State private var showWalletList = false
    @State private var isGoToWalletDetail = false
    @State private var selectedWallet = Wallet.currentWallet
    @State private var textField: UITextField?
    // swiftlint:disable line_length
    @State private var alphabetScrollList = [
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#"
    ]
    @State private var now = Date()

    private let generator = UINotificationFeedbackGenerator()

    struct SendHorizontal {
        var hashtag: String
        var image: Image
        var active: Bool
    }
}

extension ContactModalView {
    private var contacts: [ContactSectionData] {
        viewModel.searchedResults ?? (viewModel.sectionData ?? [])
    }

    private var title: String {
        switch viewModel.screenType {
        case .send:
            return "Send"
        case .contact:
            return "Contact"
        case .addSigner:
            return "Signer"
        }
    }
}

// MARK: - Body view
extension ContactModalView: View {
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color.primaryBackground.ignoresSafeArea()
                VStack(spacing: 0) {
                    header
                    searchField
                    if viewModel.sectionData?.isEmpty ?? false {
                        noContactAvailable
                    } else {
                        contactList
                    }
                }
                if let currentWallet = Wallet.currentWallet {
                    NavigationLink(
                        destination:
                            WalletDetailView(navigationLink: true, wallet: selectedWallet ?? currentWallet),
                        isActive: $isGoToWalletDetail
                    ) { EmptyView() }
                }
            }
            .hideNavigationBar()
            .keyboardAppear(keyboardHeight: $keyboardHeight)
            .loadingOverlay(isShowing: viewModel.isLoading)
            .onTapGesture { onTapOut() }
            .onAppear { onAppearHandler() }
            .onReceive(NotificationCenter.default.publisher(for: .sendOneWalletTapAction, object: nil)) { obj in
                if let userInfo = obj.userInfo {
                    viewModel.sendOneWalletTapAction(userInfo)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            renderUI.toggle()
        }
        .nowTimer(resolution: 10, now: $now)
        .onChange(of: now) { _ in
            viewModel.getContactActiveStatus()
        }
    }
}

// MARK: - Subview
extension ContactModalView {
    private var header: some View {
        ZStack {
            HStack {
                Button(action: { onTapClose() }) {
                    Image.closeBackup
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 30)
                }
                .padding(.leading, 18.5)
                .offset(y: -1)
                Spacer()
            }
            VStack(spacing: 3.5) {
                Text(title)
                    .tracking(0)
                    .foregroundColor(Color.white87)
                    .font(.system(size: 18, weight: .semibold))
                if viewModel.screenType == .send {
                    Text("Easy send")
                        .tracking(-0.2)
                        .foregroundColor(Color.subtitleSheet)
                        .font(.system(size: 14, weight: .medium))
                }
            }
        }
        .padding(.top, 26.5)
        .padding(.bottom, 31)
    }

    private var searchField: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: .infinity)
                .foregroundColor(Color.searchBackground)
                .frame(height: 42)
                .overlay(
                    ZStack(alignment: .leading) {
                        HStack(spacing: 15) {
                            Image.sendSearchIcon
                                .resizable()
                                .frame(width: 16, height: 16)
                            Text("Search")
                                .tracking(-0.5)
                                .font(.system(size: 16))
                                .foregroundColor(Color.sectionContactText)
                                .opacity(viewModel.searchingText.isBlank ? 1 : 0)
                        }
                        .padding(.leading, 15)
                        TextField("", text: $viewModel.searchingText)
                            .font(.system(size: 16))
                            .foregroundColor(Color.white)
                            .disableAutocorrection(true)
                            .keyboardType(.alphabet)
                            .accentColor(Color.timelessBlue)
                            .padding(.leading, 47)
                            .padding(.trailing, 16)
                            .introspectTextField { textField in
                                if self.textField == nil {
                                    self.textField = textField
                                }
                            }
                            .onTapGesture {
                                // AVOID KEYBOARD CLOSE
                            }
                    }
                    .frame(height: 42)
                    .background(
                        Color.almostClear
                            .onTapGesture {
                                textField?.becomeFirstResponder()
                            }
                    )
                )
                .padding(.leading, 10)
                .padding(.trailing, 12)
            Button(action: { onTapAdd() }) {
                RoundedRectangle(cornerRadius: .infinity)
                    .foregroundColor(Color.buttonAddContactBG)
                    .frame(width: 35, height: 35)
                    .overlay(
                        Image.plus
                            .resizable()
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.timelessBlue)
                            .frame(width: 12, height: 12)
                    )
            }
            .padding(.trailing, 10)
//            Button(action: { onTapMore() }) {
//                RoundedRectangle(cornerRadius: .infinity)
//                    .foregroundColor(.clear)
//                    .frame(width: 35, height: 35)
//                    .overlay(
//                        ZStack {
//                            RoundedRectangle(cornerRadius: .infinity)
//                                .stroke(Color.buttonMoreBorder, lineWidth: 1)
//                            Image.threeDotIcon
//                                .resizable()
//                                .renderingMode(.original)
//                                .frame(width: 20, height: 7)
//                        }
//                    )
//            }
//            .padding(.trailing, 8)
        }
    }

    private var noContactAvailable: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer()
                    .minHeight(10)
                    .maxHeight(50)
                Text("No contact available")
                    .tracking(-0.4)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color.white)
                    .padding(.bottom, 11)
                Text("You can not only process sending assets faster but can unlock many social features by adding new contacts")
                    .tracking(-0.2)
                    .font(.system(size: 14, weight: .medium))
                    .lineSpacing(5.5)
                    .foregroundColor(Color.noContactDetail)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 60)
                    .padding(.bottom, 54)
                if renderUI {
                    emptyLottie
                } else {
                    emptyLottie
                }
                Button(action: { onTapAdd() }) {
                    Text("ADD CONTACT")
                        .tracking(-0.2)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.timelessBlue)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24.5)
                        .background(Color.buttonAddContactBG.cornerRadius(.infinity))
                }
                Spacer()
            }
            .padding(.top, 21)
        }
    }

    private var emptyLottie: some View {
        LottieView(name: "contactEmpty", loopMode: .constant(.loop), isAnimating: .constant(true))
            .scaledToFill()
            .aspectRatio(217 / 217, contentMode: .fit)
            .padding(.horizontal, 99)
            .padding(.bottom, 60)
            .offset(x: -1)
    }

    private var contactList: some View {
        VStack(spacing: 0) {
            Button(action: { onTapAccountName() }) {
                HStack(spacing: 0) {
                    ZStack {
                        WalletAvatar(wallet: WalletInfo.shared.currentWallet, frame: CGSize(width: 58, height: 58))
                    }
                    .frame(width: 61, height: 61)
                    .cornerRadius(.infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: .infinity).stroke(Color.searchFieldBorder, lineWidth: 1)
                    )
                    .padding(.trailing, 13)
                    VStack(alignment: .leading, spacing: 2.5) {
                        Text(Wallet.currentWallet?.name ?? "")
                            .tracking(-0.4)
                            .lineLimit(1)
                            .foregroundColor(Color.white)
                            .font(.system(size: 28, weight: .semibold))
                        HStack(spacing: 0) {
                            let totalContact = viewModel.contacts?.count ?? 0
                            Text("\(totalContact) \(totalContact <= 1 ? "contact" : "contacts")")
                                .tracking(-0.6)
                                .font(.system(size: 16))
                                .foregroundColor(Color.contactAmount)
                            if let activeContact = viewModel.onlineContactsCount {
                                RoundedRectangle(cornerRadius: .infinity)
                                    .foregroundColor(Color.contactAmount)
                                    .frame(width: 5, height: 5)
                                    .padding(.leading, 9.5)
                                    .padding(.trailing, 6.5)
                                    .offset(y: 1)
                                Text("\(activeContact) active")
                                    .tracking(-0.4)
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.activeAmount)
                            }
                        }
                    }
                    .offset(y: -1)
                    Spacer(minLength: 10)
                    Image.chevronRight
                        .resizable()
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.chevronAccountName)
                        .frame(width: 10, height: 18)
                        .rotationEffect(Angle(degrees: showWalletList ? 90 : 0))
                }
            }
            .padding(.leading, 10)
            .padding(.trailing, 19)
            .padding(.bottom, showWalletList ? 20 : 24)
            contactScrollView
                .zIndex(1)
        }
        .overlay(
            VStack(spacing: 0.7) {
                ForEach(0 ..< alphabetScrollList.count) { index in
                    Button(action: {
                        withAnimation(.easeInOut) {
                            generator.notificationOccurred(.success)
                            scrollValue?.scrollTo(index + 1, anchor: .top)
                        }
                    }) {
                        Text(alphabetScrollList[index])
                            .foregroundColor(Color.timelessBlue)
                            .font(.system(size: 11, weight: .semibold))
                    }
                }
            }
            .padding(.trailing, 2)
            .offset(y: 57 - (keyboardHeight / 2) + (showWalletList ? 0 : -4))
            .animation(.easeInOut(duration: 0.2)), alignment: .topTrailing
        )
        .padding(.top, 21)
    }

    private var contactScrollView: some View {
        ScrollView(showsIndicators: false) {
            verticalContactView
        }
        .simultaneousGesture(DragGesture().onChanged({ _ in
            withAnimation {
                UIApplication.shared.endEditing()
            }
        }))
    }

    private var verticalContactView: some View {
        ScrollViewReader { value in
            VStack(spacing: 0) {
                if showWalletList {
                    horizontalContactView
                }
                if !contacts.isEmpty {
                    ForEach(contacts, id: \.self) { contact in
                        VStack(spacing: 15) {
                            RoundedRectangle(cornerRadius: .infinity)
                                .foregroundColor(Color.searchBackground)
                                .frame(height: 25)
                                .overlay(
                                    Text(contact.sectionName.uppercased())
                                        .foregroundColor(Color.sectionContactText)
                                        .font(.system(size: 18, weight: .semibold))
                                        .padding(.leading, 14.5),
                                    alignment: .leading
                                )
                            contactNameList(contact.data)
                                .padding(.bottom, 15)
                        }
                        .padding(.horizontal, 10)
                        .id(getRowID(value: contact.sectionName) + 1)
                    }
                }
            }
            .onAppear { scrollValue = value }
            .padding(.bottom, keyboardHeight > 0 ? keyboardHeight / 2.5 : (UIView.hasNotch ? UIView.safeAreaBottom : 35))
        }
    }

    private var horizontalContactView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(WalletInfo.shared.allWallets) { wallet in
                    Button(action: { onTapWallet(wallet) }) {
                        Color.searchBackground
                            .frame(width: (UIScreen.main.bounds.width - 44) / 3, height: 120)
                            .cornerRadius(15)
                            .overlay(
                                VStack(spacing: 7) {
                                    WalletAvatar(wallet: wallet, frame: CGSize(width: 40, height: 40))
                                    Text("@\(wallet.name ?? "")")
                                        .tracking(-0.5)
                                        .foregroundColor(Color.white)
                                        .font(.system(size: 14, weight: .medium))
                                        .padding(.horizontal, 5)
                                        .lineLimit(1)
                                }
                            )
                    }
                }
            }
            .padding(.horizontal, 10)
        }
        .padding(.bottom, 24)
    }

    private func contactNameList(_ list: [ContactModel]) -> some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                ForEach(0 ..< list.count) { index in
                    nameItem(list[index])
                        .frame(height: 70)
                        .previewContextMenu(preview: previewView(list[index]),
                                            actions: [.pay, .message, .editContact, .deleteContact]) { actionType in
                            print(actionType)
                            switch actionType {
                            case .editContact:
                                present(AddContactView(viewModel: .init(list[index]),
                                                       contactViewModel: viewModel),
                                        presentationStyle: .automatic)
                            case .pay:
                                let indexData = list[index]
                                present(NavigationView { SendView(
                                    recipientAddress: indexData.walletAddress,
                                    recipientName: indexData.name,
                                    recipientImageUrl: URL(string: indexData.avatar ?? ""))
                                    .hideNavigationBar() })
                            case .message:
                                presentChatView(contact: list[index])
                            case .deleteContact:
                                viewModel.deleteContact(list[index])
                            default:
                                break
                            }
                        }
                                            .background(Color.formForeground)
                    Rectangle()
                        .foregroundColor(Color.dividerContact)
                        .frame(height: 1)
                }
            }
            Rectangle()
                .foregroundColor(Color.formForeground)
                .frame(height: 1)
        }
        .cornerRadius(12)
    }

    private func nameItem(_ item: ContactModel) -> some View {
        HStack(spacing: 0) {
            item.avatarView(CGSize(width: 40, height: 40))
                .padding(.trailing, 10)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .lineLimit(1)
                    .foregroundColor(Color.white)
                    .font(.system(size: 17))
                WalletAddressView(address: item.walletAddress, trimCount: 10)
                    .lineLimit(1)
                    .foregroundColor(Color.subtitleContact)
                    .font(.system(size: 15))
                    .minimumScaleFactor(0.5)
            }
            .offset(y: -0.5)
            Spacer(minLength: 10)
            if viewModel.screenType != .addSigner && viewModel.screenType != .send {
                Button(action: {
                    present(NavigationView {
                        SendView(
                            recipientAddress: item.walletAddress,
                            recipientName: item.name,
                            recipientImageUrl: URL(string: item.displayAvatar))
                            .hideNavigationBar()
                    })
                }) {
                    Image.btcIcon
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 28, height: 28)
                }
                .padding(.trailing, 10)
                Button(action: {
                    presentChatView(contact: item)
                }) {
                    RoundedRectangle(cornerRadius: .infinity)
                        .foregroundColor(Color.emailContactBG)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image.bubbleLeftRightFill
                                .resizable()
                                .foregroundColor(Color.white)
                                .frame(width: 14, height: 12)
                        )
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 70)
        .background(Color.almostClear)
        .onTapGesture(perform: {
            if viewModel.screenType == .send {
                dismiss()
                onContactSelect?(item)
            } else if viewModel.screenType == .addSigner {
                addSigner(data: item)
            }
        })
    }

    private func previewView(_ item: ContactModel) -> some View {
        ZStack {
            Color.clear
            VStack(spacing: 0) {
                item.avatarView(CGSize(width: 135, height: 135))
                    .padding(.trailing, 10)
                Text(item.name)
                    .tracking(0.6)
                    .foregroundColor(Color.contactNamePreview)
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.top, 25)
                WalletAddressView(address: item.walletAddress, trimCount: 10)
                    .foregroundColor(Color.contactNamePreview)
                    .font(.system(size: 12))
                    .padding(.top, 10)
            }
            .offset(y: 7)
        }
    }
}

// MARK: - Methods
extension ContactModalView {
    private func addSigner(data: ContactModel) {
        guard data.walletAddress.isOneWalletAddress,
              let walletAddress = EthereumAddress(data.walletAddress.convertBech32ToEthereum()) else {
            onTapClose()
            return
        }
        let signerDetail = SignerWallet(
            walletAddress: walletAddress,
            walletName: data.name,
            walletAvatar: data.displayAvatar)
        addSignerDetail?(signerDetail)
        onTapClose()
    }
    
    private func presentChatView(contact: ContactModel) {
        let client = ChatClient.shared
        guard let currentUserId = client.currentUserId else {
            return
        }
        do {
            let controller = try client.channelController(
                createDirectMessageChannelWith: [contact.walletAddress.convertBech32ToEthereum(), currentUserId],
                name: nil,
                imageURL: nil,
                extraData: [:])
            controller.synchronize { error in
                guard error == nil else {
                    showSnackBar(.error(error))
                    return
                }
                let chatChannelVC = ChatChannelVC()
                chatChannelVC.enableKeyboardObserver = true
                chatChannelVC.channelController = controller
                chatChannelVC.modalPresentationStyle = .fullScreen
                present(chatChannelVC, animated: true)
            }
        } catch {
            showSnackBar(.error(error))
        }
    }

    private func onAppearHandler() {
        showWalletList = expandFullWallet
        viewModel.pushPaymentView = {
            if let topVC = UIApplication.shared.getTopViewController() {
                topVC.present(SendPaymentVC(oneWallet: viewModel.oneWallet), animated: true, completion: nil)
            }
        }
    }

    private func getRowID(value: String) -> Int {
        for (index, item) in alphabetScrollList.enumerated() where value == item {
            return index
        }
        return alphabetScrollList.count + 1
    }

    private func onTapAccountName() {
        withAnimation(.easeInOut) {
            expandFullWallet.toggle()
            showWalletList.toggle()
        }
    }

    private func onTapWallet(_ wallet: Wallet) {
        selectedWallet = wallet
        isGoToWalletDetail = true
    }

    private func onTapOut() {
        UIApplication.shared.endEditing()
    }

    private func onTapAdd() {
        UIApplication.shared.endEditing()
        present(AddContactView(viewModel: .init(),
                               contactViewModel: viewModel),
                presentationStyle: .automatic)
    }

    private func onTapMore() {
        UIApplication.shared.endEditing()
    }

    private func onTapClose() {
        dismiss()
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
