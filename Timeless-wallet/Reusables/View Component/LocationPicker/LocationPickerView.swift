//
//  LocationPickerView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/15/21.
//

import SwiftUI
import MapKit

struct LocationPickerView {
    @StateObject var searchInfo = TimeZoneSearchInformation()
    @State private var currentLocation: EventLocationAnnotation?
    @State private var refreshUI = false
    var isFromSettings = false
    var onCallBack: ((EventLocationAnnotation, Bool) -> Void)?
}

extension LocationPickerView: View {
    var body: some View {
        ZStack {
            Color.primaryBackground
                .edgesIgnoringSafeArea(.all)
            VStack {
                SettingsHeaderView(title: "Location")
                    .padding(.bottom, 9)
                self.searchBar
                    .frame(height: 48)
                    .introspectTextField { (textField) in
                        textField.returnKeyType = .done
                        textField.enablesReturnKeyAutomatically = true
                    }
                ScrollView {
                    if CurrentLocationManager.default.isAuthorized {
                        locationDetailView
                            .padding(.bottom, 20)
                    }
                    if !searchInfo.searchedResults.isEmpty {
                        LocationPickerSectionView(title: "Result")
                        self.searchResultsView
                    }
                }
                .simultaneousGesture(hideKeyBoardGesture)
                VStack(spacing: 10) {
                    Divider()
                    HStack {
                        // swiftlint:disable line_length
                        Text("This setting uses your location to provide relevant weather forecast. If you want weather of a specific location, the device location permission is not needed")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color.white40)
                        Spacer()
                    }
                }
                .padding(.bottom, UIView.hasNotch ? UIView.safeAreaBottom : 10)
                .padding(.horizontal, 24)
            }
        }
        .overlay(refreshUI ? EmptyView() : EmptyView())
        .edgesIgnoringSafeArea(.bottom)
        .onReceive(NotificationCenter.default.publisher(for: .locationAuthorizationStatusChanged), perform: { _ in
            getCurrentLocation {
                refreshUI.toggle()
            }
        })
        .onAppear {
            getCurrentLocation {
                refreshUI.toggle()
            }
        }
    }

    private var searchBar: some View {
        return SearchBar(
            text: $searchInfo.searchingText,
            placeholder: "Location",
            isDisableAutocorrection: true
        )
    }

    private var locationDetailView: some View {
        VStack(spacing: 0) {
            LocationPickerSectionView(title: "Current Location")
                .padding(.bottom, 10)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(currentLocation?.title ?? "")
                        .foregroundColor(Color.white87)
                        .font(.system(size: 14, weight: .regular))
                        .lineLimit(1)

                    Text(currentLocation?.subtitle ?? "")
                        .foregroundColor(Color.white40)
                        .font(.system(size: 12, weight: .regular))
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .background(Color.almostClear)
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .background(.formForeground)
            .cornerRadius(10)
            .padding(.horizontal, 16)
            .onTapGesture {
                if let currentLocation = currentLocation {
                    onCallBack?(currentLocation, true)
                    pop()
                }
            }
            Spacer()
        }
    }

    private var searchResultsView: some View {
        LazyVStack(spacing: 16) {
            ForEach(searchInfo.searchedResults, id: \.self) { item in
                LocationPickerItemView(data: item,
                                       onSelected: { data in
                    self.onSelected(data)
                })
                if searchInfo.searchedResults.last != item {
                    Divider()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(.formForeground)
        .cornerRadius(10)
        .padding(.horizontal, 16)
    }
}

extension LocationPickerView {
    private func onSelected(_ data: TimeZoneModel,
                            _ isSelectedCurrentLocation: Bool = false) {
        let address = "\(data.city), \(data.country)"
        UserInfoService.shared.getCoordinateFrom(address: address) { coordinate, error in
            guard let coordinate = coordinate, error == nil else { return }
            // don't forget to update the UI from the main thread
            DispatchQueue.main.async {
                onCallBack?(EventLocationAnnotation(coordinate: coordinate, title: data.city), isSelectedCurrentLocation)
                pop()
            }
        }
    }

    private var hideKeyBoardGesture: some Gesture {
        DragGesture()
            .onChanged({ (_) in
                UIApplication.shared.endEditing()
            })
    }

    func getLocationInfo(currentLocation: CLLocation, completion: @escaping CLGeocodeCompletionHandler) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(currentLocation) { placemarks, error in
            completion(placemarks, error)
        }
    }

    func getCurrentLocation(_ completion: @escaping (() -> Void)) {
        if CurrentLocationManager.default.isAuthorized {
            if let location = CurrentLocationManager.default.userLocationCoordinate {
                let currentLocation = CLLocation(latitude: location.latitude,
                                                 longitude: location.longitude)
                getLocationInfo(currentLocation: currentLocation) { placemark, error in
                    if error == nil {
                        let locationAnnotation = EventLocationAnnotation(coordinate: currentLocation.coordinate,
                                                                         title: placemark!.first?.locality,
                                                                         subtitle: placemark!.first?.country)
                        self.currentLocation = locationAnnotation
                    }
                }
            }
        }
        completion()
    }
}
