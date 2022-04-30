//
//  AppSetupView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/9/21.
//

import SwiftUI

struct AppSetupView {
    @ObservedObject private var viewModel = ViewModel.shared
    @State private var isPublic = true
    @AppStorage(ASSettings.General.appSetupState.key)
    private var appSetupState = ASSettings.General.appSetupState.defaultValue
}

extension AppSetupView: View {
    var body: some View {
        ZStack(alignment: .top) {
            if appSetupState == ASSettings.AppSetupState.username.rawValue
            || appSetupState == ASSettings.AppSetupState.security.rawValue {
                CreateUserNameView()
                    .transition(.move(edge: .trailing))
            }
            if appSetupState == ASSettings.AppSetupState.security.rawValue
            || appSetupState == ASSettings.AppSetupState.passcode.rawValue {
                ProtectWalletView()
                    .transition(.move(edge: .trailing))
            }
            VStack {
                HStack {
                    ForEach(0..<3) { index in
                        Rectangle()
                            .foregroundColor(Color.white)
                            .frame(width: 60, height: 2)
                            .opacity(indicatorIndex == index ? 1 : 0.2)
                            .animation(.linear, value: indicatorIndex == index)
                    }
                }
                .padding(.top, UIView.safeAreaTop + 23)
                Spacer()
            }
            .ignoresSafeArea()
        }
        .background(IntroduceItemsView())
        .onAppear {
            viewModel.errorType = .none
        }
    }
}

extension AppSetupView {
    private var indicatorIndex: Int {
        switch appSetupState {
        case ASSettings.AppSetupState.username.rawValue:
            return 1
        case ASSettings.AppSetupState.security.rawValue:
            return 2
        default:
            return 0
        }
    }
}
