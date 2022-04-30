//
//  CharityListView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 27/01/22.
//

import SwiftUI

extension CharityListView {
    class ViewModel: ObservableObject {
        // MARK: - Variables
        var columnGrid = [GridItem(.flexible())]
        var charityList = ["https://res.cloudinary.com/timeless/image/upload/v1643962926/1wallet_profile_avatar/gwyglazehb9vllle1sou.jpg",
                           "https://res.cloudinary.com/timeless/image/upload/v1643963122/1wallet_profile_avatar/shenj0gmyox4fdkcfiyc.jpg"]
    }
}
