//
//  AnimatedDotView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 3/14/22.
//

import SwiftUI

struct AnimatedDotView: View {
    @State private var shouldAnimate = false

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color.placeHolderBalanceBG)
                .frame(width: 15, height: 15)
                .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                .animation(Animation.easeInOut(duration: 0.3).repeatForever(), value: shouldAnimate)
            Circle()
                .fill(Color.placeHolderBalanceBG)
                .frame(width: 15, height: 15)
                .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                .animation(Animation.easeInOut(duration: 0.3).repeatForever().delay(0.3), value: shouldAnimate)
            Circle()
                .fill(Color.placeHolderBalanceBG)
                .frame(width: 15, height: 15)
                .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                .animation(Animation.easeInOut(duration: 0.3).repeatForever().delay(0.6), value: shouldAnimate)
        }
        .onAppear {
            self.shouldAnimate = true
        }
    }
}
