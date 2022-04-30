//
//  ProtectWalletView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/9/21.
//

import SwiftUI
import Combine

struct ProtectWalletView {
    @State private var acceptPrivacy = false
    @AppStorage(ASSettings.General.appSetupState.key)
    private var appSetupState = ASSettings.General.appSetupState.defaultValue
    @State private var dismissCancellable: AnyCancellable?
}

extension ProtectWalletView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
                .maxHeight(55)
            Image.protectWalletImage
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 296, height: 282)
                .padding(.bottom, 23)
                .padding(.horizontal, 39)
            Text("Protect your wallet")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.white)
                .padding(.bottom, 10)
                .padding(.horizontal, 39)
            // swiftlint:disable line_length
            Text("Add an extra layer of security to keep your assets safe. App Security is the first layer of security, controlling and securing access to your wallet. Your PIN must be 6 digits long.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white87)
                .padding(.horizontal, 39)
            VStack(spacing: 0) {
                Spacer()
                Button(action: {
                    Utils.playHapticEvent()
                    withAnimation {
                        acceptPrivacy.toggle()
                    }
                }) {
                    HStack(alignment: .top, spacing: 10.5) {
                        Image(systemName: acceptPrivacy ? "checkmark.square.fill" : "square")
                            .resizable()
                            .foregroundColor(Color.primary)
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 17)
                        Text("I understand that I must choose a 6-digit PIN code and safeguard it at all times. ")
                            .tracking(-0.2)
                            .lineSpacing(5)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.white87)
                            .foregroundColor(Color.primary)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                }
                .padding(.leading, 24)
                Spacer()
                    .maxHeight(30)
                Button {
                    appSetupState = ASSettings.AppSetupState.passcode.rawValue
                    dismissCancellable = dismiss()?.sink(receiveValue: { _ in
                        present(ChoosePasscodeView(shouldTriggerICloudBackup: true),
                                presentationStyle: .overFullScreen)
                    })
                } label: {
                    HStack {
                        Text("Protect wallet")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color.white)
                    }
                    .frame(width: UIScreen.main.bounds.width - 48, height: 48)
                    .background((acceptPrivacy ? Color.timelessBlue : Color.confirmationSheetCancelBG ).cornerRadius(15))
                }
                .disabled(!acceptPrivacy)
                .opacity(!acceptPrivacy ? 0.3 : 1)
            }
            .padding(.bottom, UIView.hasNotch ? 10 : 35)
        }
        .padding(.top, UIView.safeAreaTop)
        .padding(.bottom, UIView.safeAreaBottom)
        .ignoresSafeArea()
        .background(Color.introduceBG)
    }
}
