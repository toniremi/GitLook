//
//  WebView.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    // the url to load using WKWebView
    let url: String

    /// Required method from UIViewRepresentable
    /// - Returns:
    ///     - return the WKWebView we want to display using SwiftUI
    func makeUIView(context: Context) -> WKWebView {
        // return a Swift WKWebView
        return WKWebView()
    }
    
    /// required method from UIViewRepresentable
    /// This method gets called when there is a state change.
    /// In this case, we load a new URL if there is a change.
    func updateUIView(_ webView: WKWebView, context: Context) {
        // verify that we can pass a valid url
        if let validUrl = URL(string: url) {
            // create the URLRequest with our stored url
            let request = URLRequest(url: validUrl)
            // load the url into the WebView
            webView.load(request)
        }
    }
}
