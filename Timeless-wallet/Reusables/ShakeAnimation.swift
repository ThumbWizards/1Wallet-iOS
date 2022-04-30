//
//  ShakeAnimation.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 10/26/21.
//

import SwiftUI

struct ShakeAnimation: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
                                                amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                                              y: 0))
    }
}
