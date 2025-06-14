//
//  AppSettings.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//

import SwiftUI

// ViewModel to manage token storage
class AppSettings: ObservableObject {
    @Published var githubPersonalAccessToken: String = "" {
        didSet {
            // In a real app, save this securely to Keychain
            UserDefaults.standard.set(githubPersonalAccessToken, forKey: "githubPersonalAccessToken")
        }
    }

    init() {
        // In a real app, load this securely from Keychain
        if let token = UserDefaults.standard.string(forKey: "githubPersonalAccessToken") {
            self.githubPersonalAccessToken = token
        }
    }
    
    /// Clear the token for a logout kind of situation
    func clearToken() {
        githubPersonalAccessToken = ""
    }
}
