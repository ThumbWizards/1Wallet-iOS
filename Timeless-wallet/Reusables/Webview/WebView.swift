//
//  WebView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 2/8/22.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var webview = WKWebView()
    var url: URL

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let request = URLRequest(url: url)
        webview.load(request)
        return webview
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}
