//
//  SubtleBlinkAndBounceViewModifier.swift
//  Timeless-iOS
//
// Created by Brian Sipple on 5/21/20.
// Copyright © 2020 Timeless. All rights reserved.
//

import SwiftUI


struct SubtleBlinkAndBounceViewModifier {
    @State private var animationProgress: CGFloat = 0.0

    var duration: TimeInterval
}


// MARK: - Static Properties
extension SubtleBlinkAndBounceViewModifier {
    static let defaultAnimationDuration: TimeInterval = 1.45
}


// MARK: - Computeds
extension SubtleBlinkAndBounceViewModifier {

    var blinkAndBounceAnimation: Animation {
        Animation
            .easeOut(duration: duration)
            .delay(0.667)
            .repeatForever(autoreverses: true)
    }
}


// MARK: - ViewModifier
extension SubtleBlinkAndBounceViewModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .opacity(Double(self.animationProgress))
            .offset(x: 0, y: self.animationProgress * 12.0)
            .animation(blinkAndBounceAnimation)
            .onAppear {
                self.animationProgress = 1.0
            }
    }
}
