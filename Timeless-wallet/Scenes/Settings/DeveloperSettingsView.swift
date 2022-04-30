//
//  DeveloperSettingsView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 22/11/2021.
//

import SwiftUI

struct DeveloperSettingsView {
    // MARK: - Properties
    @AppStorage(ASSettings.Setting.testnetSetting.key)
    private var testnetSetting = ASSettings.Setting.testnetSetting.defaultValue
    @State private var selectedNodeSetting = NodeSettingType.mainnet
}

// MARK: - Body view
extension DeveloperSettingsView: View {
    var body: some View {
        ZStack(alignment: .top) {
            Color.primaryBackground
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                SettingsHeaderView(title: "Developer Settings")
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        selectableRow
                    }
                    .padding(.top, 18)
                }
                ZStack(alignment: .top) {
                    Rectangle()
                        .frame(height: 1)
                        .padding(.horizontal, 24)
                        .foregroundColor(Color.dividerDeveloper)
                        .padding(.bottom, 105.5)
                    // swiftlint:disable line_length
                    Text("The Faucet is intended for use by DApp Developers on Harmony Testnet. The dispensed $ONE via the faucet has no monetary value and should only be used to test application. Please return unused Testnet tokens back to the faucet.")
                        .foregroundColor(Color.bottomDescription)
                        .font(.system(size: 12))
                        .offset(x: -2)
                        .padding(.top, 13)
                        .padding(.leading, 24)
                        .padding(.trailing, 34)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear { onAppearHandler() }
    }
}

// MARK: - Subview
extension DeveloperSettingsView {
    private var selectableRow: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(DeveloperSettingsType.allCases, id: \.self) { item in
                rowButton(item)
                if item != DeveloperSettingsType.allCases.last {
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

    private func rowButton(_ item: DeveloperSettingsType) -> some View {
        var selectedValueTitle = ""
        if item == .nodeSettings {
            selectedValueTitle = selectedNodeSetting.title
        }

        return Button(action: {
            switch item {
            case .nodeSettings: onTapNodeSettings()
            case .harmonyFaucet: onTapHarmonyFaucet()
            }
        }) {
            ZStack(alignment: .trailing) {
                HStack(spacing: 11) {
                    ZStack {
                        item.image
                            .resizable()
                            .foregroundColor(Color.white)
                            .frame(width: item.imageSize.width, height: item.imageSize.height)
                    }
                    .frame(width: 28)
                    Text(item.title)
                        .tracking(0)
                        .font(.system(size: 17))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .foregroundColor(Color.white)
                        .padding(.trailing, 5)
                    Spacer(minLength: 5)
                }
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
            }
            .padding(.leading, 16)
            .padding(.trailing, 22)
            .frame(height: 50)
        }
    }
}

extension DeveloperSettingsView {
    private func onAppearHandler() {
        if testnetSetting {
            selectedNodeSetting = .testnet
        } else {
            selectedNodeSetting = .mainnet
        }
    }

    private func onTapNodeSettings() {
        push(NodeSettingsView(selectedNodeSetting: $selectedNodeSetting))
    }

    private func onTapHarmonyFaucet() {
        push(HarmonyFaucetView().hideNavigationBar())
    }
}

enum DeveloperSettingsType: CaseIterable {
    case nodeSettings
    case harmonyFaucet

    var title: String {
        switch self {
        case .nodeSettings: return "Node Settings"
        case .harmonyFaucet: return "Harmony Faucet"
        }
    }

    var image: Image {
        switch self {
        case .nodeSettings: return Image.appConnectedToAppBelowFill
        case .harmonyFaucet: return Image.mustache
        }
    }

    var imageSize: CGSize {
        switch self {
        case .nodeSettings: return CGSize(width: 14, height: 17)
        case .harmonyFaucet: return CGSize(width: 22, height: 8)
        }
    }
}
