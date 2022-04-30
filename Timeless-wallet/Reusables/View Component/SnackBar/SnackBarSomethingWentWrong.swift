//
//  SnackBarSomethingWentWrong.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 15/03/2022.
//

import SwiftUI

struct SnackBarSomethingWentWrong {
    // MARK: - Properties
    @State private var randomText = ""
}

// MARK: - Body view
extension SnackBarSomethingWentWrong: View {
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Image.ladybug
                .resizable()
                .frame(width: 17.5, height: 18.5)
                .font(.system(size: 16))
                .offset(y: 1)
                .padding(.leading, 10)
                .padding(.trailing, 11)
                .foregroundColor(Color.white)
            Text(randomText)
                .tracking(0.4)
                .lineSpacing(0.5)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(Color.white)
                .font(.system(size: 15))
            Spacer(minLength: 42.5)
        }
        .padding(.top, 15)
        .padding(.bottom, 16)
        .padding(.leading, 7.5)
        .background(Color.snackBarBackground)
        .cornerRadius(16)
        .overlay(
            Button(action: { onTapClose() }) {
                ZStack {
                    Image.xmarkCircle
                        .resizable()
                        .frame(width: 15, height: 15)
                        .font(.system(size: 16))
                        .foregroundColor(Color.white)
                }
                .frame(width: 48, height: 45)
                .background(Color.almostClear)
            }
            .offset(y: 1.5), alignment: .topTrailing
        )
        .padding(.horizontal, 22)
        .padding(.top, 13.5)
        .onAppear { onAppearHandler() }
    }
}

// MARK: - Methods
extension SnackBarSomethingWentWrong {
    private func onTapClose() {
        hideSnackBar()
    }

    private func onAppearHandler() {
        randomText = Constants.ErrorText.randomError.randomElement() ?? ""
    }
}
