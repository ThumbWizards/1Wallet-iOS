//
//  UICollectionViewCell.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 3/3/22.
//

import UIKit

protocol UINibable {
    static func uiNib() -> UINib
}


extension UICollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UICollectionViewCell: UINibable {
    static func uiNib() -> UINib {
        return UINib(nibName: self.identifier, bundle: nil)
    }
}
