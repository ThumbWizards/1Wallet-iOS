//
//  CreateWalletView.swift
//  Timeless-wallet
//
//  Created by Phu's Mac on 28/10/2021.
//

import SwiftUI

struct ConfirmationSheetView<ContentView: View> {
    // MARK: - Input parameters
    @Binding var showModal: Bool
    @Binding var viewRender: Bool
    var modalSize: ConfirmationSheetSize = .medium
    var background = Color(UIColor.systemBackground)
    var isShowCloseButton = true
    let contentView: ContentView

    // MARK: - Properties
    @State private var keyboardHeight = CGFloat.zero
    @State private var enableAnimation = false
    @State private var enableTapOut = false
    @State private var viewTransitionComplete = false
    private let generator = UINotificationFeedbackGenerator()
    private var opacityColor: Double { viewRender ? 0.0001 : 0 }
    private var modalHeight: CGFloat {
        switch modalSize {
        case .regular: return 399 // UIScreen.main.bounds.height / (812 / 399)
        case .medium: return 440  // UIScreen.main.bounds.height / (812 / 440)
        case .large: return 536  // UIScreen.main.bounds.height / (812 / 536)
        case .customSize(let size):  return size
        }
    }

    init(
        showModal: Binding<Bool>,
        viewRender: Binding<Bool>,
        modalSize: ConfirmationSheetSize = .medium,
        background: Color = Color(UIColor.systemBackground),
        isShowCloseButton: Bool = true,
        @ViewBuilder contentView: () -> ContentView
    ) {
        self._showModal = showModal
        self._viewRender = viewRender
        self.modalSize = modalSize
        self.background = background
        self.isShowCloseButton = isShowCloseButton
        self.contentView = contentView()
    }
}

// MARK: - Body view
extension ConfirmationSheetView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            blurView
            floatingView
        }
//        .keyboardAppear(keyboardHeight: $keyboardHeight)
        .edgesIgnoringSafeArea(.bottom)
        .onChange(of: showModal) { value in
            if value {
                withAnimation(.easeInOut) { viewRender = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { enableTapOut = true }
            } else { dismiss() }
        }
    }
}

// MARK: - Subview
extension ConfirmationSheetView {
    private var blurView: some View {
        Color.white.opacity(opacityColor)
            .onTapGesture { onTapOut() }
            .opacity(viewRender ? 1 : 0)
    }

    private var floatingView: some View {
        Color.white.opacity(opacityColor)
            .frame(height: modalHeight)
            .overlay(
                ZStack(alignment: .top) {
                    background
                        .cornerRadius(radius: 34, corners: [.topLeft, .topRight])
                        .padding(.horizontal, 5)
                        .onTapGesture { UIApplication.shared.endEditing() }
                    if viewRender {
                        contentView
                            .onAppear {
                                generator.notificationOccurred(.success)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                    withAnimation(.easeInOut) { viewTransitionComplete = true }
                                }
                            }
                            .onDisappear {
                                withAnimation(.easeInOut) { viewTransitionComplete = false }
                            }
                    }
                    if isShowCloseButton {
                        closeButton
                    }
                }
            )
            .offset(y: viewTransitionComplete ? 0 : modalHeight + 100)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    enableAnimation = true
                }
            }
            .animation(enableAnimation ? .spring() : nil)
    }

    private var closeButton: some View {
        HStack {
            Spacer()
            Button(action: { dismiss() }) {
                ZStack {
                    Image("xMarkCircle")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 25)
                }
                .frame(width: 44, height: 44)
            }
            .padding(.top, 24)
            .padding(.trailing, 22)
        }
    }
}

// MARK: - Methods
extension ConfirmationSheetView {
    private func onTapOut() {
        if enableTapOut {
            dismiss()
        }
    }

    private func dismiss() {
        if keyboardHeight > 0 {
            UIApplication.shared.endEditing()
        }
        enableTapOut = false
        withAnimation(.easeInOut) { viewTransitionComplete = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut) { viewRender = false }
        }
    }
}
