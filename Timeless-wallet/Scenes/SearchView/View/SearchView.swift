//
//  SearchView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 10/11/21.
//

import SwiftUI

struct SearchView {
    @Binding var isShowSearch: Bool
    @State private var txtSearch: String = ""
    @State private var animateSearch: Bool = false
    @State private var scaleAnimation: Bool = false
    @State private var textField: UITextField?
    private var scrollViewDelegateObject = SearchScrollViewDelegate()
    @ObservedObject var viewModel = SearchViewModel()
}

extension SearchView {
    init(
        shouldDismiss: Binding<Bool>,
        contentOffset: CGFloat
    ) {
        self._isShowSearch = shouldDismiss
        viewModel.contentOffset = contentOffset
    }
}

extension SearchView: View {
    var body: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()
            GeometryReader { proxy in
                VStack {
                    HStack {
                        HStack {
                            Image.iconSearch
                            TextField("Search", text: $txtSearch)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .accentColor(Color.timelessBlue)
                        }
                        .padding(10)
                        .frame(height: 36)
                        .background(
                            Color.almostClear
                                .padding(.horizontal, 4)
                                .onTapGesture {
                                    textField?.becomeFirstResponder()
                                }
                        )
                        .background(Color.searchBackground)
                        .clipShape(Capsule())
                        Image.close
                            .onTapGesture(perform: {
                                isShowSearch = false
                            })
                            .scaleEffect(scaleAnimation ? 1.5 : 1)
                    }
                    .padding(.horizontal, 15)
                    ScrollView(viewModel.axes, showsIndicators: false) {
                        VStack {
                            LazyVGrid(columns: viewModel.items, spacing: nil) {
                                ForEach(0..<30, id: \.self) { _ in
                                    VStack {
                                        Image.avatar
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                        Text("@Username")
                                            .font(.body)
                                    }
                                    .padding(10)
                                    .background(Color.red)
                                    .cornerRadius(10)
                                    .frame(width: 100, height: 100)
                                }
                            }
                            Color.clear
                                .frame(height: 100)
                        }
                    }
                    .introspectScrollView {
                        setupScrollView($0)
                    }
                    .frame(
                        width: proxy.size.width,
                        height: proxy.size.height + viewModel.scrollViewBottomPadding
                    )
                }
            }
            .offset(y: viewModel.contentOffset)
            .padding(.top, 40)
        }
        .introspectTextField { textField in
            if self.textField == nil {
                self.textField = textField
            }
        }
        .onChange(of: animateSearch, perform: { shouldAnimate in
            if shouldAnimate {
                animateCloseButton()
            }
        })
        .ignoresSafeArea()
    }
}

// MARK: - Functions
extension SearchView {
    private func animateCloseButton() {
        withAnimation {
            self.scaleAnimation = true
            let impactMed = UIImpactFeedbackGenerator(style: .soft)
            impactMed.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(Animation.easeInOut(duration: 0.3)) {
                self.scaleAnimation = false
            }
        }
    }

    private func setupScrollView(_ scrollView: UIScrollView) {
        scrollView.keyboardDismissMode = .onDrag
        scrollView.delegate = scrollViewDelegateObject
        scrollViewDelegateObject.shouldDismissSearch = {
            isShowSearch = false
            txtSearch = ""
            animateSearch = false
        }
        scrollViewDelegateObject.scrollViewDidScroll = { offset in
            if offset < -50 && !animateSearch && isShowSearch {
                DispatchQueue.main.async {
                    animateSearch = true
                }
            } else if offset > 0 {
                DispatchQueue.main.async {
                    animateSearch = false
                }
            }
        }
    }
}
