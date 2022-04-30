//
//  SettingItem.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 22/11/2021.
//

import SwiftUI

struct SettingItem {
    // MARK: - Input parameters
    @Binding var toggleValue: Bool
    var selectedValueTitle = ""
    let item: SettingsItem
}

// MARK: - Body view
extension SettingItem: View {
    var body: some View {
        ZStack(alignment: .trailing) {
            HStack(spacing: 0) {
                ZStack {
                    item.image
                        .resizable()
                        .foregroundColor(Color.white)
                        .frame(width: item.imageSize.width, height: item.imageSize.height)
                }
                .frame(width: 26.5)
                .padding(.trailing, 12)
                Text(item.title)
                    .font(.system(size: 17))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .foregroundColor(Color.white)
                Spacer(minLength: 5)
            }
            if item.toggleValue {
                ZStack {
                    Toggle("", isOn: $toggleValue)
                        .toggleStyle(SwitchToggleStyle(tint: Color.timelessBlue))
                        .scaleEffect(0.8)
                        .offset(x: -11)
                }
                .frame(width: 80, height: 51, alignment: .trailing)
                .overlay(Color.white.opacity(0.0001))
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        toggleValue.toggle()
                    }
                }
            } else if !selectedValueTitle.isEmpty {
                selectedValue()
            }
        }
        .padding(.leading, 17)
        .frame(height: 51)
    }
}

// MARK: - Subview
extension SettingItem {
    private func selectedValue() -> some View {
        HStack(spacing: 8) {
            Text(selectedValueTitle)
                .font(.system(size: 15))
                .foregroundColor(Color.white40)
                .lineLimit(1)
            Image.chevronRight
                .resizable()
                .frame(width: 7, height: 12)
                .foregroundColor(Color.white60)
        }
        .padding(.trailing, 22)
    }
}
