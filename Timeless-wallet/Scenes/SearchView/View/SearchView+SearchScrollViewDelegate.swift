//
//  SearchView+SearchScrollViewDelegate.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 11/11/21.
//

import Foundation
import UIKit

class SearchScrollViewDelegate: NSObject, UIScrollViewDelegate {
    // MARK: - Variable
    var shouldDismissSearch: (() -> Void)?
    var scrollViewDidScroll: ((CGFloat) -> Void)?
    var scrollViewDidChanged: ((CGFloat) -> Void)?

    // MARK: - Functions
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y < -30 {
            shouldDismissSearch?()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidChanged?(scrollView.contentOffset.y)
        if !scrollView.isDecelerating {
            scrollViewDidScroll?(scrollView.contentOffset.y)
        }
    }
}
