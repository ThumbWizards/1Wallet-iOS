//
//  WalletPrivacyView.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 16/11/2021.
//

import Foundation
import SwiftUI

struct WalletPrivacyView {
    @ObservedObject private var viewModel = AppSetupView.ViewModel.shared
    @State private var isPublic = true
}

extension WalletPrivacyView: View {
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .foregroundColor(Color.white60)
                .frame(width: 40, height: 5)
                .cornerRadius(2.5)
                .padding(.top, 9)
                .padding(.bottom, 26)
            Text("Privacy Preferences")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.white)
                .padding(.bottom, 12)
            Text("You can always change this later in Settings")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white87)
                .multilineTextAlignment(.center)
                .padding(.bottom, 41)
                .padding(.horizontal, 36)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image.eye
                        .foregroundColor(Color.white87)
                        .font(.system(size: 15, weight: .regular))
                    Text("Public")
                        .foregroundColor(Color.white87)
                        .font(.system(size: 15, weight: .regular))
                    Text("(Default | Recommended)")
                        .foregroundColor(Color.white60)
                        .font(.system(size: 12, weight: .regular))
                        .padding(.leading, 5)
                }
                // swiftlint:disable line_length
                Text("Other users can search for my username, send me money, and view all transactions associated with the username via the Harmony block explorer. ")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.white40)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .frame(width: UIScreen.main.bounds.width - 40)
            .background(isPublic ? Color.keyboardAccessoryBG
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.timelessBlue,
                                                lineWidth: 1))
                            .eraseToAnyView() : Color.almostClear.eraseToAnyView())
            .padding(.bottom, 14)
            .onTapGesture {
                Utils.playHapticEvent()
                withAnimation {
                    isPublic = true
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image.eyeSlash
                        .foregroundColor(Color.white87)
                        .font(.system(size: 15, weight: .regular))
                    Text("Private")
                        .foregroundColor(Color.white87)
                        .font(.system(size: 15, weight: .regular))
                }
                Text("Other users cannot search for my username. ")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.white40)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
            .background(!isPublic ? Color.keyboardAccessoryBG
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.timelessBlue,
                                                lineWidth: 1))
                            .eraseToAnyView() : Color.almostClear.eraseToAnyView())
            .onTapGesture {
                Utils.playHapticEvent()
                withAnimation {
                    isPublic = false
                }
            }
            .padding(.bottom, 14)
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                Button { } label: {
                    HStack {
                        Text("Next")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color.white)
                    }
                    .frame(width: UIScreen.main.bounds.width - 82, height: 42)
                    .background(Color.timelessBlue.cornerRadius(15))
                }
            }
            .padding(.bottom, UIView.hasNotch ? UIView.safeAreaBottom + 5 : 35)
        }
        .loadingOverlay(isShowing: viewModel.isLoading)
        .height(440)
    }
}
