//
//  WeatherSettingsView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/12/21.
//

import SwiftUI

struct WeatherSettingsView {
    @State private var toggleValue = true
    @State var shouldGoToUnitScreen = false
    @AppStorage(ASSettings.Settings.selectedWeatherType.key)
    private var selectedWeather = ASSettings.Settings.selectedWeatherType.defaultValue
    @AppStorage(ASSettings.Settings.isShowingWeather.key)
    private var isShowingWeather = ASSettings.Settings.isShowingWeather.defaultValue
    @AppStorage(ASSettings.Settings.titleLocation.key)
    private var titleLocation = ASSettings.Settings.titleLocation.defaultValue
    var list = [
        WeatherList(index: 1, type: WeatherType.Celsius),
        WeatherList(index: 2, type: WeatherType.Fahrenheit),
    ]

    struct WeatherList: Identifiable {
        var id = UUID()
        var index: Int
        var type: WeatherType

        var name: String {
            return type.rawValue
        }
    }
}

extension WeatherSettingsView: View {
    var body: some View {
        ZStack(alignment: .top) {
            Color.primaryBackground
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                SettingsHeaderView(title: "Weather")
                    .padding(.bottom, 17)
                if shouldGoToUnitScreen {
                    unitScreen
                } else {
                    weatherScreen
                }
            }
            VStack(spacing: 10) {
                Spacer()
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
        .edgesIgnoringSafeArea(.bottom)
        .onChange(of: isShowingWeather) { value in
            if value && !CurrentLocationManager.default.isAuthorized {
                CurrentLocationManager.default.activate()
            }
        }
    }
}

extension WeatherSettingsView {
    private var unitScreen: some View {
        VStack(spacing: 0) {
            ForEach(list, id: \.id) {item in
                Button(action: {
                    self.selectedWeather = item.type.rawValue
                    pop()
                }) {
                    HStack {
                        Text(item.name)
                            .font(.system(size: 17))
                            .foregroundColor(Color.white)
                        Spacer()
                        Image.checkmark
                            .foregroundColor(Color.white60)
                            .font(.system(size: 14, weight: .regular))
                            .opacity(self.selectedWeather == item.type.rawValue ? 1 : 0)
                            .padding(.trailing, 22)
                    }
                    .foregroundColor(.white)
                }
                .padding(.leading, 17)
                .frame(height: 51)
                if list.last!.type != item.type {
                    Divider()
                        .padding(.leading, 16)
                        .padding(.trailing, 22)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width - 32)
        .background(Color.formForeground)
        .cornerRadius(12)
    }

    private var weatherScreen: some View {
        VStack(spacing: 20) {
            VStack {
                ZStack {
                    HStack {
                        Text("Display Weather")
                            .font(.system(size: 17))
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .foregroundColor(Color.white)
                            .padding(.trailing, 5)
                        Spacer(minLength: 5)
                        ZStack {
                            Toggle("", isOn: $isShowingWeather)
                                .toggleStyle(SwitchToggleStyle(tint: Color.timelessBlue))
                                .scaleEffect(0.8)
                                .offset(x: -11)
                        }
                        .frame(width: 80, height: 51, alignment: .trailing)
                        .overlay(Color.almostClear)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                isShowingWeather.toggle()
                            }
                        }
                    }
                }
                .padding(.leading, 17)
                .frame(height: 51)
            }
            .frame(width: UIScreen.main.bounds.width - 32)
            .background(Color.formForeground)
            .cornerRadius(12)

            VStack {
                ZStack {
                    HStack {
                        Text("Unit")
                            .font(.system(size: 17))
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .foregroundColor(Color.white)
                            .padding(.trailing, 5)
                        Spacer(minLength: 5)
                        HStack(spacing: 8) {
                            Text("\(selectedWeather)")
                                .font(.system(size: 15))
                                .foregroundColor(Color.white40)
                                .lineLimit(1)
                            Image.chevronRight
                                .resizable()
                                .frame(width: 7, height: 12)
                                .foregroundColor(Color.white60)
                        }
                        .padding(.trailing, 22)
                    }
                }
                .padding(.leading, 17)
                .frame(height: 51)
                .background(Color.almostClear)
                .onTapGesture {
                    push(WeatherSettingsView(shouldGoToUnitScreen: true).hideNavigationBar())
                }
                Rectangle()
                    .foregroundColor(Color.settingDivider)
                    .frame(height: 1)
                    .padding(.leading, 17)
                    .padding(.trailing, 22)
                ZStack {
                    HStack {
                        Text("Location")
                            .font(.system(size: 17))
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .foregroundColor(Color.white)
                            .padding(.trailing, 5)
                        Spacer(minLength: 5)
                        HStack(spacing: 8) {
                            Text(titleLocation)
                                .font(.system(size: 15))
                                .foregroundColor(Color.white40)
                                .lineLimit(1)
                            Image.chevronRight
                                .resizable()
                                .frame(width: 7, height: 12)
                                .foregroundColor(Color.white60)
                        }
                        .padding(.trailing, 22)
                    }
                }
                .padding(.leading, 17)
                .frame(height: 51)
                .background(Color.almostClear)
                .onTapGesture {
                    push(LocationPickerView(
                        isFromSettings: true,
                        onCallBack: { location, isSelectedCurrentLocation in
                            updateLocationWeather(location, isSelectedCurrentLocation)
                        }).hideNavigationBar())
                }
            }
            .frame(width: UIScreen.main.bounds.width - 32)
            .background(Color.formForeground)
            .cornerRadius(12)
            .opacity(isShowingWeather ? 1 : 0.3)
            .disabled(!isShowingWeather)
        }
    }
}

extension WeatherSettingsView {
    private func updateLocationWeather(_ location: EventLocationAnnotation, _ isSelectedCurrentLocation: Bool) {
        let coordinate = location.coordinate
        if isSelectedCurrentLocation {
            SettingsService.shared.locationSet(location: nil, title: nil)
        } else {
            SettingsService.shared.locationSet(location: coordinate, title: location.title)
        }
        UserInfoService.shared.latestLocationSet(coordinate: coordinate)
    }
}
