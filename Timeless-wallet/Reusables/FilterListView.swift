//
//  FilterListView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 28/01/2022.
//

import SwiftUI

struct FilterListView {
    // MARK: - Input Parameters
    var keyForCaching: String
    @State var filterList: [FilterType]
    @State var selectedFilter: FilterType
    @State var previousSelectedFilter: FilterType

    // MARK: - Properties
    @State private var toggleSelf = false
}

// MARK: - Bodyview
extension FilterListView: View {
    var body: some View {
        ZStack {
            listFilter
            closeButton
        }
    }
}

// MARK: - Subview
extension FilterListView {
    private var listFilter: some View {
        VStack(spacing: 0) {
            ForEach(filterList, id: \.self) { filter in
                Text(filter.title)
                    .font(.system(size: 18, weight: .bold))
                    .scaleEffect(filter == selectedFilter ? 1.2 : 1)
                    .foregroundColor(filter == selectedFilter ? Color.white : Color.white.opacity(0.6))
                    .opacity(filter == selectedFilter ? (toggleSelf ? 0 : 1) : 1)
                    .frame(width: UIScreen.main.bounds.width)
                    .padding(.vertical, 16.5)
                    .background(Color.almostClear)
                    .onTapGesture { onTapFilterLine(filter) }
            }
        }
    }

    private var closeButton: some View {
        VStack {
            Spacer()
            Button(action: { onTapClose() }) {
                Circle()
                    .frame(width: 57.5, height: 57.5)
                    .overlay(
                        Image.xmark
                            .resizable()
                            .font(.system(size: 17, weight: .medium))
                            .frame(width: 17, height: 17)
                            .foregroundColor(.black)
                    )
                    .frame(width: UIScreen.main.bounds.width)
                    .padding(.vertical, 20)
                    .background(Color.almostClear)
            }
            .buttonStyle(ButtonTapScaleDown())
            .animation(.easeInOut(duration: 0.2))
            .padding(.bottom, UIView.hasNotch ? UIView.safeAreaBottom - 20 : 10)
        }
    }
}

// MARK: - Methods
extension FilterListView {
    private func onTapFilterLine(_ filter: FilterType) {
        Utils.playHapticEvent()
        var updateFilter = false
        if selectedFilter != filter {
            updateFilter = true
            withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.5)) {
                selectedFilter = filter
                UserDefaults.standard.setValue(selectedFilter.key, forKey: keyForCaching)
            }
        } else {
            withAnimation(.easeInOut(duration: 0.15)) {
                toggleSelf = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    toggleSelf = false
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + (updateFilter ? 0.6 : 0.4)) {
            UIApplication.shared.getTopViewController()?.dismiss()
        }
    }

    private func onTapClose() {
        Utils.playHapticEvent()
        UIApplication.shared.getTopViewController()?.dismiss()
    }
}
