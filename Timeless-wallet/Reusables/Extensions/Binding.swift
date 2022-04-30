//
//  Binding.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 27/01/22.
//

import SwiftUI

extension Binding where Value == String {
    func max(_ limit: Int) -> Self {
        if self.wrappedValue.count > limit {
            DispatchQueue.main.async {
                Utils.playHapticEvent()
                self.wrappedValue = String(self.wrappedValue.dropLast())
            }
        }
        return self
    }
}
