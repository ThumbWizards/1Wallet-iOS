//
//  SearchViewModel.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 23/11/21.
//

import UIKit
import SwiftUI

class SearchViewModel: ObservableObject {

    // MARK: - Variables
    var contentOffset: CGFloat!
    var items: [GridItem] = [
        GridItem.init(.flexible(), spacing: nil, alignment: .center),
        GridItem.init(.flexible(), spacing: nil, alignment: .center)
    ]
    var axes: Axis.Set {
        return contentOffset == 0.0 ? .vertical : []
    }
    var scrollViewBottomPadding: CGFloat {
        return axes.isEmpty ? 100 : 0
    }

}
