// UserListViewModelTests.swift
import XCTest
import Combine // Required for @Published property observations
@testable import GitLook // Replace GitLook with your actual module name

// MARK: - Mock GitHubAPIService

// Mock conforms to the same protocol as the real service
class MockGitHubAPIService: GitHubAPIServiceProtocol {
    var shouldReturnError: Bool = false
    var mockUsers: [GithubUser] = []
    var receivedToken: String?
    var receivedSince: Int?
    var receivedPerPage: Int?
    
    func fetchUsers(token: String, since: Int?, perPage: Int) async throws -> [GithubUser] {
        receivedToken = token
        receivedSince = since
        receivedPerPage = perPage
        if shouldReturnError {
            // Define a custom mock error for testing
            struct MockError: Error, LocalizedError {
                var errorDescription: String? { "Mock API Error" }
            }
            throw MockError()
        }
        return mockUsers
    }
    
    // Implement other protocol methods, even if they're not directly tested here,
    // to satisfy the protocol conformance.
    func fetchRepositories(for username: String, token: String) async throws -> [GithubRepository] {
        return []
    }
    
    func fetchUserDetails(for username: String, token: String) async throws -> GithubUserDetail {
        throw NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
    }
}

// MARK: - UserListViewModelTests

final class UserListViewModelTests: XCTestCase {
    
    var viewModel: UserListViewModel!
    var mockAPIService: MockGitHubAPIService!
    private var cancellables: Set<AnyCancellable>! // To store Combine subscriptions
    
    // Setup function, run before each test method
    override func setUp() {
        super.setUp()
        mockAPIService = MockGitHubAPIService()
        // Inject the mock service into the ViewModel - This line will now work!
        viewModel = UserListViewModel(apiService: mockAPIService)
        cancellables = []
    }
    
    // Teardown function, run after each test method
    override func tearDown() {
        viewModel = nil
        mockAPIService = nil
        cancellables.forEach { $0.cancel() } // Cancel all subscriptions
        cancellables = nil
        super.tearDown()
    }
    
    func testFetchUsers_InitialState() {
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false initially")
        XCTAssertNil(viewModel.errorMessage, "errorMessage should be nil initially")
        XCTAssertTrue(viewModel.users.isEmpty, "users array should be empty initially")
        XCTAssertTrue(viewModel.canLoadMoreUsers, "canLoadMoreUsers should be true initially")
        XCTAssertNil(viewModel.lastFetchedUserId, "lastFetchedUserId should be nil initially")
    }
    
    func testFetchUsers_Success_InitialFetch() async throws {
        // Given
        let expectedUsers = (1...50).map { i in
            GithubUser(id: i, login: "user\(i)", avatarUrl: "url\(i)", url: "repos\(i)")
        }
        mockAPIService.mockUsers = expectedUsers
        let expectedToken = "mock_token_success"
        
        let isLoadingExpectation = XCTestExpectation(description: "isLoading becomes false after fetch")
        let usersExpectation = XCTestExpectation(description: "users array is populated")
        let canLoadMoreExpectation = XCTestExpectation(description: "canLoadMoreUsers remains true")
        let lastFetchedIdExpectation = XCTestExpectation(description: "lastFetchedUserId is updated")
        
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading { isLoadingExpectation.fulfill() }
            }
            .store(in: &cancellables)
        
        viewModel.$users
            .dropFirst()
            .sink { users in
                if !users.isEmpty { usersExpectation.fulfill() }
            }
            .store(in: &cancellables)
        
        viewModel.$canLoadMoreUsers
            .dropFirst()
            .sink { canLoadMore in
                if canLoadMore { canLoadMoreExpectation.fulfill() }
            }
            .store(in: &cancellables)
        
        viewModel.$lastFetchedUserId
            .dropFirst()
            .sink { userId in
                if userId != nil { lastFetchedIdExpectation.fulfill() }
            }
            .store(in: &cancellables)
        
        
        // When
        await viewModel.fetchUsers(token: expectedToken, isInitialFetch: true)
        
        // Then
        await fulfillment(of: [isLoadingExpectation, usersExpectation, canLoadMoreExpectation, lastFetchedIdExpectation], timeout: 1.0)
        
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false after successful fetch")
        XCTAssertNil(viewModel.errorMessage, "errorMessage should be nil on success")
        XCTAssertEqual(viewModel.users.count, expectedUsers.count, "ViewModel should have the correct number of users")
        XCTAssertEqual(viewModel.users[0].login, expectedUsers[0].login, "First user login should match")
        XCTAssertEqual(viewModel.lastFetchedUserId, expectedUsers.last?.id, "lastFetchedUserId should be updated")
        XCTAssertTrue(viewModel.canLoadMoreUsers, "canLoadMoreUsers should remain true if full page fetched")
        
        XCTAssertEqual(mockAPIService.receivedToken, expectedToken, "Mock service should receive the correct token")
        XCTAssertNil(mockAPIService.receivedSince, "Initial fetch should have nil 'since'")
        XCTAssertEqual(mockAPIService.receivedPerPage, 50, "Initial fetch should request 50 per page")
    }
    
    func testFetchUsers_Success_LoadMore() async throws {
        // Given
        let initialUsers = (1...50).map { i in
            GithubUser(id: i, login: "user\(i)", avatarUrl: "url\(i)", url: "repos\(i)")
        }
        viewModel.users = initialUsers // Manually set initial state for testing load more
        viewModel.lastFetchedUserId = initialUsers.last?.id
        viewModel.canLoadMoreUsers = true
        
        let newUsers = (51...100).map { i in
            GithubUser(id: i, login: "user\(i)", avatarUrl: "url\(i)", url: "repos\(i)")
        }
        mockAPIService.mockUsers = newUsers // Mock data for the next fetch
        let expectedToken = "mock_token_load_more"
        let expectedSinceId = initialUsers.last?.id
        
        let isLoadingExpectation = XCTestExpectation(description: "isLoading becomes false after load more")
        let usersExpectation = XCTestExpectation(description: "users array is appended")
        let lastFetchedIdExpectation = XCTestExpectation(description: "lastFetchedUserId is updated again")
        
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading { isLoadingExpectation.fulfill() }
            }
            .store(in: &cancellables)
        
        viewModel.$users
            .dropFirst()
            .sink { users in
                if users.count == initialUsers.count + newUsers.count { usersExpectation.fulfill() }
            }
            .store(in: &cancellables)
        
        viewModel.$lastFetchedUserId
            .dropFirst()
            .sink { userId in
                if userId == newUsers.last?.id { lastFetchedIdExpectation.fulfill() }
            }
            .store(in: &cancellables)
        
        // When
        await viewModel.fetchUsers(token: expectedToken, isInitialFetch: false)
        
        // Then
        await fulfillment(of: [isLoadingExpectation, usersExpectation, lastFetchedIdExpectation], timeout: 1.0)
        
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false after load more")
        XCTAssertNil(viewModel.errorMessage, "errorMessage should be nil on success")
        XCTAssertEqual(viewModel.users.count, initialUsers.count + newUsers.count, "ViewModel should have all users")
        XCTAssertEqual(viewModel.lastFetchedUserId, newUsers.last?.id, "lastFetchedUserId should be updated to last new user")
        XCTAssertTrue(viewModel.canLoadMoreUsers, "canLoadMoreUsers should remain true after full page load more")
        
        XCTAssertEqual(mockAPIService.receivedToken, expectedToken, "Mock service should receive the correct token")
        XCTAssertEqual(mockAPIService.receivedSince, expectedSinceId, "'since' parameter should match last fetched ID")
        XCTAssertEqual(mockAPIService.receivedPerPage, 50, "Load more should request 50 per page")
    }
    
    func testFetchUsers_NoMoreUsers() async throws {
        // Given
        let expectedUsers = (1...10).map { i in
            GithubUser(id: i, login: "user\(i)", avatarUrl: "url\(i)", url: "repos\(i)")
        }
        mockAPIService.mockUsers = expectedUsers // Fewer users than perPage
        let expectedToken = "mock_token_no_more"
        
        let isLoadingExpectation = XCTestExpectation(description: "isLoading becomes false")
        let usersExpectation = XCTestExpectation(description: "users array is populated")
        let canLoadMoreExpectation = XCTestExpectation(description: "canLoadMoreUsers becomes false")
        
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading { isLoadingExpectation.fulfill() }
            }
            .store(in: &cancellables)
        
        viewModel.$users
            .dropFirst()
            .sink { users in
                if !users.isEmpty { usersExpectation.fulfill() }
            }
            .store(in: &cancellables)
        
        viewModel.$canLoadMoreUsers
            .dropFirst()
            .sink { canLoadMore in
                if !canLoadMore { canLoadMoreExpectation.fulfill() }
            }
            .store(in: &cancellables)
        
        // When
        await viewModel.fetchUsers(token: expectedToken, isInitialFetch: true)
        
        // Then
        await fulfillment(of: [isLoadingExpectation, usersExpectation, canLoadMoreExpectation], timeout: 1.0)
        
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false")
        XCTAssertNil(viewModel.errorMessage, "errorMessage should be nil")
        XCTAssertEqual(viewModel.users.count, expectedUsers.count, "ViewModel should have correct users")
        XCTAssertFalse(viewModel.canLoadMoreUsers, "canLoadMoreUsers should be false if less than perPage fetched")
    }
    
    func testFetchUsers_Failure() async throws {
        // Given
        mockAPIService.shouldReturnError = true
        let expectedToken = "mock_token_failure"
        
        let isLoadingExpectation = XCTestExpectation(description: "isLoading becomes false on failure")
        let errorMessageExpectation = XCTestExpectation(description: "errorMessage is set on failure")
        
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading { isLoadingExpectation.fulfill() }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .dropFirst()
            .sink { message in
                if message != nil { errorMessageExpectation.fulfill() }
            }
            .store(in: &cancellables)
        
        // When
        await viewModel.fetchUsers(token: expectedToken, isInitialFetch: true)
        
        // Then
        await fulfillment(of: [isLoadingExpectation, errorMessageExpectation], timeout: 1.0)
        
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false after failed fetch")
        XCTAssertNotNil(viewModel.errorMessage, "errorMessage should not be nil on failure")
        XCTAssertTrue(viewModel.users.isEmpty, "users array should be empty on failure")
        XCTAssertFalse(viewModel.canLoadMoreUsers, "canLoadMoreUsers should be false on failure") // Usually reset
        XCTAssertNil(viewModel.lastFetchedUserId, "lastFetchedUserId should be nil on failure")
    }
    
    func testApplySorting_Ascending() {
        // Given
        viewModel.users = [
            GithubUser(id: 2, login: "userB", avatarUrl: "", url: ""),
            GithubUser(id: 3, login: "userC", avatarUrl: "", url: ""),
            GithubUser(id: 1, login: "userA", avatarUrl: "", url: "")
        ]
        viewModel.selectedSortOption = .usernameAsc
        
        // When
        viewModel.applySorting()
        
        // Then
        XCTAssertEqual(viewModel.users.map { $0.login }, ["userA", "userB", "userC"])
    }
    
    func testApplySorting_Descending() {
        // Given
        viewModel.users = [
            GithubUser(id: 2, login: "userB", avatarUrl: "", url: ""),
            GithubUser(id: 1, login: "userA", avatarUrl: "", url: ""),
            GithubUser(id: 3, login: "userC", avatarUrl: "", url: "")
        ]
        viewModel.selectedSortOption = .usernameDesc
        
        // When
        viewModel.applySorting()
        
        // Then
        XCTAssertEqual(viewModel.users.map { $0.login }, ["userC", "userB", "userA"])
    }
    
    func testResetAndFetchUsers() async throws {
        // Given
        let fullPageUsers: [GithubUser] = (1...50).map { id in
            GithubUser(id: id, login: "user\(id)", avatarUrl: "url\(id)", url: "repos\(id)")
        }
        mockAPIService.mockUsers = fullPageUsers // Setting mock data here
        print("DEBUG: Test start. mockAPIService.mockUsers count set to: \(mockAPIService.mockUsers.count)")
        
        // When
        await viewModel.resetAndFetchUsers(token: "mock_token")
        
        // Then
        print("DEBUG: Test end state - viewModel.canLoadMoreUsers: \(viewModel.canLoadMoreUsers), viewModel.users.count: \(viewModel.users.count), viewModel.errorMessage: \(viewModel.errorMessage ?? "nil")")
        // After reset and a fetch that provides a full page,
        // canLoadMoreUsers should still be true because there might be more.
        XCTAssertTrue(viewModel.canLoadMoreUsers, "canLoadMoreUsers should be reset to true and remain true after a full page fetch")
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false after fetch completes")
        XCTAssertNil(viewModel.errorMessage, "errorMessage should be nil on successful fetch")
        XCTAssertEqual(viewModel.users.count, 50, "Should have fetched 50 users")
        XCTAssertEqual(viewModel.lastFetchedUserId, 50, "lastFetchedUserId should be updated")
    }
}
