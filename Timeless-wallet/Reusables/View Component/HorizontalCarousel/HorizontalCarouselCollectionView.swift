//
//  HorizontalCarouselCollectionView.swift
//  Timeless-iOS
//
//  Created by Tuan Diep on 10/26/20.
//  Copyright © 2020 Timeless. All rights reserved.
//

import SwiftUI

struct HorizontalCarouselCollectionView: UIViewRepresentable {
    typealias UIViewType = UICollectionView
    var contentView: [AnyView]
    var itemSize: CGSize
    var padding: CGFloat = 14
    var didSelectItem: ((Int) -> Void)?
    private (set) var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())

    func makeUIView(context: UIViewRepresentableContext<HorizontalCarouselCollectionView>) -> UICollectionView {
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        context.coordinator.collectionView = collectionView
        collectionView.register(HorizontalCardCollectionViewCell.uiNib(),
                                forCellWithReuseIdentifier: HorizontalCardCollectionViewCell.identifier)
        let flowLayout = CarouselFlowLayout(padding: .left(padding),
                                            isPaging: true,
                                            isScaleContent: false,
                                            otherItemsScaleRatio: 1,
                                            horizontalPaddingItem: 8,
                                            verticalPadding: 0)
        flowLayout.delegate = context.coordinator
        collectionView.setCollectionViewLayout(flowLayout, animated: true)
        collectionView.delegate = context.coordinator
        collectionView.dataSource = context.coordinator
        return collectionView
    }

    func updateUIView(_ uiView: UICollectionView, context: Context) {
    }

    func makeCoordinator() -> HorizontalCarouselCollectionView.Coodinator {
        Coodinator(self)
    }

    class Coodinator: NSObject {
        var didSelectItem: ((Int) -> Void)?
        weak var collectionView: UICollectionView?
        private var control: HorizontalCarouselCollectionView

        init(_ control: HorizontalCarouselCollectionView) {
            self.control = control
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HorizontalCarouselCollectionView.Coodinator: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        control.contentView.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeuCellOfType(HorizontalCardCollectionViewCell.self, at: indexPath)
        let rootView = control.contentView[indexPath.row]
        guard cell.host == nil else {
            cell.host?.rootView = rootView
            return cell
        }
        let controller = UIHostingController(rootView: rootView,
                                             ignoreSafeArea: true,
                                             ignoreKeyboardAvoidance: true)
        cell.host = controller

        controller.view.willMove(toSuperview: cell.contentView)
        cell.contentView.addSubview(controller.view)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
        controller.view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
        controller.view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
        controller.view.backgroundColor = .clear
        controller.view.didMoveToSuperview()
        controller.view.layoutIfNeeded()

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        control.didSelectItem?(indexPath.row)
    }
}

// MARK: - CarouselFlowLayoutDelegate
extension HorizontalCarouselCollectionView.Coodinator: CarouselFlowLayoutDelegate {
    func carouselFlowLayoutSizeOfItem(_ carouselFlowLayout: CarouselFlowLayout) -> CGSize {
        return control.itemSize
    }
}

// MARK: - BaseCardCollectionCellDelegate
extension HorizontalCarouselCollectionView.Coodinator: HorizontalCardCollectionViewCellDelegate {
    func didSelectItem(at cell: HorizontalCardCollectionViewCell) {
        // perform select item
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        didSelectItem?(indexPath.row)
    }
}
