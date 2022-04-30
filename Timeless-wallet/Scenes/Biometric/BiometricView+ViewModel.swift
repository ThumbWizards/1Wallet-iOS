//
//  BiometricView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 10/27/21.
//

import Foundation

extension BiometricView {
    class ViewModel: ObservableObject {
        @Published var passCode = ""
    }
}
