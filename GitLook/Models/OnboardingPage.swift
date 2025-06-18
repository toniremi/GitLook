//
//  OnboardingPage.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/18.
//

import Foundation

struct OnboardingPage: Identifiable {
    let id = UUID()
    let systemImage: String? // For SF Symbols
    let assetImage: String?  // For custom image assets
    let title: String
    let description: String
    let isTokenInputPage: Bool
    
    // Convenience initializer for regular content pages with SF Symbol
    init(systemImage: String, title: String, description: String) {
        self.systemImage = systemImage
        self.assetImage = nil
        self.title = title
        self.description = description
        self.isTokenInputPage = false
    }
    
    init(assetImage: String, title: String, description: String) {
        self.systemImage = nil
        self.assetImage = assetImage
        self.title = title
        self.description = description
        self.isTokenInputPage = false
    }
    
    
    // Convenience initializer for the token input page
    init(title: String, description: String, isTokenInputPage: Bool = true) {
        self.systemImage = nil
        self.assetImage = nil
        self.title = title
        self.description = description
        self.isTokenInputPage = isTokenInputPage
    }
}
