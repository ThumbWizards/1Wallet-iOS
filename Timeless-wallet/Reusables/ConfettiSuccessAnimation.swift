//
//  ConfettiSuccessAnimation.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 30/11/21.
//

import UIKit
import Lottie

class ConfettiSuccessAnimation: UIView {

    // MARK: - Variables
    lazy var animationView: AnimationView = {
        let animationView = AnimationView()
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.isUserInteractionEnabled = false
        return animationView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    func setup() {
        isUserInteractionEnabled = false
        addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            animationView.topAnchor.constraint(equalTo: topAnchor),
            animationView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        animationView.animation = Animation.named("confetti-cannons")
        animationView.loopMode = .playOnce
        animationView.play { isFinished in
            if isFinished {
                UIApplication.shared.stopConfettiAnimation()
            }
        }
    }
}
