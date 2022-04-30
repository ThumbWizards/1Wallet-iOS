//
//  CreateWalletView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 28/10/2021.
//

import SwiftUI
import Combine
import Lottie
import Kingfisher

struct CreateWalletView {
    // MARK: - Properties
    @SwiftUI.Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject private var cryptoViewModel = CryptoHelper.shared.viewModel
    @ObservedObject private var viewModel = CreateWalletViewModel.shared
    @State private var renderUI = false
    @State private var email = ""
    @State private var currentOnboardWalletState = 0
    @State private var now = Date()
    @State private var renderText = false
    @State private var randomText = ""
}

// MARK: - Body view
extension CreateWalletView: View {
    var body: some View {
        ZStack(alignment: .top) {
            creatingWalletView
        }
        .height(493)
        .onAppear { onAppearHandler() }
    }
}

// MARK: - Subview
extension CreateWalletView {
    private var creatingWalletView: some View {
        VStack(spacing: 0) {
            Image.createWalletLogo
                .resizable()
                .frame(width: 46, height: 49)
                .padding(.bottom, 37.5)
                .offset(x: -2.5)
            Text("Creating 1 wallet")
                .tracking(1)
                .font(.system(size: 28, weight: .bold))
                .padding(.bottom, 0.5)
                .offset(x: 1)
            LottieView(name: "confirmation-loading", loopMode: .constant(.loop), isAnimating: .constant(true))
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width, height: 35)
                .id(renderUI)
                .padding(.top, 50)
                .padding(.bottom, 46)
                .offset(x: 7)
            Text(randomText)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.white60)
                .multilineTextAlignment(.center)
                .id(renderText)
                .padding(.horizontal, 25)
            Spacer()
        }
        .padding(.top, 75)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            renderUI.toggle()
        }
        .nowTimer(resolution: 2.0, now: $now)
        .onChange(of: now) { _ in updateOnboardWalletState() }
        .onChange(of: renderText) { _ in onChangeRenderText() }
    }
}

// MARK: - Methods
extension CreateWalletView {
    private func onAppearHandler() {
        renderText.toggle()
    }

    private func updateOnboardWalletState() {
        guard !viewModel.isLoading else {
            return
        }
        if (cryptoViewModel.onboardWalletState?.stepIndex ?? 0) > currentOnboardWalletState {
            withAnimation {
                currentOnboardWalletState += 1
            }
        }
        if currentOnboardWalletState == 3 {
            viewModel.createWallet()
        }
    }

    private func onChangeRenderText() {
        randomText = Constants.CreateWallet.randomCreationText.randomElement() ?? ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                renderText.toggle()
            }
        }
    }
}
