//
//  AppSettings.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//

import SwiftUI
import Combine
import KeychainSwift

// ViewModel to manage token storage
class AppSettings: ObservableObject {
    // include KeychainSwift to replace UserDefaults
    private let keychain = KeychainSwift()
    // our key to store data into KeyChain
    private let tokenKey = "githubPersonalAccessToken"
    
    // Replaced UserDefulats to use Keychain instead
    @Published var githubPersonalAccessToken: String = "" {
        didSet {
            if githubPersonalAccessToken.isEmpty {
                // If the token is set to empty, remove it from keychain
                keychain.delete(tokenKey)
                print("PAT deleted from Keychain.")
            } else {
                // Save the new token to keychain
                keychain.set(githubPersonalAccessToken, forKey: tokenKey)
                print("PAT saved to Keychain.")
            }
        }
    }

    init() {
        // if there is a token saved in Keychain then load it
        if let storedToken = keychain.get(tokenKey) {
            self.githubPersonalAccessToken = storedToken
            print("PAT loaded from Keychain.")
        } else {
            print("No PAT found in Keychain.")
            self.githubPersonalAccessToken = "" // Ensure it's empty if nothing is found
        }
    }
    
    /// Clear the token for a logout kind of situation
    func clearToken() {
        githubPersonalAccessToken = ""
    }
}
