//
//  UserRepositoryView.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//

import SwiftUI

struct UserRepositoryView: View {
    let username: String // This is passed from UserListView
    @EnvironmentObject var appSettings: AppSettings // Access the PAT from appSettings

    @StateObject var viewModel = UserRepositoryViewModel() // Instantiate the ViewModel

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading '\(username)' User Data...")
                    .padding()
            } else if let errorMessage = viewModel.errorMessage {
                Spacer() // Push error to center
                
                ErrorView(message: errorMessage) {
                    // Retry action: re-fetch user data
                    Task {
                        await viewModel.fetchData(for: username, token: appSettings.githubPersonalAccessToken)
                    }
                }
                Spacer()
            } else if let user = viewModel.userDetail {
                // Display UserDetailsView at the top
                UserDetailsView(user: user)
                
                // Add a section title for clarity
                Text("Repositories")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading) // Align title to left
                
                // Display UserRepositoriesListView below
                UserRepositoriesListView(repositories: viewModel.repositories)
            } else {
                // This state might occur briefly before loading or if no user details found
                Spacer()
                // Show empty state if user details are nil (e.g., user not found)
                EmptyStateView(
                    systemImageName: "person.fill.questionmark",
                    title: "User Not Found",
                    message: "The user '\(username)' could not be found or their data is currently unavailable."
                )
                Spacer()
            }
        }
        .navigationTitle(username) // Set the navigation bar title
        .navigationBarTitleDisplayMode(.inline) // Keep the title compact
        .task {
            // Fetch only if user detail is nil and not already loading or in an error state
            if viewModel.userDetail == nil && !viewModel.isLoading && viewModel.errorMessage == nil {
                await viewModel.fetchData(for: username, token: appSettings.githubPersonalAccessToken)
            }
        }
    }
}

struct UserRepositoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Embed in NavigationView for previewing navigation
            UserRepositoryView(username: "octocat")
                .environmentObject(AppSettings()) // Provide AppSettings for the preview
        }
    }
}
