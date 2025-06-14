//
//  GithubUserDetails.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//
import Foundation

struct GithubUserDetail: Decodable, Equatable {
    let id: Int
    let login: String
    let avatarUrl: String
    let name: String? // full name can be null
    let location: String? // user location can be null
    let email: String? // user email can be null
    let followers: Int
    let following: Int
}
