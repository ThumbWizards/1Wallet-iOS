//
//  UpComingViewModel.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 16/11/21.
//

import Foundation
import Combine
import GetStream

class UpComingViewModel: ObservableObject {
    static var shared = UpComingViewModel()
    @Published var feeds = [FeedItem]()
    @Published var txtSearch: String = ""
    @Published var isShowEventView: Bool = true
    @Published var shouldScrollBottomView = false

    var timelineFlatFeed: FlatFeed!
    var visibleEvent: FeedItem!
    var feedOffset: Pagination? = .limit(5)
    var story = [Story]()
    var isPopup = false

    init() {
        _ = timelineFlatFeed?.subscribe(typeOf: FeedItem.self) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let items):
                self.feeds.append(contentsOf: items.newActivities)
            case .failure(_): break
            }
        }
    }
}

// MARK: - Functions
extension UpComingViewModel {
    func getUserFeeds() {
        if let feedId = FeedId(feedSlug: "UpComingEvents") {
            guard Client.shared.isValid else { return }
            timelineFlatFeed = Client.shared.flatFeed(feedId)
            timelineFlatFeed.get(
                typeOf: FeedItem.self,
                pagination: .limit(50),
                includeReactions: [.all]
            ) { [weak self] allFeeds in
                guard let `self` = self else { return }
                do {
                    let result = try allFeeds.get()
                    self.feeds = result.results
                    self.visibleEvent = self.feeds.first
                    self.feedOffset = result.next
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

    func loadNextEvent() {
        guard let nextOffset = feedOffset else { return }
        timelineFlatFeed.get(
            typeOf: FeedItem.self,
            pagination: nextOffset,
            includeReactions: [.all]
        ) { [weak self] allFeeds in
            guard let `self` = self else { return }
            do {
                let result = try allFeeds.get()
                self.feeds.append(contentsOf: result.results)
                self.feedOffset = result.next
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func addLikeReaction(event: FeedItem) {
        Client.shared.add(reactionTo: event.id, kindOf: .like) { result in
            print(result)
        }
    }
}
