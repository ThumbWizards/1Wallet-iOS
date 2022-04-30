//
//  FloorPriceView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 12/01/2022.
//

import SwiftUI

struct FloorPriceView {
    // MARK: - Input Parameters
    var avgColor = Color.clear
}

// MARK: - Body view
extension FloorPriceView: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                contentView
                gotItButton
                Spacer()
            }
            .height(492)
        }
    }
}

// MARK: - Subview
extension FloorPriceView {
    private var contentView: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: .infinity)
                .frame(width: 40, height: 5)
                .foregroundColor(Color.white.opacity(0.6))
                .padding(.bottom, 25)
            Text("Floor Price")
                .tracking(-0.2)
                .foregroundColor(Color.white)
                .font(.system(size: 28, weight: .bold))
                .padding(.bottom, 19)
            // swiftlint:disable line_length
            Text("Floor price is the lowest price for collection items, rather than the average item price, and is updated in real-time. Dutch auctions are not included in floor price calculations.")
                .tracking(-0.1)
                .lineSpacing(4)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.bottom, 27)
            Text("This doesn't necessarily mean that you should go buy the cheapest NFT out of the entire project. Find the category you want to invest in (for example the \"rare\" NFTs from the project) and pick up the cheapest one.")
                .tracking(-0.1)
                .lineSpacing(4)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.bottom, 41)
            Text("source: opensea")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.white.opacity(0.6))
        }
        .padding(.horizontal, 29)
        .padding(.top, 11)
    }

    private var gotItButton: some View {
        Button(action: { onTapGotIt() }) {
            RoundedRectangle(cornerRadius: .infinity)
                .foregroundColor(avgColor)
                .frame(height: 41)
                .padding(.horizontal, 41)
                .overlay(
                    Text("Got it")
                        .font(.system(size: 17))
                        .foregroundColor(getButtonTitleColor())
                )
        }
        .padding(.top, 32)
    }
}

// MARK: - Methods
extension FloorPriceView {
    private func onTapGotIt() {
        hideConfirmationSheet()
    }

    private func getButtonTitleColor() -> Color {
        var result = Color.white
        if UIColor(avgColor).brightness > 0.7 {
            result = Color.titleGray
        }
        return result
    }
}
