//
//  InstallGoogleAuthenticatorView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 13/12/2021.
//

import SwiftUI

struct InstallGoogleAuthenticatorView {
    // MARK: - Properties
    @State private var renderUI = false
    let urlAppStoreStr = "https://apps.apple.com/us/app/google-authenticator/id388497605"
}

// MARK: - Body view
extension InstallGoogleAuthenticatorView: View {
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: .infinity)
                .foregroundColor(Color.white60)
                .frame(width: 40, height: 5)
                .padding(.top, 7)
                .padding(.bottom, 25.5)
            Text("Google Authenticator")
                .tracking(-0.4)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.white)
                .padding(.bottom, 10)
            Text("Oops! It appears that you have not yet installed Google Authenticator.\nRetry after installation.")
                .tracking(-0.2)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(5)
                .opacity(0.8)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 56)
                .padding(.bottom, 21)
            if renderUI {
                loadingView
            } else {
                loadingView
            }
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Image.lockShield
                        .resizable()
                        .frame(width: 12, height: 14)
                        .foregroundColor(Color.white)
                        .opacity(0.8)
                        .font(.system(size: 15))
                    Text("Securely backup to Google Authenticator")
                        .tracking(-0.3)
                        .foregroundColor(Color.white87)
                        .font(.system(size: 15))
                }
                .offset(x: 3)
                Text("Google Authenticator provides security layer  through its Time-based One-time Password (OTP) Algorithm.")
                    .font(.system(size: 13))
                    .tracking(-0.01)
                    .lineSpacing(2)
                    .foregroundColor(Color.white60)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 11)
            .frame(width: UIScreen.main.bounds.width - 49)
            .background(Color.keyboardAccessoryBG
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.timelessBlue,
                                                lineWidth: 1))
                            .eraseToAnyView())
            .padding(.bottom, 14)
            Button(action: { goToAppStore() }) {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(Color.timelessBlue)
                    .frame(height: 48)
                    .padding(.horizontal, 24)
                    .overlay(
                        Text("Go to App Store")
                            .tracking(0.5)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color.white)
                    )
            }
            Spacer()
        }
        .height(498)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            renderUI.toggle()
        }
    }

    private var loadingView: some View {
        LottieView(name: "circle-loading", loopMode: .constant(.loop), isAnimating: .constant(true))
            .scaledToFill()
            .frame(width: 98, height: 86)
            .padding(.bottom, 34)
    }
}

// MARK: - Methods
extension InstallGoogleAuthenticatorView {
    private func goToAppStore() {
        if let urlAppStore = URL(string: urlAppStoreStr),
           UIApplication.shared.canOpenURL(urlAppStore) {
            UIApplication.shared.open(urlAppStore)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                hideConfirmationSheet()
            }
        }
    }
}
