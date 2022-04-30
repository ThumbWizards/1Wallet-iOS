//
//  UpComingEventView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 12/11/21.
//

import SwiftUI
import Kingfisher
import GetStream
import SwiftUIX

struct UpComingEventView: View {

    @Binding var isShowEventView: Bool
    @StateObject private var viewModel = UpComingViewModel.shared
    @State private var showStory = false
    @State private var textField: UITextField?
    @State private var showFeeds = false
    private var isPopup: Bool

    init(
        shouldDismiss: Binding<Bool>,
        isPopup: Bool = false
    ) {
        self._isShowEventView = shouldDismiss
        self.isPopup = isPopup
        UpComingViewModel.shared.isPopup = isPopup
    }

    var body: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()
            GeometryReader { _ in
                VStack {
                    ZStack(alignment: .leading) {
                        Button {
                            if isPopup {
                                onTapClose()
                            } else {
                                isShowEventView = false
                            }
                        } label: {
                            Image.closeButton
                                .padding(.leading, 10)
                        }
                        Text("Harmonauts")
                            .font(.sfProDisplayBold(size: 24))
                            .foregroundColor(Color.white)
                            .opacity(0.87)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .frame(height: 45)
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity, alignment: .center)
                    HStack {
                        HStack {
                            Image.iconSearch
                            TextField("Search", text: $viewModel.txtSearch)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                        }
                        .padding(10)
                        .frame(height: 42)
                        .background(
                            Color.almostClear
                                .padding(.horizontal, 4)
                                .onTapGesture {
                                    textField?.becomeFirstResponder()
                                }
                        )
                        .background(Color.searchBackground)
                        .clipShape(Capsule())
                        Image.notificationEvent
                    }
                    .padding(.horizontal, 15)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 20) {
                            ForEach(viewModel.story) { story in
                                VStack {
                                    ZStack {
                                        Circle()
                                            .strokeBorder(
                                                LinearGradient(
                                                    gradient:
                                                        Gradient(
                                                            colors: [Color.timelessBlue,
                                                                     Color.gradientRedColor]
                                                        ),
                                                    startPoint: .init(x: 0, y: 1),
                                                    endPoint: .init(x: 1, y: 0)),
                                                lineWidth: 3)
                                            .frame(width: 60, height: 60)
                                        Image.avatar
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                    }
                                    Text(story.username)
                                        .font(.sfProText(size: 11))
                                        .foregroundColor(Color.white)
                                }.onTapGesture {
                                    withAnimation(.easeInOut) {
                                        showStory.toggle()
                                        UIApplication.shared.endEditing()
                                    }
                                }
                            }
                        }.padding()
                    }.frame(height: viewModel.story.isEmpty ? 0 : 100)
                    EventSUIKitView()
                }
                .padding(.top, UIView.safeAreaTop)
            }
            if showStory {
                StoryView(showStory: $showStory.animation(.easeInOut))
                    .transition(.opacity)
                    .ignoresSafeArea()
            }
        }
        .introspectTextField { textField in
            if self.textField == nil {
                self.textField = textField
            }
        }
        .onChange(of: isShowEventView, perform: { onAppear in
            if onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showFeeds = true
                }
            } else {
                showFeeds = false
                viewModel.txtSearch = ""
                viewModel.isShowEventView = onAppear
            }
        })
        .onAppear(perform: {
            if isPopup {
                viewModel.getUserFeeds()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showFeeds = true
                    isShowEventView = true
                }
            }
        })
        .ignoresSafeArea()
    }
}

// MARK: - Methods
extension UpComingEventView {
    private func onTapClose() { dismiss() }
}
