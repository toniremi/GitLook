//
//  GithubUserDetails.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//

struct GithubUserDetail: Decodable {
    let login: String
    let avatarUrl: String
    let name: String? // full name
    let location: String
    let email: String
    let followers: Int
    let following: Int
}
