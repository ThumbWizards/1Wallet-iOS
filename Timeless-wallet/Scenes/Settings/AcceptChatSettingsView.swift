//
//  AcceptChatSettingsView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 19/01/2022.
//

import SwiftUI

struct AcceptChatSettingsView {
    // MARK: - Properties
    @AppStorage(ASSettings.Settings.acceptNewChatFromAnyOne.key)
    private var acceptNewChatFromAnyOne = ASSettings.Settings.acceptNewChatFromAnyOne.defaultValue
}

// MARK: - Body view
extension AcceptChatSettingsView: View {
    var body: some View {
        ZStack(alignment: .top) {
            Color.primaryBackground
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                SettingsHeaderView(title: "Accept new chats from")
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        selectableRow
                    }
                    .padding(.top, 18)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

// MARK: - Subview
extension AcceptChatSettingsView {
    private var selectableRow: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(ASSettings.AcceptNewChatFromType.allCases, id: \.self) { item in
                rowButton(item)
                if item != ASSettings.AcceptNewChatFromType.allCases.last {
                    Rectangle()
                        .foregroundColor(Color.dividerAutoLock.opacity(0.5))
                        .frame(height: 1)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width - 34)
        .background(Color.formForeground)
        .cornerRadius(10)
    }

    private func rowButton(_ item: ASSettings.AcceptNewChatFromType) -> some View {
        Button(action: {
            acceptNewChatFromAnyOne = item.rawValue
            pop()
        }) {
            ZStack(alignment: .topTrailing) {
                HStack(alignment: .top, spacing: 16) {
                    ZStack {
                        item.image
                            .resizable()
                            .foregroundColor(Color.white)
                            .frame(width: item.imageSize.width, height: item.imageSize.height)
                    }
                    .frame(width: 19.5)
                    .padding(.leading, 8)
                    VStack(alignment: .leading, spacing: item == .anyone ? 5 : 2) {
                        Text(item.title)
                            .font(.system(size: 17))
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .foregroundColor(Color.white)
                        Text(item.subtitle)
                            .tracking(-0.2)
                            .font(.system(size: 12))
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Color.white.opacity(0.4))
                    }
                    .padding(.trailing, 5)
                    .offset(y: item == .anyone ? -2 : -5)
                    Spacer(minLength: 5)
                }
                Image.checkmark
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundColor(Color.white60)
                    .offset(y: 12)
                    .opacity(acceptNewChatFromAnyOne == item.rawValue ? 1 : 0)
            }
            .padding(.leading, 11)
            .padding(.trailing, 12)
            .padding(.top, item == .anyone ? 19 : 17)
            .padding(.bottom, item == .anyone ? 14 : 6)
        }
    }
}
