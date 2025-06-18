//
//  AppTheme.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//

import Foundation
import SwiftUI // Import SwiftUI for ColorScheme

enum AppTheme: String, CaseIterable, Identifiable {
    case system // Follows the system's dark/light mode setting
    case light  // Always light mode
    case dark   // Always dark mode

    var id: String { self.rawValue }

    var description: String {
        switch self {
        case .system: return "System Default"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    // Convert AppTheme to SwiftUI's ColorScheme?
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
