//
//  Loading+ViewModifier.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 25/10/2021.
//

import SwiftUI
import SwiftUIX

extension View {
    func loadingOverlay(isShowing: Bool, background: Color = Color.black.opacity(0.3)) -> some View {
        self.modifier(
            LoadingViewModifier(isShowing: isShowing, background: background)
        )
    }
}

struct LoadingViewModifier: ViewModifier {
    let isShowing: Bool
    let background: Color

    func body(content: Content) -> some View {
        content
            .disabled(isShowing)
            .overlay(isShowing ? LoadingIndicator(background: background) : nil)
    }
}

struct LoadingIndicator: View {
    let background: Color
    var body: some View {
        ZStack {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.2)
        }
            .frame(width: 70, height: 70)
            .background(background)
            .cornerRadius(10)
    }
}
