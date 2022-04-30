//
//  ChoosePasscodeView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/10/21.
//

import Foundation

extension ChoosePasscodeView {
    class ViewModel: ObservableObject {
        @Published var passCode = ""
    }
}
