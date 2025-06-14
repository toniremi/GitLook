//
//  GithubUser.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//

struct GithubUser: Decodable, Identifiable {
    let id: Int
    let login: String
    let avatarUrl: String
    let url: String
}
