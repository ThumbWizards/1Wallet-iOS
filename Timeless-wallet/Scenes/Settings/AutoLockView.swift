//
//  AutoLockView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 04/11/2021.
//

import SwiftUI

struct AutoLockView {
    @AppStorage(ASSettings.Settings.autoLockType.key)
    private var autoLockType = ASSettings.Settings.autoLockType.defaultValue
}

// MARK: - Body view
extension AutoLockView: View {
    var body: some View {
        ZStack(alignment: .top) {
            Color.primaryBackground
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                SettingsHeaderView(title: "Auto-Lock")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("AUT0-LOCK")
                            .font(.system(size: 12))
                            .foregroundColor(Color.white40)
                            .padding(.leading, 8)
                        selectableRow
                    }
                    .padding(.top, 15)
                }
            }
        }
    }
}

// MARK: - Subview
extension AutoLockView {
    private var selectableRow: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(ASSettings.AutoLockType.allCases, id: \.self) { item in
                rowButton(item)
                if item != ASSettings.AutoLockType.allCases.last {
                    Rectangle()
                        .foregroundColor(Color.dividerAutoLock.opacity(0.5))
                        .frame(height: 1)
                        .padding(.leading, 15.5)
                        .padding(.trailing, 4.5)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width - 34)
        .background(Color.autoLockBG)
        .cornerRadius(10)
    }

    private func rowButton(_ item: ASSettings.AutoLockType) -> some View {
        Button(action: {
            autoLockType = item.rawValue
            pop()
        }) {
            ZStack(alignment: .trailing) {
                HStack(spacing: 19) {
                    Text(item.title)
                        .tracking(0.3)
                        .font(.system(size: 15))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .foregroundColor(Color.white87)
                        .padding(.trailing, 5)
                    Spacer(minLength: 5)
                }
                Image.checkmark
                    .resizable()
                    .frame(width: 14, height: 14)
                    .foregroundColor(Color.white60)
                    .opacity(autoLockType == item.rawValue ? 1 : 0)
            }
            .padding(.leading, 17)
            .padding(.trailing, 17)
            .frame(height: 49)
        }
    }
}
