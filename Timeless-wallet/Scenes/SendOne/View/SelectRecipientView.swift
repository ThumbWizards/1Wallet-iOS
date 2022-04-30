//
//  SelectRecipientView.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 26/11/21.
//

import SwiftUI
import StreamChat
import StreamChatUI

extension Notification.Name {
    public static let dismissSendOneViews = Notification.Name("kTimelessWalletDismissSendOneViews")
    public static let dismissRedPacketViews = Notification.Name("kTimelessWalletDismissSendOneViews")
    public static let sendRedPacket = Notification.Name("kTimelessWalletsendRedPacket")
}

struct SelectRecipientView {
    @ObservedObject var memberList: ChatChannelMemberListController.ObservableObject
    @ObservedObject private var viewModel = ViewModel()
    @State var isShowingPaymentView = false
    var channelListController: ChatChannelMemberListController
    var onDismiss: (() -> Void)?
    var didSelectMember: ((ChatChannelMember) -> Void)?
    var currentController = ChatClient.shared.currentUserController()

    init(channelController: ChatChannelMemberListController,
         didSelectMember: ((ChatChannelMember) -> Void)?,
         onDismiss: (() -> Void)?) {
        memberList = channelController.observableObject
        channelListController = channelController
        self.onDismiss = onDismiss
        self.didSelectMember = didSelectMember
    }

    private func getAlphabeticalSortedMemberList() -> [ChatChannelMember] {
        let filteredUsers = memberList.members.filter { return $0.id != channelListController.client.currentUserId }
        let alphabetUsers = filteredUsers.filter { ($0.name?.isFirstCharacterAlp ?? false) && $0.name?.isBlank == false }
            .sorted { ($0.name ?? "").localizedCaseInsensitiveCompare($1.name ?? "") == ComparisonResult.orderedAscending }
        let otherUsers = filteredUsers.filter { ($0.name?.isFirstCharacterAlp ?? false) == false }
            .sorted { $0.id.localizedCaseInsensitiveCompare($1.id) == ComparisonResult.orderedAscending }
        var data = [ChatChannelMember]()
        data.append(contentsOf: alphabetUsers)
        data.append(contentsOf: otherUsers)
        return data
    }
}

// MARK: - Body view
extension SelectRecipientView: View {
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                header
                membersList
            }
            .background(Color.primaryBackground)
        }
        .sheet(isPresented: $isShowingPaymentView) {
            SendPaymentView(viewModel: .init(walletData: viewModel.sendOneWalletData)).hideNavigationBar()
        }
        .ignoresSafeArea()
        .onAppear {
            memberList.controller.synchronize()
        }
        .onReceive(NotificationCenter.default.publisher(for: .dismissSendOneViews)) { _ in
            onTapClose()
        }
    }
}

// MARK: - Subview
extension SelectRecipientView {
    private var header: some View {
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
            VStack(spacing: 8) {
                Text("Send")
                    .tracking(0)
                    .foregroundColor(Color.white87)
                    .font(.sfProDisplayBold(size: 18))
                Text("Select Recipient")
                    .tracking(0)
                    .foregroundColor(.addFundsSubtitle)
                    .font(.sfProText(size: 14))
            }
            Spacer()
            WalletAvatar(wallet: WalletInfo.shared.currentWallet, frame: .init(width: 40, height: 40))
                .padding(.trailing, 18.5)
                .offset(y: -1)
        }
        .padding(.top, 26.5)
    }

    private func memberView(for member: ChatChannelMember) -> some View {
        HStack(alignment: .center) {
            if hasImageUrl(for: member) {
                RemoteImage(
                    url: member.imageURL,
                    loading: .avatar,
                    failure: .avatar)
                    .frame(width: 40, height: 40)
                    .background(.clear)
                    .clipShape(Circle())
            } else {
                Image.imgPlaceholder
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
            VStack {
                Group {
                    Text(member.name ?? "-")
                        .lineLimit(1)
                        .font(.sfProText(size: 17))
                        .foregroundColor(Color.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 8)
    }

    private var membersList: some View {
        List {
            ForEach(getAlphabeticalSortedMemberList()) { member in
                memberView(for: member)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal)
                    .background(Color.containerBackground.opacity(0.18))
                    .onTapGesture {
                        didSelectMember?(member)
                    }
            }
        }
        .introspectTableView(customize: { tblView in
            tblView.backgroundColor = UIColor(.primaryBackground)
        })
        .background(Color.primaryBackground)
    }
}

// MARK: - Functions
extension SelectRecipientView {
    private func onTapClose() {
        onDismiss?()
    }

    private func hasImageUrl(for member: ChatChannelMember) -> Bool {
        return member.imageURL != nil
    }
}
