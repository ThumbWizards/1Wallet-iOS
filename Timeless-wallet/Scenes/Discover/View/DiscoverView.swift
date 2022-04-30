//
//  DiscoverView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 26/10/21.
//

import SwiftUI
import CollectionViewPagingLayout
import ARKit
import Nuke
import ASCollectionView_SwiftUI

struct DiscoverView {
    // MARK: - Variables
    @AppStorage(ASSettings.Survey.selected.key)
    private var selectedSurvey = ASSettings.Survey.selected.defaultValue
    @StateObject private var viewModel = ViewModel.shared
    @State private var disappeared = false
}

extension DiscoverView: View {
    var body: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()
            ASTableView {
                headerSeaction
                discoverSection
                loadmoreSection
                surveySection
            }
            .onReachedBottom {
                if viewModel.isHasNextPage {
                    viewModel.getDiscoverItems(isFetchNextPage: true)
                }
            }
            .separatorsEnabled(false)
            .onPullToRefresh { endRefreshing in
                viewModel.getDiscoverItems {
                    endRefreshing()
                }
            }
            .contentInsets(UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0))
            .scrollIndicatorEnabled(false)
            .hidden(disappeared)
        }
        .loadingOverlay(isShowing: viewModel.loadingState == .initing)
        .ignoresSafeArea()
        .onAppear {
            disappeared = false
            switch viewModel.loadingState {
            case .initing, .error:
                viewModel.getDiscoverItems()
            default: break
            }
        }
        .onDisappear {
            disappeared = true
        }
    }
}

extension DiscoverView {
    private var headerSeaction: ASTableViewSection<Int> {
        ASTableViewSection(id: 0) {
            HStack {
                Text("Discover")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.white)
                    .padding(.leading, 26)
                Spacer()
            }
            .padding(.bottom, 10)
        }
    }

    private var discoverSection: ASTableViewSection<Int> {
        if let discoverItem = viewModel.discoverItem {
            switch discoverItem.type {
            case "list":
                if let items = discoverItem.children?.items {
                    return ASTableViewSection(id: 1,
                                              data: items) { item, _ in
                        switch item.blockType {
                        case "carousel":
                            DiscoverHorizontalCardView(viewModel: .init(item: item))
                                .padding(.top, 35)
                                .padding(.bottom, item.id == items.last?.id ? 0 : 30)
                        case "card":
                            DiscoverCardType1View(data: .init(title: item.title,
                                                              description: item.description,
                                                              bannerUrl: item.bannerUrl,
                                                              ctaType: item.ctaType,
                                                              ctaData: item.ctaData))
                                .padding(.bottom, item.id == items.last?.id ? 0 : 30)
                        case "card_overflow":
                            DiscoverCardType2View(data: .init(superscript: item.extraData?["superscript"] as? String,
                                                              title: item.title,
                                                              bannerUrl: item.bannerUrl))
                                .padding(.bottom, item.id == items.last?.id ? 0 : 30)
                        default:
                            EmptyView()
                        }
                    }
                }
            default: break
            }
        }
        return ASTableViewSection(id: 1) {
            EmptyView()
        }
    }

    private var loadmoreSection: ASTableViewSection<Int> {
        ASTableViewSection(id: 2) {
            if viewModel.isHasNextPage {
                Color.clear
                    .frame(height: 0)
                    .loadingOverlay(isShowing: viewModel.loadingState == .paging, background: Color.clear)
                    .padding(.top, 33)
                    .padding(.bottom, 17)
            }
        }
    }

    private var surveySection: ASTableViewSection<Int> {
        ASTableViewSection(id: 3) {
            if viewModel.isShowSurveyView,
               !selectedSurvey {
                SurveyView(surveyModel: SurveyModel.sample)
                    .padding(.top, 75)
            }
        }
    }
}
