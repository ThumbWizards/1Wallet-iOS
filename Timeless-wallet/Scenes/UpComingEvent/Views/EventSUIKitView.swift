//
//  EventSwiftUIView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 19/11/21.
//

import Foundation
import SwiftUI

struct EventSUIKitView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UpComingEventViewController

    func makeUIViewController(context: Context) -> UpComingEventViewController {
        if let eventView = UpComingEventViewController
            .instantiate(appStoryboard: .upComingEvent) as? UpComingEventViewController {
            return eventView
        }
        return UpComingEventViewController()
    }

    func updateUIViewController(_ uiViewController: UpComingEventViewController, context: Context) {}
}
