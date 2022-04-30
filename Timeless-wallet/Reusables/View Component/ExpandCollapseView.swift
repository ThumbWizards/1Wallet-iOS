//
//  ExpandCollapseView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 10/01/2022.
//

import SwiftUI

struct ExpandCollapseView<Content: View> {
    // MARK: - Input Parameters
    var title: String
    var subTitle: String
    var titleFont: Font
    var titleColor: Color
    var subTitleFont: Font
    var subTitleColor: Color
    var lineColor: Color
    var iconSize: CGSize
    var iconFont: Font
    var iconColor: Color
    var barPaddingLeading: CGFloat
    var barPaddingTrailing: CGFloat
    var verticalSpacing: CGFloat
    let content: Content

    // MARK: - Properties
    @State private var isExpand = true
    @State private var barHeight: CGFloat?

    init(
        title: String = "",
        subTitle: String = "",
        titleFont: Font = .system(size: 17, weight: .semibold),
        titleColor: Color = Color.white,
        subTitleFont: Font = .system(size: 15, weight: .semibold),
        subTitleColor: Color = Color.white.opacity(0.5),
        lineColor: Color = Color.timelessBlue,
        iconSize: CGSize = CGSize(width: 21, height: 21),
        iconFont: Font = .system(size: 22),
        iconColor: Color = Color.white.opacity(0.87),
        barPaddingLeading: CGFloat = 23.5,
        barPaddingTrailing: CGFloat = 22,
        verticalSpacing: CGFloat = 12,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subTitle = subTitle
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.subTitleFont = subTitleFont
        self.subTitleColor = subTitleColor
        self.lineColor = lineColor
        self.iconSize = iconSize
        self.iconFont = iconFont
        self.iconColor = iconColor
        self.barPaddingLeading = barPaddingLeading
        self.barPaddingTrailing = barPaddingTrailing
        self.verticalSpacing = verticalSpacing
        self.content = content()
    }
}

// MARK: - Body view
extension ExpandCollapseView: View {
    var body: some View {
        ZStack(alignment: .top) {
            if isExpand {
                content.padding(.top, verticalSpacing + (barHeight ?? 0) + 5)
            }
            ZStack {
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: .infinity)
                        .foregroundColor(lineColor)
                        .frame(width: 2, height: 20)
                        .padding(.trailing, 12.5)
                    Text(title)
                        .font(titleFont)
                        .lineLimit(1)
                        .foregroundColor(titleColor)
                    if !subTitle.isEmpty {
                        RoundedRectangle(cornerRadius: .infinity)
                            .foregroundColor(titleColor)
                            .frame(width: 2, height: 2)
                            .padding(.leading, 7)
                            .padding(.trailing, 9)
                        Text(subTitle)
                            .font(subTitleFont)
                            .lineLimit(1)
                            .foregroundColor(subTitleColor)
                    }
                    Spacer()
                    Image.chevronDownCircle
                        .resizable()
                        .frame(width: iconSize.width, height: iconSize.height)
                        .foregroundColor(iconColor)
                        .font(iconFont)
                        .rotationEffect(.radians(isExpand ? 0 : Double.pi / -2))
                }
                .padding(.leading, barPaddingLeading)
                .padding(.trailing, barPaddingTrailing)
                .padding(.bottom, -5)
            }
            .overlay(
                GeometryReader { geo in
                    Color.almostClear
                        .onAppear { barHeight = geo.size.height }
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                Utils.playHapticEvent()
                                isExpand.toggle()
                            }
                        }
                }
            )
            .frame(height: barHeight)
        }
    }
}
