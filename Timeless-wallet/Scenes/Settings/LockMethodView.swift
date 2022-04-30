//
//  LockMethodView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 22/11/2021.
//

import SwiftUI

struct LockMethodView {
    @AppStorage(ASSettings.Settings.lockMethod.key)
    private var lockMethod = ASSettings.Settings.lockMethod.defaultValue
}

// MARK: - Body view
extension LockMethodView: View {
    var body: some View {
        ZStack(alignment: .top) {
            Color.primaryBackground
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                SettingsHeaderView(title: "Lock Method")
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        selectableRow
                    }
                    .padding(.top, 18)
                }
            }
        }
    }
}

// MARK: - Subview
extension LockMethodView {
    private var selectableRow: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(ASSettings.LockMethod.allCases, id: \.self) { item in
                rowButton(item)
                if item != ASSettings.LockMethod.allCases.last {
                    Rectangle()
                        .foregroundColor(Color.dividerAutoLock.opacity(0.5))
                        .frame(height: 1)
                        .padding(.leading, 10.5)
                        .padding(.trailing, 9.5)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width - 34)
        .background(Color.autoLockBG)
        .cornerRadius(10)
    }

    private func rowButton(_ item: ASSettings.LockMethod) -> some View {
        Button(action: {
            lockMethod = item.rawValue
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
                    .frame(width: 12, height: 12)
                    .foregroundColor(Color.white60)
                    .opacity(lockMethod == item.rawValue ? 1 : 0)
            }
            .padding(.leading, 11)
            .padding(.trailing, 21)
            .frame(height: 50)
        }
    }
}
