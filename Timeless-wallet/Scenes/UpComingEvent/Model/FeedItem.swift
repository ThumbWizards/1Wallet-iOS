//
//  User.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 16/11/21.
//

import Foundation
import GetStream

class FeedItem: EnrichedActivity<GetStream.User, String, DefaultReaction>, Identifiable {

    private enum CodingKeys: String, CodingKey {
        case message, attachment, hashtag, details, title, startDate
    }

    var message: String
    var title: String
    var details: String
    var hashtag: String?
    var attachment: Attachment?
    var startDate = Date()

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
        if container.contains(.attachment) {
            attachment = try container.decode(Attachment.self, forKey: .attachment)
        } else {
            attachment = nil
        }
        if container.contains(.hashtag) {
            hashtag = try container.decode(String.self, forKey: .hashtag)
        } else {
            hashtag = nil
        }
        if container.contains(.startDate) {
            startDate = try container.decode(Date.self, forKey: .startDate)
        } else {
            startDate = Date()
        }
        details = try container.decode(String.self, forKey: .details)
        title = try container.decode(String.self, forKey: .title)
        try super.init(from: decoder)
    }

    required init(
        actor: ActorType,
        verb: Verb,
        object: ObjectType,
        foreignId: String? = nil,
        time: Date? = nil,
        feedIds: FeedIds? = nil,
        originFeedId: FeedId? = nil
    ) {
        fatalError("init(actor:verb:object:foreignId:time:feedIds:originFeedId:) has not been implemented")
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(message, forKey: .message)
        try container.encode(attachment, forKey: .attachment)
        try container.encode(hashtag, forKey: .hashtag)
        try container.encode(details, forKey: .details)
        try container.encode(title, forKey: .title)
        try super.encode(to: encoder)
    }
}

enum AttachmentType: String, Codable {
    case image
    case video
    case gif
}

struct Attachment: Codable {
    var url: URL
    var type: AttachmentType
    var videoThumbnail: URL?
}
