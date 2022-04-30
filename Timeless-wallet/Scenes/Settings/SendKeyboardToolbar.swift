//
//  SendKeyboardToolbar.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 11/11/2021.
//

import SwiftUI

struct SendKeyboardToolbar {
    var onTapContact: () -> Void
    var onTapQRScan: () -> Void
}

extension SendKeyboardToolbar: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            Button(action: { onTapContact() }) {
                ZStack {
                    Color.almostClear
                        .frame(height: 44)
                    HStack(spacing: 6) {
                        Image.personTextRectangle
                            .resizable()
                            .foregroundColor(Color.white)
                            .frame(width: 19.5, height: 15)
                        Text("Contact")
                            .font(.system(size: 17))
                            .foregroundColor(Color.white)
                    }
                    .offset(x: -1, y: 2)
                }
            }
            Rectangle()
                .frame(width: 1, height: 24)
                .foregroundColor(Color.keyboardVerticalDivider)
                .offset(y: -6)
            Button(action: { onTapQRScan() }) {
                ZStack {
                    Color.almostClear
                        .frame(height: 44)
                    HStack(spacing: 6) {
                        Image.qrcodeViewFinder
                            .resizable()
                            .foregroundColor(Color.white)
                            .frame(width: 16, height: 16)
                        Text("QR Scan")
                            .font(.system(size: 17))
                            .foregroundColor(Color.white)
                    }
                    .offset(x: -1, y: 2)
                }
            }
        }
    }
}
