//
//  GithubRepository.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//
import Foundation

struct GithubRepository: Decodable, Identifiable {
    let id: Int
    let name: String
    let language: String? // can be null
    let stargazersCount: Int
    let description: String? // can be null
    let htmlUrl: String
    let fork: Bool
}
