//
//  ContentView.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//

import SwiftUI

struct TokenInputView: View {
    @EnvironmentObject var appSettings: AppSettings
    
    // Local state for the text field input
    @State private var tokenInput: String = ""
    
    // State to control the Github WebView
    @State private var isPresentWebView = false
    
    // State for controlling alerts
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
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
                
                // Better instructions on how to create the PTA
                Text("A Personal Access Token (PAT) is required to access the GitHub API and avoid strict rate limits. \nPlease generate one from your GitHub settings under `Developer settings` > `Personal access tokens (classic)` with 'public_repo' and 'read:user' scopes.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.vertical)
                
                // Include a button to open Github from the App
                Button("Open GitHub") {
                    // make the WebView present
                    isPresentWebView = true
                }.sheet(isPresented: $isPresentWebView) {
                    NavigationStack {
                        // load our WebView to Github
                        WebView(url: "https://github.com/")
                            .ignoresSafeArea()
                            .navigationTitle("GitHub")
                            .navigationBarTitleDisplayMode(.inline)
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
                
            }
            .navigationTitle("App Setup")
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
    TokenInputView().environmentObject(AppSettings())
}
