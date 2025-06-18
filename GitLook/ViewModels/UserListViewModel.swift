//
//  UserListViewModel.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//

import Foundation

enum UserSortOption: String, CaseIterable, Identifiable {
    case usernameAsc = "Username (A-Z)"
    case usernameDesc = "Username (Z-A)"
    
    var id: String { self.rawValue }
}

class UserListViewModel: ObservableObject {
    @Published var users: [GithubUser] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // Pagination properties
    @Published var lastFetchedUserId: Int? = nil // To store the 'since' parameter for next page
    @Published var canLoadMoreUsers: Bool = true // To indicate if there are more pages
    private let usersPerPage: Int = 50 // Number of users to fetch per page max 100

    // Sorting property
    @Published var selectedSortOption: UserSortOption = .usernameAsc // Default sort option
    
// Dependency Injection
    private let apiService: any GitHubAPIServiceProtocol

    // Initialize with the API service
    init(apiService: any GitHubAPIServiceProtocol = GitHubAPIService()) {
        // assign our api Service
        self.apiService = apiService
    }

    @MainActor
    func fetchUsers(token: String, isInitialFetch: Bool = true) async {
        
        // If it's an initial fetch, reset everything
        if isInitialFetch {
            users = []
            lastFetchedUserId = nil
            canLoadMoreUsers = true
            isLoading = false // Ensure isLoading is false before starting a fresh fetch
        }
        
        // Prevent multiple simultaneous fetches or if no more users are available
        guard !isLoading && canLoadMoreUsers else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Pass the token to the API service
            // self.users = try await apiService.fetchUsers(token: token, since: lastFetchedUserId, perPage: usersPerPage)
            let fetchedUsers = try await apiService.fetchUsers(token: token, since: lastFetchedUserId, perPage: usersPerPage)
                        
            if fetchedUsers.isEmpty || fetchedUsers.count < usersPerPage {
                canLoadMoreUsers = false // No more users to load if less than perPage or empty
            }
            
            // Append new users
            users.append(contentsOf: fetchedUsers)
            
            // Update lastFetchedUserId for pagination
            if let lastUser = users.last {
                lastFetchedUserId = lastUser.id
            }
            
            // Apply sorting after new users are added
            applySorting()
            
        } catch {
            errorMessage = (error as? APIError)?.localizedDescription ?? "An unknown error occurred."
            print("Error fetching users: \(error.localizedDescription)")
            // FIX: Set canLoadMoreUsers to false on failure
            // Caught during UnitTesting
            canLoadMoreUsers = false // No more users can be loaded if an error occurs
        }
        isLoading = false
    }
    
    // Method to apply sorting
    func applySorting() {
        switch selectedSortOption {
        case .usernameAsc:
            users.sort { $0.login.lowercased() < $1.login.lowercased() }
        case .usernameDesc:
            users.sort { $0.login.lowercased() > $1.login.lowercased() }
        }
    }
        
    // Method to reset and refetch (e.g., when sort option changes)
    @MainActor
    func resetAndFetchUsers(token: String) async {
        users = []
        lastFetchedUserId = nil
        canLoadMoreUsers = true
        await fetchUsers(token: token, isInitialFetch: true)
    }
}
