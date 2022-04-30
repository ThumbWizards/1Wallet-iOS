//
//  NodeSettingsView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 22/11/2021.
//

import SwiftUI
import UIKit

struct NodeSettingsView {
    // MARK: - Input parameters
    @Binding var selectedNodeSetting: NodeSettingType

    // MARK: - Properties
    @AppStorage(ASSettings.Setting.testnetSetting.key)
    private var testnetSetting = ASSettings.Setting.testnetSetting.defaultValue
}

// MARK: - Body view
extension NodeSettingsView: View {
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
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .frame(height: 1)
                        .padding(.horizontal, 24)
                        .foregroundColor(Color.dividerDeveloper)
                        .padding(.bottom, 105.5)
                        Text("This setting determines the beginning of the week")
                            .foregroundColor(Color.bottomDescription)
                            .font(.system(size: 12))
                            .padding(.top, 13)
                            .padding(.leading, 24)
                            .padding(.trailing, 34)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .hideNavigationBar()
    }
}

// MARK: - Subview
extension NodeSettingsView {
    private var selectableRow: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(NodeSettingType.allCases, id: \.self) { item in
                rowButton(item)
                if item != NodeSettingType.allCases.last {
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

    private func rowButton(_ item: NodeSettingType) -> some View {
        Button(action: {
            if selectedNodeSetting != item {
                selectedNodeSetting = item
                if item == .testnet {
                    testnetSetting = true
                    let statusBar = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: UIScreen.main.bounds.width,
                                                         height: UIView.safeAreaTop))
                    statusBar.backgroundColor = UIColor(Color.timelessRed)
                    statusBar.tag = 100
                    UIApplication.shared.windows.first?.addSubview(statusBar)
                } else {
                    testnetSetting = false
                    UIApplication.shared.windows.first?.viewWithTag(100)?.removeFromSuperview()
                }
            }
            pop()
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
                Image.checkmark
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundColor(Color.white60)
                    .opacity(selectedNodeSetting == item ? 1 : 0)
            }
            .padding(.leading, 11)
            .padding(.trailing, 21)
            .frame(height: 50)
        }
    }
}

enum NodeSettingType: CaseIterable {
    case mainnet
    case testnet

    var title: String {
        switch self {
        case .mainnet: return "Mainnet"
        case .testnet: return "Testnet"
        }
    }

    var image: Image {
        switch self {
        case .mainnet: return Image.appConnectedToAppBelowFill
        case .testnet: return Image.mustache
        }
    }

    var imageSize: CGSize {
        switch self {
        case .mainnet: return CGSize(width: 14, height: 17)
        case .testnet: return CGSize(width: 22, height: 8)
        }
    }
}
