//
//  CardCollectionViewCell.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 2/24/22.
//

import Foundation
import UIKit
import CollectionViewPagingLayout
import SwiftUI

class CardCollectionViewCell: UICollectionViewCell {
    // MARK: Lifecycle
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var backgroundContainerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: Private functions
    func setupViews(view: AnyView) {
        clipsToBounds = false
        contentView.clipsToBounds = false
        backgroundColor = .clear
        self.imageView.fit(subview: view)
        self.backgroundContainerView.backgroundColor = .clear
    }
}

extension CardCollectionViewCell: TransformableView {
    func transform(progress: CGFloat) {
        backgroundContainerView.transform = CGAffineTransform(translationX: 0, y: progress * 50)
    }

    func zPosition(progress: CGFloat) -> Int {
        if progress < -0.5 {
            return -10
        }
        return Int(-abs(round(progress)))
    }
}
