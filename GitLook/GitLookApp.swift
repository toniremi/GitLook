//
//  GitLookApp.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//

import SwiftUI

@main
struct GitLookApp: App {
    @StateObject var appSettings = AppSettings()
    
    @AppStorage("appTheme") private var appTheme: AppTheme = .system // Default to system
    
    var body: some Scene {
        WindowGroup {
            if appSettings.githubPersonalAccessToken.isEmpty {
                SettingsView()
                    .environmentObject(appSettings)
                    .preferredColorScheme(appTheme.colorScheme)
            } else {
                UserListView()
                    .environmentObject(appSettings)
                    .preferredColorScheme(appTheme.colorScheme)
            }
        }
    }
}
