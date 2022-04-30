//
//  Support.swift
//  Timeless-wallet
//
//  Created by Ajay ghodadra on 24/10/21.
//

import Foundation

struct Support: Codable {
  enum CodingKeys: String, CodingKey {
    case text
    case url
  }

  var text: String?
  var url: String?

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    text = try container.decodeIfPresent(String.self, forKey: .text)
    url = try container.decodeIfPresent(String.self, forKey: .url)
  }
}
