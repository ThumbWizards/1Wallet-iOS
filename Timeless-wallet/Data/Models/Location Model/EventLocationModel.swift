//
//  EventLocationModel.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/15/21.
//

import Foundation
import MapKit
import SwiftUI

final class EventLocationAnnotation: NSObject, MKAnnotation {
    let id = UUID()
    // MARK: - MKAnnotation
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var distance: Double
    var placemark: CLPlacemark?

    // MARK: - Init
    init(coordinate: CLLocationCoordinate2D,
         title: String? = nil,
         subtitle: String? = nil,
         distance: Double = 0,
         placemark: CLPlacemark? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.distance = distance
        self.placemark = placemark
        super.init()
    }
}

extension EventLocationAnnotation: Identifiable {}

extension EventLocationAnnotation {
    var mkPointAnnotation: MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = coordinate
        return annotation
    }
}
