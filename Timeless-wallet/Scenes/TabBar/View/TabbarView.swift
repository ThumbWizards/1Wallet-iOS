//
//  TabBarView.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 22/10/21.
//

import SwiftUI
import Introspect
import StreamChatUI
import StreamChat
import SwiftUIX

struct TabBarView {
    @State private var keyboardHeight = CGFloat.zero
    @ObservedObject private var viewModel = ViewModel.shared
    @GestureState private var dragTracker = CGSize.zero
    @ObservedObject private var walletInfo = WalletInfo.shared
    @State private var dragging = false
    @State private var position: CGFloat = UIScreen.main.bounds.height
    @State private var isTabBarVisible = true
    @State private var topViewPosition: CGFloat = -100
    @State private var bottomViewPosition: CGFloat = UIScreen.main.bounds.height
    @State private var dragPosition: CGFloat = 0
    @State private var topViewOpacity: CGFloat = 0
    @State private var showSearchView = false
    @State private var showEventView = false
    @State private var bottomViewAnimate = false {
        didSet {
            if bottomViewAnimate {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.bottomViewAnimate = false
                }
            }
        }
    }
    @State private var viewHeight = CGFloat.zero
    @State private var shouldScrollBottomView = false
    @State private var currentDragHeight = 0.0
    @State private var scrollingDown = false
    @State private var isKeyboardVisible = false
    @State private var bottomViewVisible = false {
        didSet {
            showEventView = bottomViewVisible
        }
    }
    @State private var swipeDown = false
    @State private var topViewVisible = false {
        didSet {
            showSearchView = topViewVisible
        }
    }
    // add lock mechanism to disable tabview swipe gesture and drag gesture conflict.
    @State var lockGestureObserver = false {
        didSet {
            if lockGestureObserver {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.lockGestureObserver = false
                }
            }
        }
    }
    @State private var bottomViewOffset: CGFloat = 0
    private var topSpace: CGFloat = -100
    @State var isFullScreenView = false {
        didSet {
            if isFullScreenView {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isFullScreenView = false
                }
            }
        }
    }
}

extension TabBarView: View, KeyboardReadable {
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            Color.tabBackgroundColor
                .ignoresSafeArea()
            VStack {
                TabView(selection: $viewModel.selectedTab) {
                    DiscoverView()
                        .tag(0)
                    WalletView()
                        .ignoresSafeArea()
                        .tag(1)
                        .background(GeometryReader { geo in
                            Color.clear.onAppear {
                                viewHeight = geo.size.height
                            }
                        })
                    chatView
                        .tag(2)
                }
                .introspectPagedTabView(customize: { _, scrollView in
                    scrollView.bounces = false
                    scrollView.backgroundColor = .tabBackgroundColor
                    if viewModel.pageScrollView == nil {
                        viewModel.pageScrollView = scrollView
                    }
                })
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                if isTabBarVisible {
                    tabbarItems
                }
            }
            .ignoresSafeArea(.container, edges: .top)
            //Disable for demo
            /*SearchView(shouldDismiss: $showSearchView, contentOffset: min(0, topViewPosition))
                .opacity(topViewOpacity)
                .animation({
                    Animation
                        .interpolatingSpring(
                            stiffness: 350,
                            damping: 40.0,
                            initialVelocity: 10.0)
                }(), value: topViewPosition != 0)
             */
//            bottomView
//                .offset(y: swipeDown ? position : max(0, position + self.dragTracker.height))
//                .animation({
//                    Animation
//                        .interpolatingSpring(
//                            stiffness: 350,
//                            damping: 40.0,
//                            initialVelocity: 10.0)
//                }(), value: !dragging)
//                .animation(.default, value: bottomViewAnimate)
        }
        .disabled(viewModel.changeAvatarTransition)
        .overlay(
            BlurEffectView(style: .systemUltraThinMaterial)
                .overlay(
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(viewModel.changeAvatarTransition ? 1.5 : 0.1)
                )
                .opacity(viewModel.changeAvatarTransition ? 1 : 0)
        )
        .onChange(of: showSearchView, perform: { value in
            if !value && topViewVisible {
                dismissTopView()
                lockGestureObserver = true
            }
            if !showSearchView {
                UIApplication.shared.endEditing()
            }
        })
        .onChange(of: showEventView, perform: { value in
            if !value && bottomViewVisible {
                dismissBottomView()
            }
            if !showEventView {
                UIApplication.shared.endEditing()
            }
        })
        .onReceive(viewModel.$selectedTab, perform: { selectedTab in
            if !viewModel.isUserLogin {
                if ChatClient.shared.connectionStatus == .connected {
                    DispatchQueue.main.async {
                        viewModel.isUserLogin = true
                    }
                }
            }
            if selectedTab == 0 || selectedTab == 1 {
                isTabBarVisible = true
            }
        })
        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            isKeyboardVisible = newIsKeyboardVisible
        }
        .onAppear {
            chatlogin()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // Refresh data wallet avatar view
                if let currentWallet = Wallet.currentWallet {
                    walletInfo.currentWallet = currentWallet
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .gesture(!lockGestureObserver && viewModel.selectedTab == 1 ? dragGesture : nil)
        .onReceive(NotificationCenter.default.publisher(for: .showSnackBar, object: nil)) { obj in
            guard let userInfo = obj.userInfo else {
                return
            }
            let messageType = userInfo["type"] as? Int
            let message = userInfo["message"] as? String ?? ""
            if messageType == StreamChatMessageType.ChatGroupMute {
                showSnackBar(.chatNotificationMute(text: message))
            } else if messageType == StreamChatMessageType.ChatGroupUnMute {
                showSnackBar(.chatNotificationUnMute(text: message))
            } else if messageType == StreamChatMessageType.RedPacketExpired {
                showSnackBar(.redPacketExpiredRandomText)
            } else if messageType == StreamChatMessageType.MessageCopied {
                showSnackBar(.chatMessageCopied)
            } else {
                showSnackBar(.message(text: message))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .hideSnackBar, object: nil)) { _ in
            hideSnackBar()
        }
        .onReceive(NotificationCenter.default.publisher(for: .reachabilityChanged, object: nil)) { _ in
            if !viewModel.isUserLogin {
                chatlogin()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .showTabbar, object: nil)) { _ in
            isTabBarVisible = true
            isFullScreenView = true
            viewModel.pageScrollView?.isScrollEnabled = isTabBarVisible
        }
        .onReceive(NotificationCenter.default.publisher(for: .hideTabbar, object: nil)) { _ in
            isTabBarVisible = false
            isFullScreenView = true
            viewModel.pageScrollView?.isScrollEnabled = isTabBarVisible
        }
        .onReceive(NotificationCenter.default.publisher(for: .disburseFundAction, object: nil)) { obj in
            guard let extraData = obj.userInfo?["extraData"] as? [String: RawJSON] else {
                return
            }
            present(CreateDisbursementView(viewModel: .init(with: extraData)))
        }
        .onReceive(NotificationCenter.default.publisher(for: .showDaoShareScreen, object: nil)) { obj in
            guard let userInfo = obj.userInfo,
                  let extraData = userInfo["extraData"] as? [String: RawJSON] else {
                return
            }
            present(DaoShareView(viewModel: .init(extraData)), presentationStyle: .fullScreen)
        }
        .onReceive(NotificationCenter.default.publisher(for: .payRequestTapAction, object: nil)) { obj in
            if let userInfo = obj.userInfo {
                viewModel.handleRequestPay(userInfo)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .showWalletQRCode, object: nil)) { obj in
            guard let userInfo = obj.object as? [String: Any],
                  let walletAddress = userInfo["walletAddress"] as? String else {
                return
            }
            var wallet = Wallet(address: walletAddress)
            wallet.name = userInfo["name"] as? String
            present(WalletQRView(viewModel: .init(wallet: wallet)), presentationStyle: .fullScreen)
        }
        .keyboardAppear(keyboardHeight: $keyboardHeight)
        .ignoresSafeArea()
    }
}

// MARK: - Views
extension TabBarView {
    //Bottom draggable view
    private var bottomView: some View {
        return UpComingEventView(
            shouldDismiss: $showEventView
        )
            .ignoresSafeArea()
    }

    private var dragGesture: some Gesture {
        return DragGesture(minimumDistance: 30)
            .updating($dragTracker) { drag, state, _ in state = drag.translation }
            .onChanged { _ in
                onDragChanged()
            }
            .onEnded(onDragEnded)
    }

    private var tabbarItems: some View {
        return HStack(alignment: .top) {
            TabViewItem(image: "sparkles.square.filled.on.square",
                        name: "Discover",
                        tag: 0,
                        selectedTab: $viewModel.selectedTab)
            TabViewItem(image: "bolt.shield.fill",
                        name: "Wallet",
                        tag: 1,
                        selectedTab: $viewModel.selectedTab)
            TabViewItem(image: "bubble.left.and.bubble.right.fill",
                        name: "Chat",
                        tag: 2,
                        selectedTab: $viewModel.selectedTab)
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .padding(.bottom, UIView.safeAreaBottom)
    }

    var chatView: some View {
        VStack(spacing: 0) {
            if viewModel.isUserLogin {
                ChatChannelListView()
                    .animation(.easeOut(duration: 0.25), value: isKeyboardVisible)
                    .maxHeight(.infinity)
                    .overlay(viewModel.isForceRefresh ? EmptyView() : EmptyView())
                Spacer()
                    .height(max(0, isFullScreenView ? 0 : keyboardHeight - UIView.safeAreaBottom))
            } else {
                EmptyView()
            }
        }
        .edgesIgnoringSafeArea(.vertical)
    }
}

// MARK: - Functions
extension TabBarView {
    private func chatlogin() {
        viewModel.chatLogin {}
    }
}

// MARK: - Gesture
extension TabBarView {
    private func bottomDragGesture(_ drag: DragGesture.Value) {
        dragging = false
        let high = UIScreen.main.bounds.height
        let low: CGFloat = 0
        let currentPosition = position
        let velocity = CGSize(
            width:  drag.predictedEndLocation.x - drag.location.x,
            height: drag.predictedEndLocation.y - drag.location.y)
        if abs(velocity.height) > 80 {
            bottomViewAnimate = true
            if !scrollingDown {
                position = high
                lockGestureObserver = true
                bottomViewVisible = false
            } else {
                position = low
                bottomViewVisible = true
            }
            return
        }
        let contentHeight = high - UIView.safeAreaTop - UIView.safeAreaBottom
        //Scroll up direction
        if !scrollingDown {
            //reset to current position base on drag position
            if bottomViewOffset < (contentHeight * 0.20) {
                position = currentPosition
                return
            }
            position = high
            bottomViewVisible = false
            lockGestureObserver = true
        } else {
            //Scroll down direction
            if bottomViewOffset > contentHeight - (contentHeight * 0.30) {
                position = currentPosition
                return
            }
            position = low
            bottomViewVisible = true
        }
    }

    private func dismissTopView() {
        withAnimation {
            topViewOpacity = 0
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            topViewPosition = topSpace
            topViewVisible = false
        }
    }

    private func dismissBottomView() {
        withAnimation(.spring()) {
            position = UIScreen.main.bounds.height
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            bottomViewVisible = false
            lockGestureObserver = true
            UpComingViewModel.shared.txtSearch = ""
        }
    }

    private func showSearchView(_ visible: Bool) {
        topViewPosition = visible ? 0 : topSpace
        topViewOpacity = visible ? 1 : 0
        topViewVisible = visible
    }

    private func topDragGesture(_ drag: DragGesture.Value) {
        dragging = false
        let velocity = CGSize(
            width:  drag.predictedEndLocation.x - drag.location.x,
            height: drag.predictedEndLocation.y - drag.location.y)
        let dragDirection = drag.location.y - drag.startLocation.y
        if abs(velocity.height) > 30 {
            if dragDirection > 0 {
                showSearchView(true)
            } else {
                showSearchView(false)
            }
            return
        }
        let topViewOffset = min(0, topViewPosition)
        if topViewOffset > -30 && !topViewVisible {
            showSearchView(true)
        } else if topViewOffset != 0 {
            showSearchView(false)
        }
    }

    private func onDragEnded(drag: DragGesture.Value) {
        if swipeDown {
            topDragGesture(drag)
        } else {
            bottomDragGesture(drag)
        }
        UpComingViewModel.shared.shouldScrollBottomView = true
    }

    private func onDragChanged() {
        if abs(dragTracker.height - currentDragHeight) > 20 {
            scrollingDown = dragTracker.height < currentDragHeight
            currentDragHeight = dragTracker.height
        }
        if dragTracker.height > 0 && !bottomViewVisible {
            if topViewPosition != 0 {
                topViewPosition = topSpace + dragTracker.height
                topViewOpacity = abs(topSpace - topViewPosition) / 100
            }
            if dragTracker.height > 100 && !topViewVisible {
                showSearchView(true)
            } else if topViewPosition < -90 && !topViewVisible && !lockGestureObserver {
                showSearchView(false)
            }
            dragPosition = dragTracker.height
            dragging = false
            swipeDown = true
        } else if !topViewVisible && topViewPosition == -100 {
            bottomViewPosition = position + self.dragTracker.height
            bottomViewOffset = position + dragTracker.height
            dragging = bottomViewOffset >= 50
            swipeDown = false
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
