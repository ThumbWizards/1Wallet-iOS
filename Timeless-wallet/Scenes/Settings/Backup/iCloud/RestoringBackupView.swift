//
//  RestoringBackupView.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 12/01/2022.
//

import SwiftUI

struct RestoringBackupView {
    // MARK: - Properties
    @SwiftUI.Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var renderUI = false
    @ObservedObject var viewModel: ViewModel
}

// MARK: - Body view
extension RestoringBackupView: View {
    var body: some View {
        ZStack(alignment: .top) {
            restoringBackupView
        }
        .height(493)
    }
}

// MARK: - Subview
extension RestoringBackupView {
    private var restoringBackupView: some View {
        VStack(spacing: 0) {
            Image.backUpLock
                .resizable()
                .frame(width: 43, height: 43)
                .aspectRatio(1, contentMode: .fit)
                .padding(.top, 53)
                .padding(.bottom, 27)
            Text("Restoring Backup")
                .tracking(0.9)
                .font(.system(size: 28, weight: .bold))
                .padding(.bottom, 8)
            Text("Your wallet is being securely restored…")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.white60)
            Spacer()
                .maxHeight(71)
            if renderUI {
                loadingView
            } else {
                loadingView
            }
            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                viewModel.restore()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            renderUI.toggle()
        }
    }

    private var loadingView: some View {
        LottieView(name: "confirmation-loading", loopMode: .constant(.loop), isAnimating: .constant(true))
            .scaledToFill()
            .frame(width: UIScreen.main.bounds.width, height: 35)
            .offset(x: 7)
    }
}
