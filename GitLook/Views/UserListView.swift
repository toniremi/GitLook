//
//  UserListView.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//

import SwiftUI

struct UserListView: View {
    // Access the shared AppSettings object from the environment
    @EnvironmentObject var appSettings: AppSettings
    
    @StateObject var viewModel = UserListViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                
                HStack {
                    Text("Sort by:")
                    Picker("Sort By", selection: $viewModel.selectedSortOption) {
                        ForEach(UserSortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented) // segmented seems to look better
                    .onChange(of: viewModel.selectedSortOption, { oldValue, newValue in
                        Task {
                            // reset and fetch users after a change
                            await viewModel.resetAndFetchUsers(token: appSettings.githubPersonalAccessToken)
                        }
                    })
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 5)
                
                // Example of how you might pass the token to your ViewModel's fetch method
                if viewModel.isLoading && viewModel.users.isEmpty {
                    Spacer()
                    // show only loading when users list is empty
                    LoadingView(loadingText: "Loading users...").transition(.opacity)
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Spacer()
                    // Display our new Error View
                    ErrorView(message: error, actionTitle: "Retry") {
                        // Retry action: re-fetch users
                        Task {
                            await viewModel.fetchUsers(token: appSettings.githubPersonalAccessToken)
                        }
                    }.transition(.opacity) // include fade (in/out) transition
                    Spacer()
                } else if viewModel.users.isEmpty {
                    // Show our reusable EmptyStateView if no users are found
                    EmptyStateView(
                        systemImageName: "person.2.fill",
                        title: "No GitHub Users Found",
                        message: "It seems no users are available at the moment. This might be due to API issues or the provided token."
                    ).transition(.opacity) // include fade (in/out) transition
                } else {
                    List {
                        ForEach(viewModel.users) { user in
                            // when tapping a row navigate to UserRepositoryView
                            NavigationLink(destination: UserRepositoryView(username: user.login).environmentObject(appSettings)) {
                                HStack {
                                    AsyncImage(url: URL(string: user.avatarUrl)) { phase in
                                        if let image = phase.image {
                                            image.resizable()
                                                .transition(.opacity) // Fade in the loaded image
                                        } else if phase.error != nil {
                                            Image(systemName: "person.circle.fill") // Placeholder for error
                                                .resizable()
                                                .foregroundColor(.gray)
                                        } else {
                                            ProgressView() // Placeholder while loading
                                        }
                                    }
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .animation(.easeOut(duration: 0.3), value: user.avatarUrl)
                                    
                                    Text(user.login)
                                        .font(.headline)
                                }
                            }
                        }
                        
                        // Pagination "Load More" section
                        if viewModel.canLoadMoreUsers {
                            HStack {
                                Spacer()
                                if viewModel.isLoading { // Show progress view if loading more
                                    ProgressView()
                                        .padding()
                                } else { // Show button to load more
                                    Button("Load more users") {
                                        Task {
                                            await viewModel.fetchUsers(token: appSettings.githubPersonalAccessToken, isInitialFetch: false)
                                        }
                                    }
                                    .padding()
                                }
                                Spacer()
                            }
                            .onAppear {
                                // Implement infinite scrolling
                                // This will trigger loading next page automatically when user scrolls to the end
                                if viewModel.canLoadMoreUsers && !viewModel.isLoading {
                                    Task {
                                        await viewModel.fetchUsers(token: appSettings.githubPersonalAccessToken, isInitialFetch: false)
                                    }
                                }
                            }
                        }
                    }.transition(.opacity) // include fade (in/out) transition to the entire list
                }
            }
            .navigationTitle("GitHub Users")
            .task {
                // Trigger fetching users when the view appears
                // Only fetch if the list is empty, not loading, and no error previously occurred
                if viewModel.users.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                    await viewModel.fetchUsers(token: appSettings.githubPersonalAccessToken)
                }
            }
            // Optional: Add a settings button to navigate back to token input
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView().environmentObject(appSettings)) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .animation(.default, value: viewModel.isLoading) // Animate changes based on isLoading
            .animation(.default, value: viewModel.errorMessage) // Animate changes based on error message
            //.animation(.default, value: viewModel.users.isEmpty) // Animate changes based on list emptiness
            //.animation(.default, value: viewModel.selectedSortOption) // animate changes to sort options
        }
    }
}

struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView()
            .environmentObject(AppSettings())
    }
}
