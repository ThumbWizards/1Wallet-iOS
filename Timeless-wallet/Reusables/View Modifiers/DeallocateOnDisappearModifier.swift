//
//  DeallocateOnDisappearModifier.swift
//  Timeless-iOS
//
//  Created by Vo Trong Nghia on 02/03/2021.
//  Copyright © 2021 Timeless. All rights reserved.
//

import SwiftUI


struct DeallocateOnDisappear: ViewModifier {
    @State var hasDisappeared = false

    @ViewBuilder
    func body(content: Content) -> some View {
        if hasDisappeared {
            EmptyView()
        } else {
            content.onDisappear { hasDisappeared = true }
        }
    }
}

extension View {
    func deallocateOnDisappear() -> some View {
        return modifier(DeallocateOnDisappear())
    }
}
