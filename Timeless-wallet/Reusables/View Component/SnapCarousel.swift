//
//  SnapCarousel.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/1/21.
//

import SwiftUI
import MapKit

class UIStateModel: ObservableObject {
    init(cardWidth: CGFloat,
         cardHeight: CGFloat,
         firstSpacing: CGFloat,
         spacing: CGFloat,
         hiddenCardScale: CGFloat
    ) {
        self.cardWidth = cardWidth
        self.cardHeight = cardHeight
        self.firstSpacing = firstSpacing
        self.spacing = spacing
        self.hiddenCardScale = hiddenCardScale
    }
    var cardWidth: CGFloat = UIScreen.main.bounds.width - 68
    var cardHeight: CGFloat = UIScreen.main.bounds.width - 68
    var firstSpacing: CGFloat = 16
    var spacing: CGFloat = 20
    var hiddenCardScale: CGFloat = 0.9
    @Published var activeCard: Int = 0
    @Published var screenDrag: Float = 0.0
}

struct SnapCarousel<Items: View>: View {
    let items: Items
    let numberOfItems: CGFloat

    @GestureState var isDetectingGesture = false

    @EnvironmentObject var UIState: UIStateModel

    init(numberOfItems: CGFloat, @ViewBuilder _ items: () -> Items) {
        self.items = items()
        self.numberOfItems = numberOfItems
    }

    var body: some View {
        let totalSpacing = (numberOfItems - 1) * UIState.spacing
        let totalCanvasWidth: CGFloat = (UIState.cardWidth * numberOfItems) + totalSpacing
        let xOffsetToShift = (totalCanvasWidth - UIScreen.main.bounds.width) / 2
        let leftPadding = UIState.activeCard == 0 ? UIState.firstSpacing : (UIScreen.main.bounds.width - UIState.cardWidth) / 2
        let totalMovement = UIState.cardWidth + UIState.spacing

        let activeOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard))
        let nextOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard) + 1)

        var calcOffset = Float(activeOffset)

        if calcOffset != Float(nextOffset) {
            calcOffset = Float(activeOffset) + UIState.screenDrag
        }

        return HStack(alignment: .center, spacing: UIState.spacing) {
            items
        }
        .offset(x: CGFloat(calcOffset), y: 0)
        .highPriorityGesture(DragGesture()
                                .updating($isDetectingGesture) { currentState, _, _ in
            self.UIState.screenDrag = Float(currentState.translation.width)
        }
                                .onEnded { value in
            self.UIState.screenDrag = 0

            if value.translation.width < -50 {
                self.UIState.activeCard = min(self.UIState.activeCard + 1, Int(numberOfItems) - 1)
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }

            if value.translation.width > 50 {
                self.UIState.activeCard = max(self.UIState.activeCard - 1, 0)
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }
        })
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: UIState.cardHeight, alignment: .center)
        .clipped()
    }
}

struct SnapCarouselItem<Content: View>: View {
    @EnvironmentObject var UIState: UIStateModel
    var id: Int
    var content: Content

    init(id: Int, @ViewBuilder _ content: () -> Content) {
        self.content = content()
        self.id = id
    }

    var body: some View {
        content
            .cornerRadius(19)
            .frame(width: UIState.cardWidth, height: UIState.cardHeight, alignment: .leading)
    }
}

struct CarouselItem: Identifiable, Equatable {
    let id: Int
    let wallet: Wallet
}
