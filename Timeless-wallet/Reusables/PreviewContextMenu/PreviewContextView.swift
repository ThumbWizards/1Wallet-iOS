//
//  PreviewContextView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 27/10/21.
//

import SwiftUI

///Custom preview does not support in SwiftUI
///UIView wrapper with UIContextMenuInteraction
struct PreviewContextView<Preview: View>: UIViewRepresentable {
    // MARK: - Variables
    let preview: Preview?
    let preferredContentSize: CGSize?
    let actions: [UIAction]
    let detailAction: (() -> Void)?
    @Binding var isActive: Bool
    @Binding var longPressAnimation: Bool

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.addInteraction(
            UIContextMenuInteraction(
                delegate: context.coordinator
            )
        )
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, UIContextMenuInteractionDelegate {

        private var view: PreviewContextView<Preview>

        init(_ view: PreviewContextView<Preview>) {
            self.view = view
        }

        func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            configurationForMenuAtLocation location: CGPoint
        ) -> UIContextMenuConfiguration? {
            UIContextMenuConfiguration(
                identifier: nil,
                previewProvider: {
                    let hostingController = UIHostingController(rootView: self.view.preview)
                    if let preferredContentSize = self.view.preferredContentSize {
                        hostingController.preferredContentSize = preferredContentSize
                    }
                    return hostingController
                }, actionProvider: { _ in
                    UIMenu(title: "", children: self.view.actions)
                }
            )
        }

        func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration
        ) -> UITargetedPreview? {
            withAnimation { [weak self] in
                guard let `self` = self else { return }
                self.view.longPressAnimation = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let `self` = self else { return }
                withAnimation(Animation.easeInOut(duration: 0.3)) { [weak self] in
                    guard let `self` = self else { return }
                    self.view.longPressAnimation = false
                }
            }
            return nil
        }

        func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
            animator: UIContextMenuInteractionCommitAnimating
        ) {
            animator.addAnimations {
                if self.view.detailAction != nil {
                    self.view.detailAction?()
                } else {
                    let hostingController = UIHostingController(
                        rootView: ZStack(alignment: .topTrailing) {
                            self.view.preview
                            Button(action: {
                                dismiss()
                            }) {
                                Image.closeBackup
                                    .resizable()
                                    .foregroundColor(Color.white)
                                    .frame(width: 25, height: 25)
                            }
                            .padding(.top, 20)
                            .padding(.trailing, 20)
                        }
                    )
                    if let topVc = UIApplication.shared.getTopViewController() {
                        hostingController.modalPresentationStyle = .fullScreen
                        topVc.present(hostingController, animated: true)
                    }
                }
            }
        }
    }
}
