//
//  UserDetailViewModel.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//

import Foundation

class UserRepositoryViewModel: ObservableObject {
    @Published var userDetail: GithubUserDetail? = nil
    @Published var repositories: [GithubRepository] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let apiService: GitHubAPIService // Dependency Injection
    
    init(apiService: GitHubAPIService = GitHubAPIService()) {
        self.apiService = apiService
    }
    
    @MainActor // Ensures UI updates happen on the main thread
    func fetchData(for username: String, token: String) async {
        isLoading = true
        errorMessage = nil
        userDetail = nil // Clear previous data
        repositories = [] // Clear previous data
        
        do {
            // Fetch user details and repositories concurrently
            // 'async let' allows these two network calls to start at roughly the same time
            async let fetchedUserDetail = apiService.fetchUserDetails(for: username, token: token)
            async let fetchedRepositories = apiService.fetchRepositories(for: username, token: token)
            
            // 'try await' waits for both async tasks to complete
            let user = try await fetchedUserDetail
            let repos = try await fetchedRepositories
            
            self.userDetail = user
            // Filter out forked repositories as per requirement
            self.repositories = repos.filter { !$0.fork }
            
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? "An unknown error occurred."
            print("Error fetching user data: \(error.localizedDescription)")
        }
        isLoading = false
    }
}
