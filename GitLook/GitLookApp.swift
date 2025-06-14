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
    
    var body: some Scene {
        WindowGroup {
            if appSettings.githubPersonalAccessToken.isEmpty {
                TokenInputView().environmentObject(appSettings)
            } else {
                UserListView().environmentObject(appSettings)
            }
        }
    }
}
