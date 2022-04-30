//
//  DAOTemplates.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 02/02/22.
//

import SwiftUI
import CollectionViewPagingLayout

struct DAOTemplates {
    // MARK: - Properties
    @State private var activeCard: CarouselItem.ID? = 0
    private var options: ScaleTransformViewOptions {
        return ScaleTransformViewOptions(
            minScale: 0.95,
            maxScale: 1,
            translationRatio: CGPoint(x: 0.95, y: 0.8),
            maxTranslationRatio: CGPoint(x: 2, y: 0),
            scaleCurve: .linear,
            translationCurve: .linear
        )
    }
    private let daoTemplates: [DaoTemplate] = DaoTemplate.templateList()
    private var carouselItem: [CarouselItem] {
        return daoTemplates.enumerated().compactMap { result in
            return .init(id: result.offset, wallet: Wallet.init(address: "invalid"))
        }
    }
}

// MARK: - Body view
extension DAOTemplates: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                headerView
                allTemplates
                    .padding(.top, 20)
            }
            .height(436)
            closeButton
        }
    }
}

// MARK: - Subview
extension DAOTemplates {
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("DAO")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.white)
                    .lineLimit(1)
                Text("Easy, fast DAO setup")
                    .font(.system(size: 15))
                    .foregroundColor(Color.white60)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.leading, 26)
        .padding(.trailing, 59)
        .padding(.bottom, 4)
    }

    private var closeButton: some View {
        Button(action: { onTapClose() }) {
            Image.closeBackup
                .resizable()
                .frame(width: 25, height: 25)
                .padding(.vertical, 28)
                .padding(.horizontal, 31)
                .background(Color.almostClear)
        }
    }

    private var allTemplates: some View {
        return VStack {
            ScalePageView(carouselItem, selection: $activeCard) { item in
                ZStack(alignment: .topTrailing) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(daoTemplates[item.id].title ?? "")
                                .font(.sfProText(size: 18))
                                .foregroundColor(Color.daoDiscoverableDesc)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(4)
                                .padding(.top, 15)
                            Spacer()
                        }
                        Text(daoTemplates[item.id].description ?? "")
                            .tracking(-0.4)
                            .multilineTextAlignment(.leading)
                            .font(.sfProText(size: 13))
                            .foregroundColor(Color.daoDiscoverableDesc)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 5)
                        Color.daoSeparatorColor
                            .frame(height: 1)
                            .padding(.top, 10)
                        HStack {
                            Text("by Timeless")
                                .font(.sfProText(size: 12))
                                .foregroundColor(Color.daoDiscoverableDesc)
                            StarsView(rating: 4.5, color: Color.daoDiscoverableDesc)
                            Spacer()
                        }
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                    }
                    .padding(.leading, 25)
                    .padding(.trailing, 50)
                    .frame(width: UIScreen.main.bounds.width - 63)
                    Image.heart
                        .font(.system(size: 24))
                        .foregroundColor(Color.hashtagLength)
                        .padding(.trailing, 15)
                        .padding(.top, 15)
                }
                .background(Color.daoTemplateBg)
                .cornerRadius(15)
            }
            .onTapPage({ page in
                createDaoView(daoTemplates[page])
            })
            .collectionView(\.contentInset, UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 0))
            .options(options)
            .pagePadding(horizontal: .absolute(20))
            .frame(height: 188)
            .padding(.horizontal, 5)
            HStack(alignment: .top) {
                Group {
                    Image.infoCircle
                    Text("Note: for your security, every DAO is set up with multisig wallet.")
                        .font(.sfProText(size: 14))
                }
                .foregroundColor(Color.white40)
            }
            .padding(.top, 10)
            .padding(.horizontal, 45)
            HStack {
                Spacer()
                ForEach(carouselItem.indices, id: \.self) { index in
                    Rectangle()
                        .frame(width: activeCard == index ? 18 : 6, height: 6)
                        .cornerRadius(.infinity)
                        .foregroundColor(activeCard == index ? Color.carouselRectangle : Color.carouselCircle)
                        .animation(.easeInOut(duration: 0.2), value: activeCard)
                }
                Spacer()
            }
            .padding(.top, 15)
            .padding(.bottom, 15)
        }
    }
}

// MARK: - Methods
extension DAOTemplates {
    private func onTapClose() {
        hideConfirmationSheet()
    }

    private func createDaoView(_ model: DaoTemplate) {
        hideConfirmationSheet()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            present(CreateDonationView(
                viewModel: .init(placeholder: model.title ?? "")),
                    presentationStyle: .fullScreen)
        }
    }
}
