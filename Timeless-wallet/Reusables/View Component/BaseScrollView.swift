//
//  BaseScrollView.swift
//  Timeless-iOS
//
//  Created by Phu Tran on 18/06/2021.
//  Copyright © 2021 Timeless. All rights reserved.
//

import SwiftUI
import Combine

class BaseScrollViewModel: ObservableObject {
    var headerHeight: CGFloat = 55
    @Published var headerOffsetY = CGFloat.zero
    @Published var isScrolling = false

    static let discoverShared = BaseScrollViewModel()
}

struct BaseScrollView<Content: View, Header: View, Toolbar: View> {
    let header: Header
    let content: Content
    var toolbar: Toolbar?
    var sharedViewModel: BaseScrollViewModel?
    var scrolledToBottom: (() -> Void)?
    var onOffsetChanged: ((CGPoint) -> Void)?
    private let isStickyHeader: Bool
    private let isIgnoreHeader: Bool
    private let colorBackground: Color
    private let viewBackground: AnyView?
    private let bottomThreshold: Binding<CGFloat>
    private let isShowEndText: Binding<Bool>
    private let endTextPaddingBottom: CGFloat?
    // swiftlint:disable weak_delegate
    @State private var baseScrollViewDelegate: BaseScrollViewDelegate?
    @State private var headerHeight = CGFloat.zero
    @State private var toolbarHeight = CGFloat.zero
    @State private var currentOffsetPublisher = Just(CGPoint.zero).eraseToAnyPublisher()
    @State private var headerOffsetY = CGFloat.zero
    @State private var toolbarOffsetY = CGFloat.zero
    @State private var lastOffset = CGPoint.zero
    @State private var scrollView: UIScrollView?
    @State private var scrollUp = false
    @State private var disAppeared = false
    @State private var opacityEndText = Double.zero

    init(
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content,
        toolbar: (() -> Toolbar)? = nil,
        isStickyHeader: Bool = false,
        isIgnoreHeader: Bool = false,
        colorBackground: Color = .clear,
        bottomThreshold: Binding<CGFloat> = .constant(0),
        viewBackground: AnyView? = nil,
        isShowEndText: Binding<Bool> = .constant(true),
        endTextPaddingBottom: CGFloat = 10,
        scrolledToLoadMore: (() -> Void)? = nil,
        onOffsetChanged: ((CGPoint) -> Void)? = nil,
        sharedViewModel: BaseScrollViewModel? = nil
    ) {
        self.header = header()
        self.content = content()
        self.toolbar = toolbar?()
        self.isStickyHeader = isStickyHeader
        self.isIgnoreHeader = isIgnoreHeader
        self.colorBackground = colorBackground
        self.bottomThreshold = bottomThreshold
        self.viewBackground = viewBackground
        self.isShowEndText = isShowEndText
        self.endTextPaddingBottom = endTextPaddingBottom
        self.scrolledToBottom = scrolledToLoadMore
        self.onOffsetChanged = onOffsetChanged
        self.sharedViewModel = sharedViewModel
    }
}

// Support optional toolbar
extension BaseScrollView where Toolbar == EmptyView {
    init(
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content,
        isStickyHeader: Bool = false,
        isIgnoreHeader: Bool = false,
        colorBackground: Color = .clear,
        bottomThreshold: Binding<CGFloat> = .constant(0),
        viewBackground: AnyView? = nil,
        isShowEndText: Binding<Bool> = .constant(true),
        endTextPaddingBottom: CGFloat = 10,
        scrolledToLoadMore: (() -> Void)? = nil,
        onOffsetChanged: ((CGPoint) -> Void)? = nil,
        sharedViewModel: BaseScrollViewModel? = nil
    ) {
        self.header = header()
        self.content = content()
        self.toolbar = nil
        self.isStickyHeader = isStickyHeader
        self.isIgnoreHeader = isIgnoreHeader
        self.colorBackground = colorBackground
        self.bottomThreshold = bottomThreshold
        self.viewBackground = viewBackground
        self.isShowEndText = isShowEndText
        self.endTextPaddingBottom = endTextPaddingBottom
        self.scrolledToBottom = scrolledToLoadMore
        self.onOffsetChanged = onOffsetChanged
        self.sharedViewModel = sharedViewModel
    }
}

extension BaseScrollView: View {
    var body: some View {
        ZStack(alignment: .top) {
            if viewBackground != nil {
                viewBackground
            } else {
                colorBackground
            }
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    content
                }
                .padding(.top, isIgnoreHeader ? 0 : headerHeight)
                .padding(.bottom, toolbarHeight)
            }
            .overlay(VStack {
                header
                    .offset(y: isStickyHeader ? headerOffsetY : lastOffset.y)
                    .background(GeometryReader { geo in
                        Color.clear.onAppear {
                            headerHeight = geo.size.height
                        }
                    })
                    .opacity(isStickyHeader ? Double(1 - abs(headerOffsetY / headerHeight)) : 1)
                Spacer()
            })
            VStack {
                Spacer()
                toolbar
                    .offset(y: isStickyHeader ? -toolbarOffsetY : -lastOffset.y)
                    .background(GeometryReader { geo in
                        Color.clear.onAppear {
                            toolbarHeight = geo.size.height
                        }
                    })
                    .opacity(isStickyHeader ? Double(1 - abs(toolbarOffsetY / toolbarHeight)) : 1)
            }
            .introspectScrollView {
                guard !disAppeared, baseScrollViewDelegate == nil else { return }
                baseScrollViewDelegate = BaseScrollViewDelegate()
                baseScrollViewDelegate?.onOffsetChanged = {
                    offsetChanged(currentOffset: $0)
                }
                baseScrollViewDelegate?.scrollViewWillEndDragging = {
                    if headerOffsetY != 0, headerOffsetY != -headerHeight {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            headerOffsetY = scrollUp ? -headerHeight : 0
                        }
                    }
                    if let sharedViewModel = sharedViewModel,
                       sharedViewModel.headerOffsetY != 0, sharedViewModel.headerOffsetY != -sharedViewModel.headerHeight {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            sharedViewModel.headerOffsetY = scrollUp ? -sharedViewModel.headerHeight : 0
                            if scrollUp, scrollView!.contentOffset.y < sharedViewModel.headerHeight {
                                scrollView?.contentInset.top = -sharedViewModel.headerHeight + 10
                            } else {
                                scrollView?.contentInset.top = 0
                            }
                        }
                    }
                    if toolbarOffsetY != 0, toolbarOffsetY != -toolbarHeight {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            toolbarOffsetY = scrollUp ? -toolbarHeight : 0
                        }
                    }
                }
                baseScrollViewDelegate?.sharedViewModel = sharedViewModel
                $0.delegate = baseScrollViewDelegate
                $0.verticalScrollIndicatorInsets = UIEdgeInsets(
                    top: headerHeight,
                    left: 0.0,
                    bottom: 0.0,
                    right: 0.0
                )
                scrollView = $0
            }
            .onAppear {
                if disAppeared {
                    disAppeared = false
                }
            }
            .onDisappear {
                disAppeared = true
                baseScrollViewDelegate = nil
            }
        }
    }

    private func offsetChanged(currentOffset: CGPoint) {
        guard !disAppeared, let scrollView = scrollView else { return }
        onOffsetChanged?(currentOffset)
        let maximumOffsetY = scrollView.contentSize.height - scrollView.frame.size.height
        guard currentOffset.y < maximumOffsetY - bottomThreshold.wrappedValue else {
            lastOffset.y = maximumOffsetY
            withAnimation(.easeInOut(duration: 0.35)) {
                headerOffsetY = 0
                toolbarOffsetY = 0
                sharedViewModel?.headerOffsetY = 0
            }
            if abs(1 - (currentOffset.y / lastOffset.y)) * 100 > 1 {
                opacityEndText = 1
            } else {
                opacityEndText = Double(abs(1 - (currentOffset.y / lastOffset.y)) * 100)
            }
            scrolledToBottom?()
            return
        }
        guard currentOffset.y > 0 else {
            lastOffset.y = 0
            withAnimation(.easeInOut(duration: 0.35)) {
                headerOffsetY = 0
                toolbarOffsetY = 0
                sharedViewModel?.headerOffsetY = 0
            }
            return
        }
        let newHeaderOffsetY = headerOffsetY - (currentOffset.y - lastOffset.y)
        let newSharedHeaderOffsetY = (sharedViewModel?.headerOffsetY ?? 0) - (currentOffset.y - lastOffset.y)
        let newToolbarOffsetY = toolbarOffsetY - (currentOffset.y - lastOffset.y)
        scrollUp = currentOffset.y - lastOffset.y > 0
        lastOffset = currentOffset
        headerOffsetY = min(0, max(-headerHeight, newHeaderOffsetY))
        sharedViewModel?.headerOffsetY = min(0, max(-(sharedViewModel?.headerHeight ?? 0), newSharedHeaderOffsetY))
        toolbarOffsetY = min(0, max(-toolbarHeight, newToolbarOffsetY))
    }
}

extension BaseScrollView {
    private class BaseScrollViewDelegate: NSObject, UIScrollViewDelegate {
        var onOffsetChanged: ((_ currentOffset: CGPoint) -> Void)?
        var scrollViewWillEndDragging: (() -> Void)?
        var sharedViewModel: BaseScrollViewModel?

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            sharedViewModel?.isScrolling = true
        }

        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            scrollViewWillEndDragging?()
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate { scrollViewDidEndScrolling(scrollView) }
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            scrollViewDidEndScrolling(scrollView)
        }

        func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            scrollViewDidEndScrolling(scrollView)
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            DispatchQueue.main.async {
                self.onOffsetChanged?(scrollView.contentOffset)
            }
        }

        func scrollViewDidEndScrolling(_ scrollView: UIScrollView) {
            sharedViewModel?.isScrolling = false
        }
    }
}
