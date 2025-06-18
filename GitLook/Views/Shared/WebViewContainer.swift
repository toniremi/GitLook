//
//  RepositoryWebViewContainer.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/18.
//

import SwiftUI
import WebKit

struct WebViewContainer: View {
    // the url is required
    let url: String
    // set an optional navigation title
    let title: String?

    // WebView state
    @State private var isLoadingWebView: Bool = false
    @State private var webViewError: Error? = nil

    var body: some View {
        ZStack {
            // Display the WebView
            WebView(url: url, isLoading: $isLoadingWebView, webViewError: $webViewError)
                .navigationTitle(title ?? "") // Set the navigation title for this view
                .navigationBarTitleDisplayMode(.inline) // Adjust as needed

            // Conditional ProgressView Overlay
            if isLoadingWebView {
                LoadingView()
            }
        }
        // Optional: Display an alert if a webViewError occurs
        .alert(isPresented: .constant(webViewError != nil)) { // Binding for presenting alert
            Alert(
                title: Text("Error Loading Page"),
                message: Text(webViewError?.localizedDescription ?? "An unknown error occurred."),
                dismissButton: .default(Text("OK")) {
                    // Optional: Reset error or handle dismissal
                    webViewError = nil
                }
            )
        }
    }
}

// Optional: Preview Provider for RepositoryWebViewContainer
struct RepositoryWebViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Wrap in NavigationView for title preview
            WebViewContainer(url:  "https://github.com/toniremi?tab=repositories", title: "toniremi")
        }
    }
}
