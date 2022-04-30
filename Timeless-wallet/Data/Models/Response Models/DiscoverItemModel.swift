//
//  DiscoverItemModel.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 3/10/22.
//

import Foundation
import SwiftUI

struct DiscoverItemModel: Codable, Identifiable {
    var id: String?
    var type: String?
    var blockType: String?
    var ctaType: String?
    var ctaData: [String: Any]? {
        extraData?["cta"] as? [String: Any]
    }
    var title: String?
    var description: String?
    var created: String?
    var updated: String?
    var children: DiscoverChildrenModel?
    var bannerType: String?
    var bannerUrl: String?
    var extraData: [String: Any]?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case blockType = "block_type"
        case ctaType = "cta_type"
        case title = "title"
        case description = "description"
        case created = "created_at"
        case updated = "updated_at"
        case children = "children"
        case bannerType = "banner_type"
        case bannerUrl = "banner_url"
        case extraData = "extra_data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try? values.decode(String?.self, forKey: CodingKeys.id)
        type = try? values.decode(String?.self, forKey: CodingKeys.type)
        blockType = try? values.decode(String?.self, forKey: CodingKeys.blockType)
        ctaType = try? values.decode(String?.self, forKey: CodingKeys.ctaType)
        title = try? values.decode(String?.self, forKey: CodingKeys.title)
        description = try? values.decode(String?.self, forKey: CodingKeys.description)
        created = try? values.decode(String?.self, forKey: CodingKeys.created)
        updated = try? values.decode(String?.self, forKey: CodingKeys.updated)
        children = try? values.decode(DiscoverChildrenModel?.self, forKey: CodingKeys.children)
        bannerType = try? values.decode(String?.self, forKey: CodingKeys.bannerType)
        bannerUrl = try? values.decode(String?.self, forKey: CodingKeys.bannerUrl)
        extraData = try? values.decode([String: Any].self, forKey: CodingKeys.extraData)
    }

    func encode(to encoder: Encoder) throws {
    }
}

struct DiscoverChildrenModel: Codable {
    var items: [DiscoverItemModel]?
    var cursor: String?

    enum CodingKeys: String, CodingKey {
        case items, cursor
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        items = try? values.decode([DiscoverItemModel]?.self, forKey: CodingKeys.items)
        cursor = try? values.decode(String?.self, forKey: CodingKeys.cursor)
    }
}
