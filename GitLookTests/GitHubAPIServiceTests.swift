// GitHubAPIServiceTests.swift
import XCTest
@testable import GitLook // Replace GitLook with your actual module name

// MARK: - Mock URLProtocol

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("Received unexpected request with no handler set.")
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // Required, but often empty for mocks
    }
}

// MARK: - GitHubAPIServiceTests

final class GitHubAPIServiceTests: XCTestCase {

    var apiService: GitHubAPIService!
    var mockSession: URLSession!

    override func setUp() {
        super.setUp()
        // Configure a mock URLSession
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self] // Register our mock protocol
        mockSession = URLSession(configuration: configuration)

        // Initialize GitHubAPIService with the mock session
        apiService = GitHubAPIService(session: mockSession)
    }

    override func tearDown() {
        apiService = nil
        mockSession = nil
        MockURLProtocol.requestHandler = nil // Clear handler for next test
        super.tearDown()
    }

    func testFetchUsers_SuccessParsing() async throws {
        // Given
        let jsonString = """
        [
            {"login": "user1", "id": 1, "avatar_url": "url1", "url": "https://api.github.com/users/user1"},
            {"login": "user2", "id": 2, "avatar_url": "url2", "url": "https://api.github.com/users/user2"}
        ]
        """
        let mockData = Data(jsonString.utf8)
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.github.com/users?per_page=50&since=0")!, // Match expected URL
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        MockURLProtocol.requestHandler = { request in
            XCTAssertTrue(request.url?.absoluteString.contains("https://api.github.com/users") ?? false, "Request URL should contain base API path")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "token mock_valid_token", "Authorization header should be present")
            return (mockResponse, mockData)
        }

        // When
        let users = try await apiService.fetchUsers(token: "mock_valid_token", since: 0, perPage: 50)

        // Then
        XCTAssertEqual(users.count, 2, "Should parse two users")
        XCTAssertEqual(users[0].login, "user1")
        XCTAssertEqual(users[1].id, 2)
    }

    func testFetchUsers_FailureInvalidToken_401() async throws {
        // Given
        let errorJsonString = """
        {"message": "Bad credentials", "documentation_url": "https://docs.github.com/rest"}
        """
        let mockErrorData = Data(errorJsonString.utf8)
        let mockErrorResponse = HTTPURLResponse(
            url: URL(string: "https://api.github.com/users")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )!

        MockURLProtocol.requestHandler = { request in
            return (mockErrorResponse, mockErrorData)
        }

        // When
        do {
            _ = try await apiService.fetchUsers(token: "invalid_token", since: nil, perPage: 50)
            XCTFail("Expected an APIError.unauthorized but succeeded")
        } catch let error as APIError {
            // Then
            XCTAssertEqual(error, APIError.unauthorized(message: "Bad credentials"), "Should throw unauthorized error for 401")
        } catch {
            XCTFail("Expected an APIError but got a different error: \(error)")
        }
    }

    func testFetchUsers_FailureNetworkError() async throws {
           // Given
           let networkError = URLError(.notConnectedToInternet)
           MockURLProtocol.requestHandler = { request in
               throw networkError
           }

           // When
           do {
               _ = try await apiService.fetchUsers(token: "any_token", since: nil, perPage: 50)
               XCTFail("Expected a network error but succeeded")
           } catch let error as APIError {
               // Then
               if case .networkError(let receivedError) = error {
                   // Cast to URLError to compare URLError.Code types
                   if let receivedURLError = receivedError as? URLError {
                       XCTAssertEqual(receivedURLError.code, networkError.code, "Should throw networkError with correct underlying error code")
                   } else {
                       XCTFail("Received error was not a URLError as expected.")
                   }
               } else {
                   XCTFail("Expected APIError.networkError but got \(error)")
               }
           } catch {
               XCTFail("Expected an APIError but got a different error: \(error)")
           }
       }

    func testFetchUsers_FailureDecodingError() async throws {
        // Given
        let invalidJsonString = """
        [{"bad_key": "value"}]
        """ // Missing 'login', 'id', etc. for GithubUser
        let mockData = Data(invalidJsonString.utf8)
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.github.com/users")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        MockURLProtocol.requestHandler = { request in
            return (mockResponse, mockData)
        }

        // When
        do {
            _ = try await apiService.fetchUsers(token: "valid_token", since: nil, perPage: 50)
            XCTFail("Expected a decoding error but succeeded")
        } catch let error as APIError {
            // Then
            if case .decodingError(_) = error {
                XCTAssertTrue(true, "Should throw a decoding error")
            } else {
                XCTFail("Expected APIError.decodingError but got \(error)")
            }
        } catch {
            XCTFail("Expected an APIError but got a different error: \(error)")
        }
    }

    func testFetchRepositories_Success() async throws {
        // Given
        let username = "testUser"
        let jsonString = """
        [{"id": 1, "name": "repo1", "html_url": "url1", "description": "desc1", "stargazers_count": 10, "fork": false}]
        """
        let mockData = Data(jsonString.utf8)
        let mockResponse = HTTPURLResponse(url: URL(string: "https://api.github.com/users/\(username)/repos")!, statusCode: 200, httpVersion: nil, headerFields: nil)!

        MockURLProtocol.requestHandler = { request in
            XCTAssertTrue(request.url?.absoluteString.contains("/repos") ?? false)
            return (mockResponse, mockData)
        }

        // When
        let repos = try await apiService.fetchRepositories(for: username, token: "mock_token")

        // Then
        XCTAssertEqual(repos.count, 1)
        XCTAssertEqual(repos[0].name, "repo1")
    }

    func testFetchUserDetails_Success() async throws {
        // Given
        let username = "testUser"
        let jsonString = """
        {"login": "testUser", "id": 1, "avatar_url": "url", "followers": 100, "following": 50, "public_repos": 10, "bio": "A bio"}
        """
        let mockData = Data(jsonString.utf8)
        let mockResponse = HTTPURLResponse(url: URL(string: "https://api.github.com/users/\(username)")!, statusCode: 200, httpVersion: nil, headerFields: nil)!

        MockURLProtocol.requestHandler = { request in
            XCTAssertTrue(request.url?.absoluteString.contains("/users/\(username)") ?? false)
            return (mockResponse, mockData)
        }

        // When
        let userDetail = try await apiService.fetchUserDetails(for: username, token: "mock_token")

        // Then
        XCTAssertEqual(userDetail.login, "testUser")
        XCTAssertEqual(userDetail.followers, 100)
    }
}
