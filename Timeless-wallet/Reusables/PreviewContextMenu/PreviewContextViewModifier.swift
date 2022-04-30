//
//  PreviewContextViewModifier.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 27/10/21.
//

import SwiftUI
import UIKit

struct PreviewContextViewModifier<Preview: View>: ViewModifier {
    // MARK: - Variable
    @State private var isActive: Bool = false
    @State private var longPressAnimation: Bool = false
    private let previewContent: Preview?
    private let preferredContentSize: CGSize?
    var onActionBlock: ((ContextActionType) -> Void)?
    var detailAction: (() -> Void)?
    private let actions: [UIAction]

    init(
        preview: Preview,
        preferredContentSize: CGSize? = nil,
        actions: [ContextActionType] = [],
        onActionBlock: ((ContextActionType) -> Void)?,
        detailAction: (() -> Void)?
    ) {
        self.previewContent = preview
        self.preferredContentSize = preferredContentSize
        let contextAction = actions.map { contextMenuType in
            UIAction(title: contextMenuType.title,
                     image: contextMenuType.icon,
                     attributes: contextMenuType.attributes) { _ in
                onActionBlock?(contextMenuType)
            }
        }
        self.actions = contextAction
        self.detailAction = detailAction
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        ZStack {
            content
                .scaleEffect(scaleEffect())
                .overlay(
                    PreviewContextView(
                        preview: previewContent,
                        preferredContentSize: preferredContentSize,
                        actions: actions,
                        detailAction: detailAction,
                        isActive: $isActive,
                        longPressAnimation: $longPressAnimation
                    ).opacity(0.05))
        }
    }

    private func scaleEffect() -> CGFloat {
        return longPressAnimation ? 0.9 : 1.0
    }
}
