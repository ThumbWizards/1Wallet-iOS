//
//  UICollectionView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 3/3/22.
//

import UIKit

extension UICollectionView {
    func dequeuCellOfType<Cell: UICollectionViewCell>(_ type: Cell.Type, at indexPath: IndexPath) -> Cell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: Cell.identifier, for: indexPath) as? Cell else {
            return Cell()
        }
        return cell
    }

    func register<Cell: UICollectionViewCell>(_ type: Cell.Type) {
        register(type.uiNib(), forCellWithReuseIdentifier: type.identifier)
    }
}
