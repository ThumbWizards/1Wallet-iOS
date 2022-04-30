//
//  UserInfoService.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 10/28/21.
//

import Foundation
import Combine
import CoreLocation

class UserInfoService {
    // MARK: - Variables
    class LocationModel {
        @Published var hasCompletedInitialCurrentLocation = false
        @Published var state: LocationState = .unknown
    }
    var location = LocationModel()
    var cancellables = [AnyCancellable]()

    static let shared = UserInfoService()
}

// MARK: - Enums
extension UserInfoService {
    enum LocationState {
        case unknown
        case latestCoordinate(CLLocationCoordinate2D)
    }
}

// MARK: - Computeds
extension UserInfoService {
    var latestLocation: CLLocationCoordinate2D? {
        guard case let .latestCoordinate(coordinate) = location.state else { return nil }
        return coordinate
    }
}

extension UserInfoService {
    func latestLocationSet(coordinate: CLLocationCoordinate2D?) {
        if let coordinate = coordinate {
            location.state = .latestCoordinate(coordinate)
            if !location.hasCompletedInitialCurrentLocation {
                location.hasCompletedInitialCurrentLocation = true
            }
        } else {
            location.state = .unknown
        }
    }

    func fetchCurrentLocation(_ completion: @escaping (() -> Void)) {
        CurrentLocationManager.default
            .$userLocationCoordinate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coordinate in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.latestLocationSet(coordinate: coordinate)
                completion()
            }
            .store(in: &cancellables)
        CurrentLocationManager.default.activate()
    }

    func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> Void ) {
        CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, $1) }
    }
}
