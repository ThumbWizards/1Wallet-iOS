//
//  ThemeSettingsView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 20/01/2022.
//

import SwiftUI

struct ThemeSettingsView {
    // MARK: - Properties
    @AppStorage(ASSettings.Settings.theme.key)
    private var theme = ASSettings.Settings.theme.defaultValue
}

// MARK: - Body view
extension ThemeSettingsView: View {
    var body: some View {
        ZStack(alignment: .top) {
            Color.primaryBackground
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                SettingsHeaderView(title: "Theme")
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
extension ThemeSettingsView {
    private var selectableRow: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(ASSettings.ThemeType.allCases, id: \.self) { item in
                rowButton(item)
                if item != ASSettings.ThemeType.allCases.last {
                    Rectangle()
                        .foregroundColor(Color.dividerAutoLock.opacity(0.5))
                        .frame(height: 1)
                        .padding(.horizontal, 11)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width - 34)
        .background(Color.autoLockBG)
        .cornerRadius(10)
    }

    private func rowButton(_ item: ASSettings.ThemeType) -> some View {
        Button(action: {
            theme = item.rawValue
            pop()
        }) {
            ZStack(alignment: .trailing) {
                HStack(spacing: 17) {
                    if item != .system {
                        RoundedRectangle(cornerRadius: .infinity)
                            .foregroundColor(item == .dark ? Color.primaryBackground : Color.white)
                            .frame(width: 43, height: 43)
                    } else {
                        VStack(spacing: 0) {
                            Rectangle()
                                .foregroundColor(Color.systemLightGray)
                            Rectangle()
                                .foregroundColor(Color.primaryBackground)
                        }
                        .frame(width: 43, height: 43)
                        .cornerRadius(.infinity)
                    }
                    Text(item.title)
                        .font(.system(size: 15))
                        .foregroundColor(Color.white.opacity(0.87))
                    Spacer(minLength: 5)
                }
                Image.checkmark
                    .resizable()
                    .frame(width: 14, height: 14.5)
                    .foregroundColor(Color.white)
                    .offset(y: 2)
                    .opacity(theme == item.rawValue ? 1 : 0)
                Text("available soon")
                    .font(.system(size: 15))
                    .foregroundColor(Color.white.opacity(0.4))
                    .offset(x: 11)
                    .opacity(item != .dark ? 1 : 0)
            }
            .padding(.leading, 11)
            .padding(.trailing, 36)
            .padding(.top, item == .dark ? 15.5 :
                           item == .light ? 19.5 : 18.5)
            .padding(.bottom, item == .dark ? 15.5 :
                              item == .light ? 18.5 : 19.5)
        }
        .disabled(item != .dark)
    }
}
