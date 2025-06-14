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
                // Example of how you might pass the token to your ViewModel's fetch method
                if viewModel.isLoading {
                    ProgressView("Loading Users...")
                } else if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                    Button("Retry") {
                        Task {
                            // Ensure the token is passed here for the API call
                            await viewModel.fetchUsers(token: appSettings.githubPersonalAccessToken)
                        }
                    }
                } else {
                    
                    List(viewModel.users) { user in
                        // when tapping a row navigate to UserRepositoryView
                        NavigationLink(destination: UserRepositoryView(username: user.login).environmentObject(appSettings)) {
                            HStack {
                                AsyncImage(url: URL(string: user.avatarUrl)) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                
                                Text(user.login)
                                    .font(.headline)
                            }
                        }
                    }
                }
            }
            .navigationTitle("GitHub Users")
            .task {
                // Trigger fetching users when the view appears
                // Pass the token from appSettings to the ViewModel's fetch method
                await viewModel.fetchUsers(token: appSettings.githubPersonalAccessToken)
            }
            // Optional: Add a settings button to navigate back to token input
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: TokenInputView().environmentObject(appSettings)) {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
}

struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView()
        // Provide a dummy AppSettings for the preview
            .environmentObject(AppSettings())
    }
}
