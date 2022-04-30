//
//  LazyView.swift
//  Timeless-iOS
//
//  Created by Vo Trong Nghia on 07/09/2021.
//  Copyright © 2021 Timeless. All rights reserved.
//
import SwiftUI

struct LazyView: View {
    static var itemCacheOffset: [String: [String: CGFloat]] = [:]

    var content: AnyView
    var id: String
    @Binding var currentOffset: CGPoint
    var size: CGSize
    var coordinateSpace: String

    var body: some View {
        GeometryReader { geo -> AnyView in
            if LazyView.itemCacheOffset[coordinateSpace]?[id] == nil {
                LazyView.itemCacheOffset[coordinateSpace]?[id] = geo.frame(in: .named(coordinateSpace)).origin.y
            }
            // Only show the content view if it's visible on the screen, otherwise deallocate them to reduce the memory consumption
            if let itemOffset = LazyView.itemCacheOffset[coordinateSpace]?[id],
               itemOffset > currentOffset.y - size.height,
               itemOffset < currentOffset.y + UIScreen.main.bounds.height {
                return content
                    .deallocateOnDisappear()
                    .eraseToAnyView()
            }
            return EmptyView().eraseToAnyView()
        }
        .frame(size)
    }
}
