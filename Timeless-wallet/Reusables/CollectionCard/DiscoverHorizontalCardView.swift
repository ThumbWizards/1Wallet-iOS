//
//  DiscoverHorizontalCardView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 3/8/22.
//

import SwiftUI
import CollectionViewPagingLayout

struct DiscoverHorizontalCardView {
    @StateObject var viewModel: ViewModel
}

extension DiscoverHorizontalCardView {
    private var carouselItem: [DiscoverItemModel] {
        return viewModel.childrenItems ?? []
    }
}

extension DiscoverHorizontalCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.item.description ?? "")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color.descriptionCardColor)
                    Text(viewModel.item.title ?? "")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color.white)
                }
                Spacer()
            }
            .padding(.leading, 16)
            .padding(.bottom, 40)
            if viewModel.childrenItems != nil {
                HorizontalCarouselCollectionView(contentView: carouselItem.map {
                    DiscoverCardType1View(data: .init(title: $0.title,
                                                      description: $0.description,
                                                      bannerUrl: $0.bannerUrl,
                                                      ctaType: $0.ctaType,
                                                      ctaData: $0.ctaData)).eraseToAnyView()
                },
                                                 itemSize: CGSize(width: UIScreen.main.bounds.width - 32,
                                                                  height: (UIScreen.main.bounds.width - 32) * 1.24),
                                                 padding: 16)
                    .height((UIScreen.main.bounds.width - 32) * 1.24)
            } else {
                ZStack {
                    Color.searchBackground
                    AnimatedDotView()
                }
                .frame(CGSize(width: UIScreen.main.bounds.width - 32,
                              height: (UIScreen.main.bounds.width - 32) * 1.24))
                .cornerRadius(20)
                .padding(.leading, 16)
            }
        }
        .onAppear {
            if viewModel.childrenItems == nil {
                viewModel.getChildrenItems()
            }
        }
    }
}
