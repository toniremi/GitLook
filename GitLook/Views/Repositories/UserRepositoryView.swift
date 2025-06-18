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
                LoadingView(loadingText: "Loading '\(username)' User Data...").transition(.opacity)
            } else if let errorMessage = viewModel.errorMessage {
                Spacer() // Push error to center
                
                ErrorView(message: errorMessage, actionTitle: "Retry") {
                    // Retry action: re-fetch user data
                    Task {
                        await viewModel.fetchData(for: username, token: appSettings.githubPersonalAccessToken)
                    }
                }.transition(.opacity) // include fade (in/out) transition
                Spacer()
            } else if let user = viewModel.userDetail {
                // Display UserDetailsView at the top
                UserDetailsView(user: user).transition(.opacity)
                
                // Add a section title for clarity
                Text("Repositories")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading) // Align title to left
                
                // Display UserRepositoriesListView below
                UserRepositoriesListView(repositories: viewModel.repositories).transition(.opacity)
            } else {
                // This state might occur briefly before loading or if no user details found
                Spacer()
                // Show empty state if user details are nil (e.g., user not found)
                EmptyStateView(
                    systemImageName: "person.fill.questionmark",
                    title: "User Not Found",
                    message: "The user '\(username)' could not be found or their data is currently unavailable."
                ).transition(.opacity)
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
        .animation(.default, value: viewModel.isLoading) // Animate changes based on isLoading
        .animation(.default, value: viewModel.errorMessage) // Animate changes based on error message
        .animation(.default, value: viewModel.userDetail) // Animate changes based on userDetails
        .animation(.default, value: viewModel.repositories.isEmpty) // Animate changes based on list emptiness
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
