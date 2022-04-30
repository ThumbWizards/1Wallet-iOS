//
//  DaoTemplates.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 16/02/22.
//

import Foundation

// swiftlint:disable line_length
struct DaoTemplate {
    var title: String?
    var description: String?

    static func templateList() -> [DaoTemplate] {
        return [DaoTemplate(title: "DonationDAO", description: "Create your own philanthropic foundation through a first-of-its-kind experiment to radically reconceive and restructure charitable donation."),
                DaoTemplate(title: "LunchDAO", description: "Tired of fighting over a lunch check or mysteriously disappearing to the bathroom? Go uber-Dutch and create a DAO."),
                DaoTemplate(title: "BucketListDAO", description: "From Machu Pichu to Taj Majal, create a DAO and start planning for the post-Rona bucket list activities. Just imagine what we can do, together. Iykyk.")
        ]
    }
}
