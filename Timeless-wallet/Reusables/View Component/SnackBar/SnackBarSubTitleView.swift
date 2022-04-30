//
//  SnackBarSubTitleView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 01/02/22.
//

import SwiftUI

struct SnackBarSubTitleView {
    // MARK: - Input parameters
    var snackBarIcon: Image
    var snackBarTitle: String
    var snackBarSubtitle: String
    var background = Color.snackBarBackground
    var iconColor: Color?
    var textColor = Color.white
    var didTap: (() -> Void)?
}

// MARK: - Body view
extension SnackBarSubTitleView: View {
    var body: some View {
        HStack(spacing: 0) {
            snackBarIcon
                .resizable()
                .frame(width: 25, height: 25)
                .padding(.horizontal, 15)
                .foregroundColor(iconColor)
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(snackBarTitle)
                        .tracking(0.6)
                        .fixedSize(horizontal: false, vertical: false)
                        .foregroundColor(textColor)
                        .font(.system(size: 15), weight: .bold)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(snackBarSubtitle)
                        .tracking(0.6)
                        .fixedSize(horizontal: false, vertical: false)
                        .foregroundColor(textColor)
                        .font(.system(size: 12))
                        .lineLimit(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.vertical, 10)
            Button(action: { hideSnackBar() }) {
                Image("closeBackup")
                    .resizable()
                    .foregroundColor(Color.white)
                    .frame(width: 22, height: 22)
            }
            .frame(width: 51, height: 51)
        }
        .background(background)
        .cornerRadius(20)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .onTapGesture {
            didTap?()
            hideSnackBar()
        }
    }
}
