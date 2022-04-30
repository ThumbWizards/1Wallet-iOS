//
//  StarView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 02/02/22.
//

import Foundation
import SwiftUI

struct StarsView {
    // MARK: - Variables
    private let maxRating: Float = 5
    private let fullCount: Int
    private let emptyCount: Int
    private let halfFullCount: Int
    let rating: Float
    let color: Color

    init(rating: Float, color: Color) {
        self.rating = rating
        self.color = color
        fullCount = Int(rating)
        emptyCount = Int(maxRating - rating)
        halfFullCount = (Float(fullCount + emptyCount) < maxRating) ? 1 : 0
    }
}

extension StarsView: View {
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<fullCount) { _ in
                self.fullStar
            }
            ForEach(0..<halfFullCount) { _ in
                self.halfFullStar
            }
            ForEach(0..<emptyCount) { _ in
                self.emptyStar
            }
        }
    }
}

extension StarsView {
    private var fullStar: some View {
        Image(systemName: "star.fill").foregroundColor(color)
            .font(.sfProText(size: 12))
    }

    private var halfFullStar: some View {
        Image(systemName: "star.lefthalf.fill").foregroundColor(color)
            .font(.sfProText(size: 12))
    }

    private var emptyStar: some View {
        Image(systemName: "star").foregroundColor(color)
            .font(.sfProText(size: 12))
    }
}
