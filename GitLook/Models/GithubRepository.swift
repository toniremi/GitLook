//
//  GithubRepository.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//

struct GithubRepository: Decodable, Identifiable {
    let id: Int
    let name: String
    let language: String? // can be null
    let stargazersCount: Int
    let description: String
    let html_url: String
    let fork: Bool
}
