//
//  FilterButtonView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 28/01/2022.
//

import SwiftUI

struct FilterButtonView {
    // MARK: - Input Parameters
    var keyForCaching: String
    @State var filterList: [FilterType]
    @State var selectedFilter: FilterType
}

// MARK: - Bodyview
extension FilterButtonView: View {
    var body: some View {
        Button(action: { showFilterView() }) {
            HStack(spacing: 0) {
                Image.filterIcon
                    .resizable()
                    .frame(width: 19, height: 18)
                    .padding(.leading, 13)
                    .offset(y: -1)
                Spacer(minLength: 0)
                Text(selectedFilter.shortTitle)
                    .font(.system(size: 14, weight: .medium))
                    .tracking(-0.5)
                    .foregroundColor(Color.filterText)
                    .lineLimit(1)
                    .offset(x: -2)
                Spacer(minLength: 0)
                Image.chevronDown
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color.filterText)
                    .frame(width: 12, height: 7)
                    .padding(.trailing, 14)
            }
            .frame(width: 140, height: 37)
            .background(Color.filterButtonBG)
            .cornerRadius(.infinity)
        }
    }
}

// MARK: - Methods
extension FilterButtonView {
    private func showFilterView() {
        Utils.playHapticEvent()
        let view = UIHostingController(rootView: ZStack {
            if let uiImage = UIApplication.shared.windows.first?.asUIImage() {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .overlay(Color.black.opacity(0.4))
                    .blur(radius: 5)
            }
            FilterListView(keyForCaching: keyForCaching,
                           filterList: filterList,
                           selectedFilter: selectedFilter,
                           previousSelectedFilter: selectedFilter)
        },
        ignoreSafeArea: true)
        view.view.backgroundColor = .clear
        view.modalPresentationStyle = .overFullScreen
        view.modalTransitionStyle = .crossDissolve
        UIApplication.shared.getTopViewController()?.present(view, animated: true)
    }
}

struct FilterType: Hashable {
    var shortTitle: String
    var title: String
    var key: Int
}

enum MultiSigFilterType {
    case queued
    case history

    static var filterList: [FilterType] {
        return [
            FilterType(shortTitle: "QUEUED", title: "Queued", key: 0),
            FilterType(shortTitle: "HISTORY", title: "History", key: 1)
        ]
    }

    static var selectedFilterType: FilterType {
        Self.filterList.first {
            $0.key == UserDefaults.standard.integer(forKey: ASSettings.WalletDetail.multiSigFilterType.key)
        } ?? filterList[0]
    }
}
