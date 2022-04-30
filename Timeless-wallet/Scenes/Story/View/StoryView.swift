//
//  StoryView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 23/11/21.
//

import SwiftUI
import CollectionViewPagingLayout

struct StoryView {
    // MARK: - Variables
    @State private var activeCard: Story.ID? = 0
    @Binding var showStory: Bool
    @StateObject private var viewModel = StoryViewModel()
}

extension StoryView: View {
    var body: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: UIView.safeAreaTop)
                VStack {
                    HStack(spacing: 5) {
                        ForEach(enumerating: viewModel.items, id: \.id) { id, item  in
                            if item.id == activeCard {
                                Color.white
                                    .frame(height: 3)
                            } else {
                                Color.white.opacity(0.20)
                                    .frame(height: 3)
                            }
                        }
                    }
                    .padding(.horizontal, 15)
                }
                .padding(.top, 10)
                .animation(.spring())
                TransformPageView(viewModel.items, selection: $activeCard) { item, progress in
                    ZStack(alignment: .top) {
                        VStack {
                            ZStack(alignment: .bottomLeading) {
                                Image("temp")
                                    .resizable()
                                    .frame(maxWidth: .infinity)
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("MARKETS")
                                            .font(.sfProTextSemibold(size: 15))
                                            .foregroundColor(.white)
                                        Text("Apple Reports Record Profit")
                                            .font(.sfProDisplayBold(size: 22))
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                    Image.play.padding()
                                }
                                .padding(.leading, 30)
                            }
                            .frame(height: UIScreen.main.bounds.height * 0.4)
                            VStack(spacing: 15) {
                                Text("Biden vows to stand up for ‘dignity’ of Native Americans")
                                    .font(.sfProDisplayBold(size: 28))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                //swiftlint:disable line_length
                                Text("President Joe Biden sought to awareness commitment to Native Americans on Monday by announcing a step to help improve public safety and justice for their communities, which experiences violent crime a t rates more htan double the national average.")
                                    .font(.sfProText(size: 14))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(30)
                        }
                        .opacity(1 - Double(abs(progress)))
                        .scaleEffect(1 - abs(progress) * 0.3)
                        .transformEffect(.init(translationX: progress * 400, y: 0))
                        .padding(.top, 80)
                        HStack {
                            userImage
                            VStack(alignment: .leading) {
                                Text("Happening Now")
                                    .font(.sfProText(size: 16))
                                    .foregroundColor(.white)
                                Text(item.username)
                                    .font(.sfProText(size: 12))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Image.more
                        }
                        .opacity(1 - Double(abs(progress * 4)))
                        .offset(x: (progress * UIScreen.main.bounds.width))
                        .padding(15)
                        .frame(height: 50)
                        HStack {
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    guard activeCard ?? 0 > 0 else { return }
                                    activeCard! -= 1
                                }
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    guard activeCard ?? 0 < (viewModel.items.count - 1) else { return }
                                    activeCard! += 1
                                }
                        }
                    }.ignoresSafeArea()
                }
                .pagePadding(
                    top: .absolute(20),
                    left: .absolute(0),
                    bottom: .absolute(0),
                    right: .absolute(0)
                )
            }
            .gesture(dragGesture)
        }
    }
}

// MARK: - Gesture
extension StoryView {
    private var userImage: some View {
        ZStack {
            Circle()
                .strokeBorder(
                    LinearGradient(
                        gradient:
                            Gradient(
                                colors: viewModel.storyGradientColors
                            ),
                        startPoint: .init(x: 0, y: 1),
                        endPoint: .init(x: 1, y: 0)
                    ),
                    lineWidth: 3)
                .frame(width: 60, height: 60)
            Image.avatar
                .resizable()
                .frame(width: 50, height: 50)
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
                    .onChanged { _ in }
                    .onEnded { drag in
            let dragDirection = drag.location.y - drag.startLocation.y
            let velocity = CGSize(
                width:  drag.predictedEndLocation.x - drag.location.x,
                height: drag.predictedEndLocation.y - drag.location.y)
            if abs(velocity.height) > 20 {
                if dragDirection > 0 {
                    showStory.toggle()
                }
            }
        }
    }
}
