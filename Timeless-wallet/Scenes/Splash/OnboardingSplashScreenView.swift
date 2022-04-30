//
//  OnboardingSplashScreenView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 10/25/21.
//

import SwiftUI
import SwiftUIX

struct OnboardingSplashScreenView {
    @StateObject private var viewModel = ViewModel()
    @State var isGoToWalkthroughScreen = false
    @State var isFirstTime = true
}

extension OnboardingSplashScreenView: View {
    var body: some View {
        ZStack {
            Color.black
            NavigationLink(destination: WalkthroughScreenView().hideNavigationBar(),
                           isActive: $isGoToWalkthroughScreen) {
                EmptyView()
            }
        }
        .ignoresSafeArea()
        .onAppear {
            if isFirstTime {
                viewModel.generateWalletPayloadSilent()
                isFirstTime = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                isGoToWalkthroughScreen = true
            }
        }
    }
}
