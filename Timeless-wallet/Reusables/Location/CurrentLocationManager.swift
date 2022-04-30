//
//  CurrentLocationManager.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 10/26/21.
//

import SwiftUI
import Combine
import CoreLocation

extension Notification.Name {
    static let locationAuthorizationStatusChanged = Notification.Name("kTimelessLocationAuthorizationStatusChanged")
}

final class CurrentLocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    // MARK: - Published Outputs
    @Published var userLocationCoordinate: CLLocationCoordinate2D?
}


// MARK: - Static Properties
extension CurrentLocationManager {
    static let `default`: CurrentLocationManager = .init()
}

// MARK: - Computeds
extension CurrentLocationManager {
    var locationAuthStatus: CLAuthorizationStatus { locationManager.authorizationStatus }
    var isAuthorized: Bool {
        locationAuthStatus == .authorizedAlways || locationAuthStatus == .authorizedWhenInUse
    }
}

// MARK: - Public Methods
extension CurrentLocationManager {

    func activate() {
        locationManager.delegate = self
        locationAuthorizationStatusChanged(to: locationAuthStatus)
    }
}

// MARK: - Private Helpers
private extension CurrentLocationManager {
    func requestLocationTrackingAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestLocation()
    }

    func locationAuthorizationStatusChanged(to newStatus: CLAuthorizationStatus) {
        switch newStatus {
        case .notDetermined:
            requestLocationTrackingAuthorization()
        case .authorizedAlways,
             .authorizedWhenInUse:
            startUpdatingLocation()
            NotificationCenter.default.post(Notification(name: .locationAuthorizationStatusChanged))
        case .denied,
             .restricted:
            NotificationCenter.default.post(Notification(name: .locationAuthorizationStatusChanged))
        @unknown default:
            requestLocationTrackingAuthorization()
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension CurrentLocationManager: CLLocationManagerDelegate {

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let currentLocationCoordinate = locations.last?.coordinate else { return }
        userLocationCoordinate = currentLocationCoordinate
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError {
            switch error.code {
            case .denied:
//                log.infoMessage("User denied location permission")
                print("User denied location permission")
            case .locationUnknown:
//                log.infoMessage("Location manager failed to determine location, locationUnknown:")
                print("Location manager failed to determine location, locationUnknown:")
            default:
//                log.error(TimelessMessage(name: "Location Manager failed with CLError.",
//                                          attributes: .error(error)))
                print("Location Manager failed with CLError.")
            }
            print("User denied location permission")
//            log.infoMessage("User denied location permission")
        } else {
//            log.error(TimelessMessage(name: "Location Manager failed with error.", attributes: .error(error)))
            print("Location Manager failed with error.")
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        locationAuthorizationStatusChanged(to: status)
    }
}
