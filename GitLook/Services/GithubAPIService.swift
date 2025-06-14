//
//  GithubAPIService.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The URL provided was invalid."
        case .noData: return "No data was received from the server."
        case .decodingError(let error): return "Failed to decode the response: \(error.localizedDescription)"
        case .networkError(let error): return "Network request failed: \(error.localizedDescription)"
        case .httpError(let statusCode): return "HTTP Error: \(statusCode)"
        }
    }
}

class GitHubAPIService {
    /// Generic function to make authenticated GitHub API requests
    /// It is using: [https://docs.github.com/en/rest/quickstart?apiVersion=2022-11-28]
    /// - Parameters:
    ///     - url: The github url we want to make a request for
    ///     - personalAccessToken: the personal access token that the user generated
    func performRequest<T: Decodable>(url: URL, personalAccessToken: String) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // Add Authorization header with Personal Access Token
        if personalAccessToken.isEmpty == false {
            request.setValue("token \(personalAccessToken)", forHTTPHeaderField: "Authorization")
        } else {
            print("Warning: No Personal Access Token found. API requests might be rate-limited.")
        }

        // Set User-Agent header (GitHub API requires it)
        request.setValue("GitHubClientAppSwiftUI", forHTTPHeaderField: "User-Agent")


        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(NSError(domain: "Invalid Response", code: 0, userInfo: nil))
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase // GitHub API uses snake_case
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    /// Fetch GitHub Users
    /// - Parameters:
    ///     - token: The personal access token neded for the request
    func fetchUsers(token: String) async throws -> [GithubUser] {
        guard let url = URL(string: "https://api.github.com/users") else {
            throw APIError.invalidURL
        }
        return try await performRequest(url: url, personalAccessToken: token)
    }

    /// Fetch Repositories for a specific user
    /// - Parameters:
    ///     - username: The user we want to fetch repositories for
    ///     - token: The personal access token neded for the request
    func fetchRepositories(for username: String, token: String) async throws -> [GithubRepository] {
        guard let url = URL(string: "https://api.github.com/users/\(username)/repos") else {
            throw APIError.invalidURL
        }
        return try await performRequest(url: url, personalAccessToken: token)
    }

    /// Fetch User details for a user
    /// - Parameters:
    ///     - username: The user we want to fetch details for
    ///     - token: The personal access token neded for the request
    func fetchUserDetails(for username: String, token: String) async throws -> GithubUserDetail {
        guard let url = URL(string: "https://api.github.com/users/\(username)") else {
            throw APIError.invalidURL
        }
        return try await performRequest(url: url, personalAccessToken: token)
    }
}
