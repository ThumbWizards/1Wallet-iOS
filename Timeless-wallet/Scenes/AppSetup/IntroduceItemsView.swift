//
//  IntroduceItemsView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/9/21.
//

import SwiftUI

struct IntroduceItemsView {
    @AppStorage(ASSettings.General.appSetupState.key)
    private var appSetupState = ASSettings.General.appSetupState.defaultValue
}

extension IntroduceItemsView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .maxHeight(58)
            HStack {
                Text("Few ")
                    .foregroundColor(Color.white)
                +
                Text("{ ")
                    .foregroundColor(Color.introduceItem)
                +
                Text("Very ")
                    .foregroundColor(Color.searchFieldBorder)
                +
                Text("Important ")
                    .foregroundColor(Color.white)
                +
                Text("} ")
                    .foregroundColor(Color.introduceItem)
                +
                Text("Laundry Items")
                    .foregroundColor(Color.white)
            }
            .font(.system(size: 28, weight: .bold))
            //                .foregroundColor(Color.white)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 39)
            Spacer()
                .maxHeight(29)
                .layoutPriority(-1)
            Text("To ensure you have a wonderful experience on 1Wallet, we ask you to take a minute on the following:")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white87)
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 58.5)
            Spacer()
                .maxHeight(50)
                .layoutPriority(-1)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    verticalBlocks(image: Image.faceSmiling
                                    .resizable()
                                    .frame(width: 26, height: 26)
                                    .eraseToAnyView(),
                                   title: "User name",
                                   // swiftlint:disable line_length
                                   subtitle: "Create that perfect user name for 1Wallet. This is how you communicate with other users")
                        .padding(.bottom, 41)
                    verticalBlocks(image: Image.lockShield
                                    .resizable()
                                    .frame(width: 22, height: 26)
                                    .eraseToAnyView(),
                                   title: "Security",
                                   subtitle: "Your wallet is protected with all the latest security features of iOS")
                        .padding(.bottom, 41)
                    verticalBlocks(image: Image.keyiCloud
                                    .resizable()
                                    .frame(width: 32, height: 22)
                                    .eraseToAnyView(),
                                   title: "Backup",
                                   subtitle: "Exported data is encrypted with a client generated key. Peace of mind without the need to remember the seed / private key")
                }
            }
            Spacer(minLength: 15)
            Button {
                withAnimation {
                    appSetupState = ASSettings.AppSetupState.username.rawValue
                }
            } label: {
                HStack {
                    Text("Let’s Go")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color.white)
                }
                .frame(width: UIScreen.main.bounds.width - 84, height: 42)
                .background(Color.timelessBlue.cornerRadius(20.5))
            }
            .padding(.bottom, UIView.hasNotch ? 10 : 35)
        }
        .padding(.top, UIView.safeAreaTop)
        .padding(.bottom, UIView.safeAreaBottom)
        .width(UIScreen.main.bounds.width)
        .height(UIScreen.main.bounds.height)
        .background(Color.introduceBG.ignoresSafeArea())
    }
}

extension IntroduceItemsView {
    private func verticalBlocks(image: AnyView, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            image
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color.white)
            Text(subtitle)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.white60)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)
        }
        .padding(.horizontal, 34)
    }
}
