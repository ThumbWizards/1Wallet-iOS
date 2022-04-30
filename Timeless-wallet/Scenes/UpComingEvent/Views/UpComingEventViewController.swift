//
//  UpComingEventViewController.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 19/11/21.
//

import UIKit
import Combine
import AVKit
import AVFoundation
import Kingfisher
import StreamChatUI

class UpComingEventViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var tblEvents: UITableView!

    // MARK: - Variables
    var viewModel = UpComingViewModel.shared
    var feedItems = [FeedItem]()
    var anyCancellable = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        ImageCache.default.memoryStorage.config.totalCostLimit = 300
        viewModel.feeds.removeAll()
        viewModel.$feeds.sink { [weak self] feeds in
            guard let `self` = self else { return }
            self.feedItems = feeds
                .filter { Calendar.current.isDateInToday($0.startDate) || $0.startDate > Date() }
                .sorted(by: { $0.startDate < $1.startDate })
            self.tblEvents.reloadData()
            self.fadeEdges(with: 1.5)
            self.pausePlayVideos()
        }
        .store(in: &anyCancellable)
        viewModel.$shouldScrollBottomView.sink(receiveValue: { [weak self] isScrollEnable in
            guard let `self` = self else { return }
            if !self.viewModel.isPopup {
                self.tblEvents.isScrollEnabled = isScrollEnable
            }
        })
        .store(in: &anyCancellable)
        viewModel.$isShowEventView.sink { [weak self] _ in
            guard let `self` = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let `self` = self else { return }
                self.tblEvents.setContentOffset(.zero, animated: false)
            }
        }
        .store(in: &anyCancellable)
        tblEvents.keyboardDismissMode = .onDrag
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.txtSearch = ""
    }

    deinit {
        debugPrint("deinit")
    }

    func pausePlayVideos() {
        ASVideoPlayerController.sharedVideoPlayer.pausePlayVideosFor(tableView: tblEvents)
    }

    @objc func btnLikeAction(_ sender: UIButton) {
        guard let cell = sender.superview?.superview?.superview?.superview as? UpComingEventCell else { return }
        guard let indexPath = tblEvents.indexPath(for: cell) else { return }
        let currentLikeCount = (Int(cell.lblNoLikes.text ?? "0") ?? 0)
        cell.lblNoLikes.text = "\(currentLikeCount + 1)"
        viewModel.addLikeReaction(event: feedItems[indexPath.row])
    }

    func fadeEdges(with modifier: CGFloat) {
        let visibleCells = tblEvents.visibleCells
        guard !visibleCells.isEmpty else { return }
        guard let topCell = tblEvents.visibleCells.first else { return }
        guard let bottomCell = tblEvents.visibleCells.last else { return }
        visibleCells.forEach {
            $0.contentView.alpha = 1
        }
        let cellHeight = topCell.frame.height - 1
        let tableViewTopPosition = tblEvents.frame.origin.y
        let tableViewBottomPosition = tblEvents.frame.maxY
        guard let topCellIndexpath = tblEvents.indexPath(for: topCell) else { return }
        let topCellPositionInTableView = tblEvents.rectForRow(at: topCellIndexpath)
        guard let bottomCellIndexpath = tblEvents.indexPath(for: bottomCell) else { return }
        let bottomCellPositionInTableView = tblEvents.rectForRow(at: bottomCellIndexpath)
        let topCellPosition = tblEvents.convert(topCellPositionInTableView, to: tblEvents.superview).origin.y
        let bottomCellPosition = tblEvents.convert(bottomCellPositionInTableView, to: tblEvents.superview).origin.y + cellHeight
        let topCellOpacity = (1.0 - ((tableViewTopPosition - topCellPosition) / cellHeight) * modifier)
        let bottomCellOpacity = (1.0 - ((bottomCellPosition - tableViewBottomPosition) / cellHeight) * modifier)
        topCell.contentView.alpha = max(topCellOpacity, 0.15)
        bottomCell.contentView.alpha = max(bottomCellOpacity, 0.15)
    }

}

extension UpComingEventViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UpComingEventCell") as? UpComingEventCell else {
            return UITableViewCell()
        }
        cell.configCell(feed: feedItems[indexPath.row])
        cell.btnLike.addTarget(self, action: #selector(btnLikeAction(_:)), for: .touchUpInside)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedItems.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let videoCell = cell as? ASAutoPlayVideoLayerContainer, videoCell.videoURL != nil {
            ASVideoPlayerController.sharedVideoPlayer.removeLayerFor(cell: videoCell)
        }
    }

}

extension UpComingEventViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            pausePlayVideos()
        }
        // Disable swipe down gesture
        /*
        if scrollView.contentOffset.y < 0 && !self.viewModel.isPopup {
            self.tblEvents.isScrollEnabled = false
        }
        */
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pausePlayVideos()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.fadeEdges(with: 1.5)
    }
}
