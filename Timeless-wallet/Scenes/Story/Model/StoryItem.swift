//
//  StoryItem.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 23/11/21.
//

import Foundation

struct Story: Identifiable {
    let id: Int
    let title: String
    let username: String

    //Dummy Data 
    static func getDummyData() -> [Story] {
        return ["Welcome", "Community", "Development", "Vibe"].enumerated().compactMap {
            return Story(id: $0, title: "Happening Now", username: $1)
        }
    }
}
