//
//  ProviderInfoView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 04/01/2022.
//

import SwiftUI

struct ProviderInfoView: View {
    // MARK: - Properties
}

// MARK: - Body view
extension ProviderInfoView {
    var body: some View {
        ZStack(alignment: .top) {
            Color.sheetBG
            VStack(spacing: 0) {
                header
                providerDetail
                Spacer()
                okButton
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - Subview
extension ProviderInfoView {
    private var header: some View {
        ZStack {
            HStack {
                Button(action: { onTapClose() }) {
                    Image.closeBackup
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 30)
                }
                .padding(.leading, 18.5)
                .offset(y: -1)
                Spacer()
            }
            Text("Service Provider Info")
                .tracking(-0.1)
                .foregroundColor(Color.white87)
                .font(.system(size: 18, weight: .semibold))
                .offset(y: -4)
        }
        .padding(.top, 33)
    }

    private var providerDetail: some View {
        VStack(spacing: 28) {
            Image.simplexIcon
                .resizable()
                .renderingMode(.original)
                .frame(width: 241, height: 75)
            // swiftlint:disable line_length
            Text("Simplex is an EU-licensed financial institution enabling crypto businesses and users to more easily access cryptocurrencies and digital assets with fiat currencies and traditional payment methods including credit and debit cards.")
                .font(.system(size: 13))
                .multilineTextAlignment(.center)
                .lineSpacing(4.5)
                .foregroundColor(Color.white)
                .padding(.horizontal, 36)
                .opacity(0.4)
        }
        .padding(.top, 73)
    }

    private var okButton: some View {
        Button(action: { onTapClose() }) {
            RoundedRectangle(cornerRadius: .infinity)
                .foregroundColor(Color.timelessBlue)
                .frame(height: 41)
                .overlay(
                    Text("OK")
                        .font(.system(size: 17))
                        .foregroundColor(Color.white)
                )
        }
        .padding(.horizontal, 43)
        .padding(.bottom, 60)
    }
}

// MARK: - Methods
extension ProviderInfoView {
    private func onTapClose() {
        dismiss()
    }
}
