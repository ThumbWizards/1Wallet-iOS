//
//  StoryViewModel.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 29/11/21.
//

import SwiftUI

class StoryViewModel: ObservableObject {
    // MARK: - Variables
    let items: [Story] = Story.getDummyData()
    let storyGradientColors = [Color.timelessBlue, Color.gradientRedColor]
}
