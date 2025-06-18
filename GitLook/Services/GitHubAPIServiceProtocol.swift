//
//  GitHubAPIServiceProtocol.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/18.
//

import Foundation

protocol GitHubAPIServiceProtocol {
    func fetchUsers(token: String, since: Int?, perPage: Int) async throws -> [GithubUser]
    func fetchRepositories(for username: String, token: String) async throws -> [GithubRepository]
    func fetchUserDetails(for username: String, token: String) async throws -> GithubUserDetail
}
