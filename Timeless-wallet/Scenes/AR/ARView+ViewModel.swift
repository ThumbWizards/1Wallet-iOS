//
//  ARView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 4/1/22.
//

import Foundation

extension ARView {
    class ViewModel: ObservableObject {
        // MARK: - Variables

        var discoverItems: [Discover] {
            var items = [Discover]()
            items.append(Discover(
                id: 0,
                name: "TOY BI-PLANE",
                modelDetails: "Apple Collection",
                modelName: "toy_biplane",
                image: "tupian"))
            items.append(Discover(
                id: 1,
                name: "Toy Robot Vintage",
                modelDetails: "Apple Collection",
                modelName: "toy_robot_vintage",
                image: "robot"))
            items.append(Discover(
                id: 2,
                name: "Cup Saucer Set",
                modelDetails: "Apple Collection",
                modelName: "cup_saucer_set",
                image: "toy"))
            items.append(Discover(
                id: 3,
                name: "LE BLUE",
                modelDetails: "Timeless Living",
                modelName: "meeting_preview",
                image: "meetingPreview"))
            items.append(Discover(
                id: 4,
                name: "AIR DROP",
                modelDetails: "Timeless Living",
                modelName: "airdrop",
                image: "airdrop"))
            return items
        }
    }
}

extension ARView.ViewModel {
    static let shared = ARView.ViewModel()
}
