//
//  CarouselFlowLayout.swift
//  Timeless-iOS
//
//  Created on 6/1/21.
//  Copyright © 2021 Timeless. All rights reserved.
//

import UIKit

@objc protocol CarouselFlowLayoutDelegate: AnyObject {
    func carouselFlowLayoutSizeOfItem(_ carouselFlowLayout: CarouselFlowLayout) -> CGSize
    @objc optional func carouselFlowLayoutScrollToIndex(_ carouselFlowLayout: CarouselFlowLayout, index: Int)
}

class CarouselFlowLayout: UICollectionViewFlowLayout {
    private var isPaging = false
    private var isScaleContent = false
    private var otherItemsScaleRatio: CGFloat = 1
    private var horizontalPaddingItem: CGFloat = 5
    private var verticalPadding: CGFloat = 5
    private var cachingAttributes: [UICollectionViewLayoutAttributes] = []
    private var padding: CarouselFlowLayoutPadding = .center(0)
    var currentPoint: CGPoint = .zero
    weak var delegate: CarouselFlowLayoutDelegate?

    enum CarouselFlowLayoutPadding {
        case center(CGFloat)
        case left(CGFloat)
        case right(CGFloat)
    }

    init(padding: CarouselFlowLayoutPadding,
         isPaging: Bool,
         isScaleContent: Bool,
         otherItemsScaleRatio: CGFloat,
         horizontalPaddingItem: CGFloat,
         verticalPadding: CGFloat) {
        super.init()
        self.padding = padding
        self.isPaging = isPaging
        self.isScaleContent = isScaleContent
        self.otherItemsScaleRatio = otherItemsScaleRatio
        self.horizontalPaddingItem = horizontalPaddingItem
        self.verticalPadding = verticalPadding
        scrollDirection = .horizontal
        minimumLineSpacing = horizontalPaddingItem
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension CarouselFlowLayout {
    override func prepare() {
        guard let collectionView = collectionView else { return }
        itemSize = delegate?.carouselFlowLayoutSizeOfItem(self) ??
            CGSize(width: collectionView.frame.width - 100,
                   height: collectionView.frame.height - 10)
        switch padding {
        case .center(let value):
            collectionView.contentInset.left = collectionView.frame.width / 2 - itemSize.width / 2 + value
        case .left(let value):
            collectionView.contentInset.left = value
        case .right(let value):
            collectionView.contentInset.left = collectionView.frame.width - itemSize.width - value
        }
        collectionView.contentInset.right = collectionView.frame.width - collectionView.contentInset.left - itemSize.width
        if currentPoint.x == 0 {
            currentPoint.x = -collectionView.contentInset.left
        }
        super.prepare()
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        guard let attributes = super.layoutAttributesForElements(in: rect),
              let rectAttributes = NSArray(array: attributes, copyItems: true) as? [UICollectionViewLayoutAttributes]
        else { return nil }
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)

        // Get leading offset by padding value
        let leading: CGFloat
        switch padding {
        case .center(let value):
            leading = collectionView.frame.width / 2 - itemSize.width / 2 + value
        case .left(let value):
            leading = value
        case .right(let value):
            leading = collectionView.frame.width - itemSize.width - value
        }
        let maxValue = leading + itemSize.width
        for attributes in rectAttributes where attributes.frame.intersects(visibleRect) {
            // Distance between the attributes with visibleRect
            let distance = visibleRect.minX + leading - attributes.frame.origin.x
            let percentage = distance / maxValue
            let percentForScale = 1 - (1 - otherItemsScaleRatio) * percentage.magnitude
            if isScaleContent {
                // Use transform3D to scale width (scale content)
                attributes.transform3D = CATransform3DMakeScale(1, percentForScale, 1)
            } else {
                // Change width and height, not scale content
                let currentWith = percentForScale * itemSize.width
                let currentHeight = percentForScale * itemSize.height
                attributes.frame.size.width = currentWith
                attributes.frame.size.height = currentHeight

                if percentage > 0 {
                    attributes.frame.origin.x += (itemSize.width - currentWith)
                }
                attributes.center.y = collectionView.center.y
            }
        }

        return rectAttributes
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView, isPaging else {
            return proposedContentOffset
        }

        // Add some snapping behaviour so that the zoomed cell is always centered
        let targetRect = CGRect(x: collectionView.contentOffset.x,
                                y: 0,
                                width: collectionView.frame.width,
                                height: collectionView.frame.height)
        guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else {
            return currentPoint
        }
        if (proposedContentOffset.x < 0 || collectionView.contentOffset.x > proposedContentOffset.x) &&
            proposedContentOffset.x < collectionView.contentSize.width - collectionView.frame.width {
            // Back
            guard let first = rectAttributes.first else { return currentPoint }
            if first.indexPath.row == 0 {
                delegate?.carouselFlowLayoutScrollToIndex?(self, index: 0)
                currentPoint = CGPoint(x: -collectionView.contentInset.left, y: proposedContentOffset.y)
            } else {
                currentPoint = CGPoint(x: first.frame.origin.x - collectionView.contentInset.left, y: proposedContentOffset.y)
            }
            delegate?.carouselFlowLayoutScrollToIndex?(self, index: first.indexPath.row)
        } else if collectionView.contentOffset.x < proposedContentOffset.x {
            // Next
            guard rectAttributes.count > 1 else { return currentPoint }
            currentPoint = CGPoint(x: rectAttributes[1].frame.origin.x - collectionView.contentInset.left,
                                   y: proposedContentOffset.y)
            delegate?.carouselFlowLayoutScrollToIndex?(self, index: rectAttributes[1].indexPath.row)
        } else {
            // Current
            return currentPoint
        }
        return currentPoint
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // Invalidate layout so that every cell get a chance to be zoomed when it reaches the center of the screen
        true
    }

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        guard let context = super.invalidationContext(forBoundsChange: newBounds)
                as? UICollectionViewFlowLayoutInvalidationContext else {
            return super.invalidationContext(forBoundsChange: newBounds)
        }
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
}
