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
                
                Text("A Personal Access Token (PAT) is required to access the GitHub API and avoid strict rate limits. Please generate one from your GitHub settings under Developer settings > Personal access tokens (classic) with 'public_repo' and 'read:user' scopes.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.vertical)
            }
            .navigationTitle("App Setup")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                // Pre-fill if there's a token already (e.g., from a previous session, but this is handled by AppSettings itself)
                // This line is primarily for testing/visual feedback in the field if a token were loaded,
                // but AppSettings handles the loading into its @Published var
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
}

#Preview {
    TokenInputView().environmentObject(AppSettings())
}
