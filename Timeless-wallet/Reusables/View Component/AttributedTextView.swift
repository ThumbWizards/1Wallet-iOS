//
//  AttributedTextView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 04/01/2022.
//

import SwiftUI
import Atributika

struct AttributedTextView: UIViewRepresentable {
    let attributedText: AttributedText

    func makeUIView(context: Context) -> AttributedLabel {
        let attributedLabel = AttributedLabel()
        attributedLabel.numberOfLines = 10
        attributedLabel.attributedText = attributedText
        attributedLabel.onClick = { _, detection in
            switch detection.type {
            case .link(let url):
                if [nil, "http"].contains(url.scheme),
                   let newUrl = URL(string: "https://\(url.absoluteString.replacingOccurrences(of: "http://", with: ""))") {
                    UIApplication.shared.open(newUrl)
                } else {
                    UIApplication.shared.open(url)
                }
            case .tag(let tag):
                if tag.name == "a", let href = tag.attributes["href"], let url = URL(string: href) {
                    UIApplication.shared.open(url)
                }
            default: break
            }
        }
        return attributedLabel
    }

    func updateUIView(_ uiView: AttributedLabel, context: Context) {
        uiView.numberOfLines = 10
        uiView.attributedText = attributedText
    }

    static func createLinkableText(text: String) -> AttributedText {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineSpacing = -0.5

        let aStyle = Style("a")
            .font(UIFont.systemFont(ofSize: 13))
            .foregroundColor(UIColor.init(Color.timelessBlue), .normal)
            .foregroundColor(UIColor.init(Color.timelessBlue.opacity(0.5)), .highlighted)

        let regularText = Style
            .font(UIFont.systemFont(ofSize: 13))
            .paragraphStyle(paragraphStyle)
            .foregroundColor(UIColor.init(Color.white.opacity(0.6)))

        let displayText = text.stringByDecodingHTMLEntities
            .style(tags: [aStyle], transformers: [])
            .styleAll(regularText)

        return displayText
    }
}
