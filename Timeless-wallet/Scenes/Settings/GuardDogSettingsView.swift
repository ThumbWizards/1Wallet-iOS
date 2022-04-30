//
//  GuardDogSettingsView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 21/01/2022.
//

import SwiftUI
import Lottie
import SwiftUIX

struct GuardDogSettingsView {
    // MARK: - Properties
    @State private var renderUI = false
    @AppStorage(ASSettings.Settings.guardDog.key)
    private var guardDog = ASSettings.Settings.guardDog.defaultValue
    private let cardWidth = UIScreen.main.bounds.width - 38
    private let guardDogData = [
        GuardDogInfo(type: .whiteGuardDog,
                     name: "BEAGLE",
                     image: Image.whiteGuardDog,
                     adventurous: 80, energetic: 34, intelligent: 55, independent: 34,
                     courageous: 77, friendly: 70, loyal: 49, playful: 55),
        GuardDogInfo(type: .redGuardDog,
                     name: "BEAGLE",
                     image: Image.redGuardDog,
                     adventurous: 80, energetic: 34, intelligent: 55, independent: 34,
                     courageous: 77, friendly: 70, loyal: 49, playful: 55),
        GuardDogInfo(type: .blurGuardDog,
                     name: "BEAGLE",
                     image: Image.blurGuardDog,
                     adventurous: 80, energetic: 34, intelligent: 67, independent: 34,
                     courageous: 88, friendly: 70, loyal: 49, playful: 55,
                     isBlur: true)
    ]
}

// MARK: - Body view
extension GuardDogSettingsView: View {
    var body: some View {
        ZStack(alignment: .top) {
            Color.primaryBackground
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                SettingsHeaderView(title: "Guard dog")
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 29) {
                        ForEach(0 ..< guardDogData.count) { idx in
                            rowButton(guardDogData[idx])
                        }
                    }
                    .padding(.top, 19)
                    .padding(.bottom, UIView.hasNotch ? UIView.safeAreaBottom : 35)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

// MARK: - Subview
extension GuardDogSettingsView {
    private func rowButton(_ item: GuardDogInfo) -> some View {
        ZStack(alignment: .bottom) {
            imageBG(item)
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .leading) {
                        Text(item.name)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.87))
                            .opacity(item.isBlur ? 0 : 1)
                        Image.beagleBlur
                            .resizable()
                            .frame(width: 136.5, height: 26)
                            .offset(x: -6, y: -2)
                            .opacity(item.isBlur ? 1 : 0)
                    }
                    HStack(spacing: 0) {
                        VStack(spacing: 0) {
                            detailText(title: "Adventurous", value: item.adventurous, isBlur: item.isBlur)
                            detailText(title: "Energetic", value: item.energetic, isBlur: item.isBlur)
                            detailText(title: "Intelligent", value: item.intelligent)
                            detailText(title: "Independent", value: item.independent, isBlur: item.isBlur)
                        }
                        Spacer(minLength: 0)
                        VStack(spacing: 0) {
                            detailText(title: "Courageous", value: item.courageous)
                            detailText(title: "Friendly", value: item.friendly, isBlur: item.isBlur)
                            detailText(title: "Loyal", value: item.loyal, isBlur: item.isBlur)
                            detailText(title: "Playful", value: item.playful, isBlur: item.isBlur)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 11)
                .padding(.bottom, 18)
            }
            .background(BlurEffectView(style: .regular))
        }
        .frame(width: cardWidth)
        .overlay(
            ZStack {
                if renderUI {
                    selectedIcon
                        .offset(x: 12, y: -12)
                        .opacity(guardDog == item.type.rawValue ? 1 : 0)
                } else {
                    selectedIcon
                        .offset(x: 12, y: -12)
                        .opacity(guardDog == item.type.rawValue ? 1 : 0)
                }
            }, alignment: .topTrailing
        )
        .cornerRadius(25)
        .onTapGesture { onSelectGuardDog(item) }
        .disabled(item.isBlur)
    }

    private var selectedIcon: some View {
        LottieView(name: "guardDogSelected", loopMode: .constant(.loop), isAnimating: .constant(true))
            .scaledToFill()
            .frame(width: 95, height: 95)
    }

    private func imageBG(_ item: GuardDogInfo) -> some View {
        VStack(spacing: 0) {
            item.image
                .resizable()
                .frame(height: 470)
                .overlay(
                    Text("\(Image.lock) UNLOCK LIMITED ED.\nDOGS SIMPLY BY USING\nTHE WALLET")
                        .tracking(0.4)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                        .offset(y: -24)
                        .opacity(item.isBlur ? 1 : 0)
                )
            Rectangle()
                .foregroundColor(.black)
                .frame(height: 77)
        }
    }

    private func detailText(title: String, value: Int, isBlur: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Rectangle()
                .foregroundColor(Color.white.opacity(0.2))
                .frame(height: 1)
            HStack(spacing: 0) {
                Text(title)
                    .tracking(0.2)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .font(.system(size: 15))
                    .foregroundColor(Color.white.opacity(0.4))
                Spacer(minLength: 0)
                if !isBlur {
                    Text("\(value)")
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .font(.system(size: 15))
                        .foregroundColor(Color.white.opacity(0.4))
                        .padding(.trailing, 12)
                }
            }
        }
        .frame(width: (cardWidth - 59) / 2)
        .overlay(
            Image.blurValue
                .resizable()
                .frame(width: 30, height: 18)
                .offset(x: -8)
                .opacity(isBlur ? 1 : 0), alignment: .bottomTrailing
        )
        .padding(.top, 4)
    }
}

// MARK: - Methods
extension GuardDogSettingsView {
    private func onSelectGuardDog(_ item: GuardDogInfo) {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        if guardDog != item.type.rawValue {
            guardDog = item.type.rawValue
            UIApplication.shared.setAlternateIconName(item.type == .redGuardDog ? "redAppIcon" : nil) { error in
                if let err = error {
                    showSnackBar(.errorMsg(text: "App icon failed to change"))
                }
            }
        }
        pop()
    }
}

struct GuardDogInfo {
    var type: ASSettings.GuardDogType
    var name: String
    var image: Image
    var adventurous: Int
    var energetic: Int
    var intelligent: Int
    var independent: Int
    var courageous: Int
    var friendly: Int
    var loyal: Int
    var playful: Int
    var isBlur = false
}
