//
//  LottieView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 28/10/2021.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    // MARK: - Input parameters
    var name: String!
    @Binding var loopMode: LottieLoopMode
    @Binding var isAnimating: Bool
    var tintColor: UIColor?

    // MARK: - Properties
    var animationView = AnimationView()

    class Coordinator: NSObject {
        var parent: LottieView

        init(_ animationView: LottieView) {
            self.parent = animationView
            super.init()
        }
    }

    // MARK: - Methods
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView()

        animationView.animation = Animation.named(name)
        animationView.contentMode = .scaleAspectFit
        if let tintColor = tintColor {
            let colorProvider = ColorValueProvider(tintColor.lottieColorValue)
            animationView.setValueProvider(colorProvider,
                                           keypath: AnimationKeypath(keypath: "Heart Icon AI File Outlines.Group *.Fill *.Color"))
            animationView.setValueProvider(colorProvider,
                                           keypath: AnimationKeypath(keypath: "Shape Layer *.Ellipse *.Fill *.Color"))
        }
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        view.clipsToBounds = true

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        animationView.loopMode = self.loopMode
        isAnimating ? context.coordinator.parent.animationView.play() : context.coordinator.parent.animationView.stop()
    }
}
