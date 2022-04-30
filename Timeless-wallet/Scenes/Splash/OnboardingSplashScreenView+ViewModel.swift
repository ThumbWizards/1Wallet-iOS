//
//  OnboardingSplashScreenView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 27/10/2021.
//

import SwiftUI
import Combine

extension OnboardingSplashScreenView {
    class ViewModel: ObservableObject {
    }
}

extension OnboardingSplashScreenView.ViewModel {
    func generateWalletPayloadSilent() {
        CryptoHelper.shared.generateWalletPayloadSilent()
    }
}
