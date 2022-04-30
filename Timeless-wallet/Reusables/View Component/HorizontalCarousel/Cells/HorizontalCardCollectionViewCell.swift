//
//  HorizontalCardCollectionViewCell.swift
//  Timeless-iOS
//
//  Created by Tu Nguyen on 10/26/20.
//

import SwiftUI

// MARK: - BaseCardCollectionCellDelegate
protocol HorizontalCardCollectionViewCellDelegate: AnyObject {
    func didSelectItem(at cell: HorizontalCardCollectionViewCell)
}

class HorizontalCardCollectionViewCell: UICollectionViewCell {
    var host: UIHostingController<AnyView>?
}
