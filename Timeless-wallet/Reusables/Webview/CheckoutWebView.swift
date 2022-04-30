//
//  CheckoutWebView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 1/13/22.
//

import SwiftUI
import WebKit

struct CheckoutWebView: UIViewRepresentable {
    var webview = WKWebView()
    var url: URL

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: CheckoutWebView

        init(_ parent: CheckoutWebView) {
            self.parent = parent
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        webview.navigationDelegate = context.coordinator
        webview.scrollView.contentInsetAdjustmentBehavior = .never
        loadWebPage(url: url)
        return webview
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
    }

    func loadWebPage(url: URL) {
        var request = URLRequest(url: url)
        request.setValue("https://www.harmony.one/", forHTTPHeaderField: "Referer")
        webview.load(request)
    }
}
