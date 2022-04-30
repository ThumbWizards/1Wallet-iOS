//
//  CardsViewController.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 2/24/22.
//

import Foundation
import UIKit
import CollectionViewPagingLayout
import SwiftUI

class CardsViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    // MARK: Constants
    private struct Constants {
        static let infiniteNumberOfItems = 100_000
    }

    private let layout = CollectionViewPagingLayout()
    private var didScrollCollectionViewToMiddle = false

    var contentView: [AnyView]?
    var activeIndex: Int = 0
    var currentPage: Int = 0
    var calledSuccess: ((WalletSelectorView.PageState, Int) -> Void)?

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layout.invalidateLayoutInBatchUpdate()
        if !didScrollCollectionViewToMiddle {
            didScrollCollectionViewToMiddle = true
            collectionView?.performBatchUpdates({ [weak self] in
                self?.layout.setCurrentPage(currentPage + activeIndex,
                                            animated: false)
            })
        }
    }

    func configureViews(contentView: [AnyView], activeIndex: Int) {
        view.backgroundColor = .clear
        view.clipsToBounds = true
        self.contentView = contentView
        self.activeIndex = activeIndex
        let halfInfineNumerOfItems = Constants.infiniteNumberOfItems / 2
        self.currentPage = !contentView.isEmpty ? ((halfInfineNumerOfItems) - (halfInfineNumerOfItems % contentView.count)) : 0
        configureCollectionView()

    }

    func setCurrentPage(activeIndex: Int) {
        layout.setCurrentPage(currentPage + activeIndex,
                              animated: false)
    }

    // MARK: Private functions
    private func configureCollectionView() {
        collectionView.register(CardCollectionViewCell.self)
        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        layout.numberOfVisibleItems = self.contentView!.count
        layout.scrollDirection = .vertical
        layout.transparentAttributeWhenCellNotLoaded = true
        collectionView.collectionViewLayout = layout
        collectionView.showsVerticalScrollIndicator = false
        collectionView.clipsToBounds = false
        collectionView.backgroundColor = .clear
        collectionView.scrollsToTop = false
        collectionView.isScrollEnabled = false
    }

    func changingPageState(state: WalletSelectorView.PageState) {
        switch state {
        case .next:
            layout.goToNextPage { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.calledSuccess?(state, weakSelf.layout.currentPage % weakSelf.contentView!.count)
            }
        case .previous:
            layout.goToPreviousPage { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.calledSuccess?(state, weakSelf.layout.currentPage % weakSelf.contentView!.count)
            }
        default:
            break
        }
    }
}

extension CardsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Constants.infiniteNumberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.row % contentView!.count
        let cell = collectionView.dequeuCellOfType(CardCollectionViewCell.self, at: indexPath)
        cell.setupViews(view: contentView![index].eraseToAnyView())
        return cell
    }
}
