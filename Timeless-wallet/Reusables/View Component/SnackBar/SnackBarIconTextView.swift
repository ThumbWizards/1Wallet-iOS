//
//  SnackBarIconTextView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 29/10/2021.
//

import SwiftUI

struct SnackBarIconTextView {
    // MARK: - Input parameters
    var snackBarIcon: Image
    var snackBarTitle: String
    var background = Color.snackBarBackground
    var iconColor: Color?
    var textColor = Color.white
    var showCheckMark = false
    var hideIcon = false
    var customFrame: CGSize = .init(width: 16, height: 16)
}

// MARK: - Body view
extension SnackBarIconTextView: View {
    var body: some View {
        HStack(spacing: 0) {
            if !hideIcon {
                snackBarIcon
                    .resizable()
                    .frame(width: customFrame.width, height: customFrame.height)
                    .scaledToFit()
                    .padding(.horizontal, 10)
                    .foregroundColor(iconColor)
                    .opacity(showCheckMark ? 0 : 1)
            }
            HStack(spacing: 0) {
                if showCheckMark {
                    Text("\(Image.checkmarkCircleFill) \(snackBarTitle)")
                        .tracking(0.6)
                        .fixedSize(horizontal: false, vertical: false)
                        .foregroundColor(textColor)
                        .font(.system(size: 15))
                        .lineLimit(5)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                } else {
                    Text(snackBarTitle)
                        .tracking(0.6)
                        .fixedSize(horizontal: false, vertical: false)
                        .foregroundColor(textColor)
                        .font(.system(size: 15))
                        .lineLimit(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                }
            }
            .padding(.leading, hideIcon ? 16 : 0)
            Button(action: { hideSnackBar() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color.white)
            }
            .frame(width: 51, height: 51)
        }
        .background(background)
        .cornerRadius(20)
        .padding(.horizontal, 20)
    }
}
