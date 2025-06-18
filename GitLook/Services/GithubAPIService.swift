//
//  GithubAPIService.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error) // Original network errors from URLSession
    case httpError(Int) // Generic HTTP error with status code
    case unauthorized(message: String?) // Specific for 401, with optional message from API
    case apiError(statusCode: Int, message: String) // For other non-2xx errors with an API message
    case decodingError(Error) // For JSON decoding failures
    case unknownError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL was invalid. Please check the application's configuration."
        case .networkError(let error):
            // Provide a more user-friendly message for common network issues
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet:
                    return "No internet connection. Please check your network settings."
                case .timedOut:
                    return "The network request timed out. Please try again."
                case .cannotConnectToHost:
                    return "Could not connect to the server. The GitHub API might be temporarily unavailable."
                default:
                    return "A network error occurred: \(urlError.localizedDescription)"
                }
            }
            return "A network error occurred: \(error.localizedDescription)"
        case .httpError(let statusCode):
            return "Server responded with status code \(statusCode). Please try again later."
        case .unauthorized(let message):
            // More helpful message for 401
            if let msg = message, !msg.isEmpty {
                return "Authentication failed: \(msg). Please check your Personal Access Token (PAT)."
            }
            return "Authentication failed (401 Unauthorized). Please ensure your Personal Access Token (PAT) is correct and has the necessary permissions."
        case .apiError(let statusCode, let message):
            // For other API-specific errors with a message
            return "GitHub API Error (\(statusCode)): \(message). Please try again."
        case .decodingError(let error):
            // Detailed message for decoding errors (useful for development, can be more generic for user)
            return "Failed to process data from the server. \(error.localizedDescription)"
        case .unknownError:
            return "An unexpected error occurred. Please try again."
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
        
        // MARK: - Debugging: Print Raw JSON Response
        if let jsonString = String(data: data, encoding: .utf8) {
            print("--- Raw JSON Response ---")
            print(jsonString)
            print("-------------------------")
        } else {
            print("--- Could not convert data to string for debugging ---")
        }


        // properly check status code to return a more complete error
        // the aim is to using our new ErrorView to display a more user friendly error in the UI
        guard (200...299).contains(httpResponse.statusCode) else {
            // Attempt to decode a GitHub API error response
            do {
                let apiErrorResponse = try JSONDecoder().decode(GitHubAPIErrorResponse.self, from: data)
                
                // Specific handling for 401 Unauthorized
                if httpResponse.statusCode == 401 {
                    throw APIError.unauthorized(message: apiErrorResponse.message)
                } else {
                    // Other non-2xx status codes that have a message
                    throw APIError.apiError(statusCode: httpResponse.statusCode, message: apiErrorResponse.message)
                }
            } catch let decodingError as DecodingError {
                // If we couldn't decode a GitHubAPIErrorResponse, it might be a generic HTTP error
                // or a different error format. Log the decoding error for debugging.
                print("Failed to decode GitHubAPIErrorResponse for status \(httpResponse.statusCode): \(decodingError.localizedDescription)")
                // Fallback to generic HTTP error, but give specific 401 if it's 401
                if httpResponse.statusCode == 401 {
                    // throw unauthorized error without specific message
                    throw APIError.unauthorized(message: nil)
                } else {
                    // throw generic http error using the status code
                    throw APIError.httpError(httpResponse.statusCode)
                }
            } catch {
                // Catch any other errors during the error decoding process
                print("An unexpected error occurred while trying to decode API error: \(error.localizedDescription)")
                
                if httpResponse.statusCode == 401 {
                    // throw unauthorized error without specific message
                    throw APIError.unauthorized(message: nil)
                } else {
                    // throw generic http error using the status code
                    throw APIError.httpError(httpResponse.statusCode)
                }
            }
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase // GitHub API uses snake_case
            return try decoder.decode(T.self, from: data)
        } catch {
            // Debugging: Print Decoding Error details
            print("--- Decoding Error Details for successful HTTP status ---")
            print("Error: \(error.localizedDescription)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .dataCorrupted(let context):
                    print("Data corrupted: \(context.debugDescription)")
                case .keyNotFound(let key, let context):
                    print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                case .typeMismatch(let type, let context):
                    print("Type mismatch for \(type): \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                case .valueNotFound(let type, let context):
                    print("Value not found for \(type): \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                @unknown default:
                    print("Unknown decoding error")
                }
            }
            print("----------------------------")
            
            // throw a decoding error
            throw APIError.decodingError(error)
        }
    }

    /// Fetch GitHub Users
    /// - Parameters:
    ///     - token: The personal access token neded for the request
    func fetchUsers(token: String, since: Int?, perPage: Int) async throws -> [GithubUser] {
        
        var urlString = "https://api.github.com/users?per_page=\(perPage)"
        if let sinceId = since {
            urlString += "&since=\(sinceId)"
        }
        
        guard let url = URL(string: urlString) else {
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
