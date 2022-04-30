//
//  TabViewItem.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 27/10/21.
//

import SwiftUI

struct TabViewItem: View {
    var image: String
    var name: String
    var tag: Int
    @Binding var selectedTab: Int
    @State var shouldAnimate = false

    var body: some View {
        Spacer()
        VStack(alignment: .center) {
            if selectedTab == tag {
                LottieView(name: name, loopMode: .constant(.playOnce), isAnimating: $shouldAnimate)
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .scaleEffect(selectedTab == 2 ? 1.3 : 1.05)
                    .tag(tag)
            } else {
                Image(systemName: image)
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .scaleEffect(selectedTab == 2 ? 1.4 : 1.4)
                    .tag(tag)
            }
            Text(name)
                .padding(.top, UIView.safeAreaBottom == 0 ? 0 : 3)
                .foregroundColor(tag == selectedTab ? Color.white : Color.tabDeselectColor)
                .font(.system(size: 10, weight: .medium))
        }
        .offset(y: UIView.safeAreaBottom == 0 ? -5 : 0)
        .frame(width: 80, height: 80, alignment: .center)
        .contentShape(Rectangle())
        .onTapGesture(perform: {
            selectedTab = tag
        })
        .foregroundColor(tag == selectedTab ? Color.timelessBlue : Color.tabDeselectColor)
        .tag(tag)
        .onChange(of: selectedTab) { tabIndex in
            shouldAnimate = (tabIndex == tag)
        }
        Spacer()
    }
}
