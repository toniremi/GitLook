//
//  SettingsView.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.openURL) var openURL
    
    // Access the same AppStorage variable for the theme
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    
    // Local state for the text field input
    @State private var tokenInput: String = ""
    
    // State to control the Github WebView
    @State private var isPresentWebView = false
    
    // State for controlling alerts
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // github PAT create help url
    private let githubHelpURL = URL(string: "https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token")!
    
    // some personal branding
    // my github avatar picture
    private var myAvatarUrl = URL(string: "https://avatars.githubusercontent.com/u/1259874?v=4")!
    // my github url
    private let myGitHubURL = URL(string: "https://github.com/toniremi/")!
    // my linkedin url
    private let myLinkedInProfileURL = URL(string: "https://www.linkedin.com/in/toniremeseiro/")!
    // my name
    private let myName = "Antoni Remeseiro"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("GitHub Personal Access Token")) {
                    SecureField("Enter your PAT", text: $tokenInput)
                    
                    Button("Save Token") {
                        saveToken()
                    }
                    .disabled(tokenInput.isEmpty) // Disable button if field is empty
                }
                
                Section(header: Text("Generate Personal Access Token")) {
                    // Better instructions on how to create the PTA
                    Text("A Personal Access Token (PAT) is required to access the GitHub API and avoid strict rate limits. \nPlease generate one from your GitHub settings under `Developer settings` > `Personal access tokens (classic)` with 'public_repo' and 'read:user' scopes.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.vertical)
                    
                    // Include a button to open Github from the App
                    Button("Open GitHub Settings Page") {
                        // make the WebView present
                        isPresentWebView = true
                    }.sheet(isPresented: $isPresentWebView) {
                        NavigationStack {
                            // load our WebView to Github
                            WebViewContainer(url: "https://github.com/settings/profile", title: "Github")
                                .ignoresSafeArea()
                                .navigationBarTitleDisplayMode(.inline)
                        }
                    }
                    
                    // include a help button to github documentation on PAT's
                    Button(action: {
                        openURL(githubHelpURL)
                    }) {
                        HStack {
                            Text("Get help creating a token")
                            Image(systemName: "questionmark.circle") // Help icon
                        }
                        .font(.subheadline)
                        .foregroundColor(.accentColor) // Uses the system's accent color (or your custom one if set in Assets)
                    }
                }
                
                // only when the user has a token saved show a clear token section
                if appSettings.githubPersonalAccessToken.isEmpty == false {
                    Section() {
                        Button("Clear Saved Token") {
                            // clear the token
                            clearToken()
                        }
                    }
                }
                
                // Appearence to choose theme
                Section(header: Text("App Appearance")) {
                    Picker("Theme", selection: $appTheme) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.description)
                                .tag(theme)
                        }
                    }
                    .pickerStyle(.segmented) // A compact segmented control for the options
                }
                
                // some Personal Branding
                Section(header: Text("About This App")) {
                    VStack(alignment: .center, spacing: 15) { // Center alignment for the VStack
                        // Profile Picture
                        AsyncImage(url: myAvatarUrl) { phase in
                            if let image = phase.image {
                                image.resizable()
                                    .transition(.opacity) // Fade in
                            } else if phase.error != nil {
                                Image(systemName: "person.circle.fill") // Error placeholder
                                    .resizable()
                                    .foregroundColor(.gray)
                            } else {
                                ProgressView() // Loading placeholder
                            }
                        }
                        .frame(width: 64, height: 64) // Larger size for main profile pic
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.accentColor, lineWidth: 2)) // Accent colored border
                        .shadow(radius: 5)
                        .animation(.easeOut(duration: 0.3), value: myAvatarUrl)
                        
                        // Your Name
                        HStack {
                            Text("Made by") // Using the new myName constant
                                .font(.headline)
                                .fontWeight(.regular)
                                .foregroundColor(.primary)
                            Text(myName) // Using the new myName constant
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        
                        // Buttons for GitHub and LinkedIn
                        HStack(spacing: 20) {
                            Button {
                                openURL(myGitHubURL) // Open GitHub profile externally
                            } label: {
                                Label("GitHub", systemImage: "chevron.left.forwardslash.chevron.right") // Code icon
                                    .font(.subheadline)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.black.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain) // Remove default button styling for custom look
                            
                            Button {
                                openURL(myLinkedInProfileURL) // Open LinkedIn profile externally
                            } label: {
                                Label("LinkedIn", systemImage: "link") // Generic link icon
                                    .font(.subheadline)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.blue.opacity(0.8)) // LinkedIn blue
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain) // Remove default button styling for custom look
                        }
                    }
                    .frame(maxWidth: .infinity) // Make VStack take full width to center its content
                    .padding(.vertical, 10)
                }
            }
            .navigationTitle("Settings")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                // Pre-fill if there's a token already (e.g., from a previous session, but this is handled by AppSettings itself)
                tokenInput = appSettings.githubPersonalAccessToken
            }
        }
    }
    
    private func saveToken() {
        if tokenInput.isEmpty {
            alertTitle = "Error"
            alertMessage = "Please enter your Personal Access Token to continue."
            showingAlert = true
        } else {
            // Save the token to AppSettings. This will trigger the @Published property wrapper,
            // which in turn updates UserDefaults and causes GitLookApp's body to re-evaluate.
            appSettings.githubPersonalAccessToken = tokenInput
            
            alertTitle = "Success!"
            alertMessage = "Your Personal Access Token has been saved successfully."
            showingAlert = true
            
            // The view transition will happen automatically because appSettings.githubPersonalAccessToken
            // is no longer empty, causing GitLookApp's body to switch to UserListView.
            // No explicit dismissal or navigation code is needed here for that transition.
        }
    }
    
    private func clearToken() {
        // call clear token to remove it from KeyChain
        appSettings.clearToken()
        tokenInput = "" // clear the local state also
        // display an UI alert to notifiy the user that the token has ben cleared
        alertTitle = "Success!"
        alertMessage = "Your Personal Access Token has been cleared and removed successfully."
        showingAlert = true
    }
}

#Preview {
    SettingsView().environmentObject(AppSettings())
}
