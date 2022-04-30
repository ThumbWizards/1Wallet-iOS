//
//  ButtonStyle.swift
//  Timeless-wallet
//
//  Created by Phu's Mac on 28/01/2022.
//

import SwiftUI

struct ButtonTapScaleUp: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.6 : 1)
    }
}

struct ButtonTapScaleDown: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.7 : 1)
    }
}
