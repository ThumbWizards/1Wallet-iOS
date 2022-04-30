//
//  ExchangeWarningModal.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 4/25/22.
//

import SwiftUI

struct ExchangeWarningModal {
    @State private var renderUI = false
}

extension ExchangeWarningModal: View {
    var body: some View {
        contentView
    }
}

extension ExchangeWarningModal {
    private var contentView: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: .infinity)
                .foregroundColor(Color.swipeBar)
                .frame(width: 40, height: 5)
                .padding(.top, 6)
                .padding(.bottom, 30)
            Text("Caution")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.white)
                .padding(.bottom, 16)
            detailsView
                .padding(.horizontal, 37)
                .padding(.bottom, 25)
            lottieView
            discordText()
                .padding(.horizontal, 40)
                .padding(.bottom, 10)
            confirmButton
            Spacer()
        }
        .padding(.bottom, UIView.safeAreaBottom + 4)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            renderUI.toggle()
        }
    }
}

extension ExchangeWarningModal {

    @ViewBuilder
    private func discordText() -> some View {
        if let discordUrl = URL(string: Constants.Urls.discordUrl) {
            Link(destination: discordUrl) {
                HStack {
                    Text("Accidentally sent to an exchange wallet? Send us a ping via ")
                        .foregroundColor(Color.white40)
                    +
                    Text("Discord")
                        .foregroundColor(Color.timelessBlue.opacity(0.4))
                    Spacer()
                }
                .font(.system(size: 13, weight: .regular))
                .multilineTextAlignment(.leading)
            }
        } else {
            EmptyView()
        }
    }

    private var lottieView: some View {
        LottieView(name: "warning-error", loopMode: .constant(.loop), isAnimating: .constant(true))
            .scaledToFill()
            .frame(width: 101, height: 101)
            .padding(.bottom, 38)
            .id(renderUI)
    }

    private var confirmButton: some View {
        Button {
            hideConfirmationSheet()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                present(NavigationView { SendView().hideNavigationBar() })
            }
        } label: {
            Text("I understand")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color.white)
                .frame(width: UIScreen.main.bounds.width - 48, height: 48)
                .background(Color.timelessBlue)
                .cornerRadius(15)
        }
    }

    private var detailsView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 2) {
                    Text(Image.exclamationMark)
                    +
                    Text(" DO NOT SEND FUND TO EXCHANGES")
                }
                .font(.sfCompactText(size: 15))
                .foregroundColor(Color.white.opacity(0.8))
                // swiftlint:disable line_length
                Text("Centralized exchanges such as Binance, Kucoin,  Crypto.com cannot detect deposits from smart contract wallet at this time. We are working with the exchanges and on a new solution to address this issue in future releases.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.5))
                    .lineSpacing(2)
            }
            Spacer()
        }
    }
}
