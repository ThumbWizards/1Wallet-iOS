//
//  UpComingEventCell.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 23/11/21.
//

import UIKit
import AVFoundation
import StreamChatUI

class UpComingEventCell: ASVideoTableViewCell {

    // MARK: - Outlets
    // swiftlint:disable private_outlet
    @IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var viewOverlay: UIView!
    @IBOutlet weak var lblDetails: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblHashTag: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblNoLikes: UILabel!
    @IBOutlet weak var lblNumberComments: UILabel!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var btnLike: UIButton!

    // MARK: - Variables
    private let formatter = DateFormatter()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // TODO: - 3. Thumbnail placeholder jumps
        // Check for video frame issue on first time.
        videoLayer.frame = playerView.frame
    }

    private func setupUI() {
        self.selectionStyle = .none
        videoLayer.backgroundColor = UIColor.clear.cgColor
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerView.layer.addSublayer(videoLayer)
        viewContainer.layer.cornerRadius = 8
        viewContainer.clipsToBounds = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.viewOverlay.bounds
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.3).cgColor, UIColor.clear.cgColor]
        self.viewOverlay.layer.insertSublayer(gradientLayer, at: 0)
    }

    func configCell(feed: FeedItem) {
        lblDay.text = getDayString(feed.startDate)
        lblMonth.text = getMonthString(feed.startDate).uppercased()
        imgPlay.isHidden = true
        if feed.attachment?.type == .video {
            videoURL = feed.attachment?.url.absoluteString
            imgView.kf.setImage(
                with: feed.attachment?.videoThumbnail,
                placeholder: UIImage(named: "placeholder"),
                options: [.transition(.fade(0.1)), .loadDiskFileSynchronously]
            ) { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success:
                    self.imgPlay.isHidden = false
                case .failure: break
                }
            }
            playerView.isHidden = false
        } else if feed.attachment?.type == .image {
            imgView.kf.setImage(
                with: feed.attachment?.url,
                placeholder: nil,
                options: [.transition(.fade(0.1)), .loadDiskFileSynchronously])
            self.imgPlay.isHidden = true
            videoURL = nil
            playerView.isHidden = true
        } else {
            playerView.isHidden = true
            imgView.image = nil
        }
        lblTitle.text = feed.title
        lblDetails.text = feed.details
        lblInfo.text = feed.message
        lblNoLikes.text = "\(feed.likesCount)"
        lblHashTag.text = feed.hashtag
    }

    private func getDayString(_ date: Date) -> String {
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }

    private func getMonthString(_ date: Date) -> String {
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
}
