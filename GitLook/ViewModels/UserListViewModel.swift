//
//  UserListViewModel.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//

import Foundation

class UserListViewModel: ObservableObject {
    @Published var users: [GithubUser] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let apiService: GitHubAPIService // Dependency Injection

    // Initialize with the API service
    init(apiService: GitHubAPIService = GitHubAPIService()) {
        // assign our api Service
        self.apiService = apiService
    }

    @MainActor
    func fetchUsers(token: String) async {
        isLoading = true
        errorMessage = nil
        do {
            // Pass the token to the API service
            self.users = try await apiService.fetchUsers(token: token)
        } catch {
            errorMessage = (error as? APIError)?.localizedDescription ?? "An unknown error occurred."
            print("Error fetching users: \(error.localizedDescription)")
        }
        isLoading = false
    }
}
