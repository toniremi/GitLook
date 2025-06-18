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
    // observe the loading state
    @Binding var isLoading: Bool
    // For existing error handling
    @Binding var webViewError: Error?
    
    @Environment(\.colorScheme) var colorScheme
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /// Required method from UIViewRepresentable
    /// - Returns:
    ///     - return the WKWebView we want to display using SwiftUI
    func makeUIView(context: Context) -> WKWebView {
        // create a WKWebView
        let webView = WKWebView()
        // setup the background color as label so we also respect theme for webView
        // using dark and light theme
        webView.overrideUserInterfaceStyle = colorScheme == .dark ? .dark : .light
        // assign our context coordinator to the navigation delegate
        webView.navigationDelegate = context.coordinator
        // load our url
        if let validUrl = URL(string: url) {
            // create the URLRequest with our stored url
            let request = URLRequest(url: validUrl)
            // load the url into the WebView
            webView.load(request)
        }
        // return the generated web view
        return webView
    }
    
    /// required method from UIViewRepresentable
    /// This method gets called when there is a state change.
    /// In this case, we load a new URL if there is a change.
    func updateUIView(_ webView: WKWebView, context: Context) {
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        // MARK: - WKNavigationDelegate Methods
        
        // Navigation did start
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            // Set isLoading to true when navigation starts
            parent.isLoading = true
            parent.webViewError = nil // Clear any previous errors
            print("WebView: Started loading \(webView.url?.absoluteString ?? "unknown URL")")
        }
        
        // navigation did finish
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Set isLoading to false when navigation finishes
            parent.isLoading = false
            print("WebView: Finished loading \(webView.url?.absoluteString ?? "unknown URL")")
        }
        
        // did fail provisional navigation
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            // Set isLoading to false and capture error on failure
            parent.isLoading = false
            // set the error so we can know why it did fail
            parent.webViewError = error
            print("WebView: Failed provisional navigation with error: \(error.localizedDescription)")
        }
        
        // did fail
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            // Set isLoading to false and capture error on failure
            parent.isLoading = false
            parent.webViewError = error
            print("WebView: Failed navigation with error: \(error.localizedDescription)")
        }
        
        // Handle external links opening in Safari (if needed)
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated,
               let url = navigationAction.request.url,
               UIApplication.shared.canOpenURL(url),
               url.host != webView.url?.host { // Open external links in Safari
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }
}
