//
//  SurveyModel.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 3/8/22.
//

import Foundation

struct SurveyModel {
    var title: String
    var description: String
    var options: [String]
    var urlImage: String
}

extension SurveyModel {
    static var sample = SurveyModel(title: "Still looking for something?",
                                    description: "Let’s make the feed together! Which services do you want to see most on the app?",
                                    options: [
                                        "Harmony Events",
                                        "Learning Series",
                                        "Nearby Fun",
                                        "Restaurant / Food Recommendations",
                                        "Concert & Outdoor Entertainments",
                                    ],
                                    urlImage: "https://res.cloudinary.com/timeless/video/upload/v1647243106/app/Wallet/Discover/WORKING_SEARCH.mp4"
    )
}
