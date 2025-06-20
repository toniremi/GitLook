//
//  UserRepositoriesListView.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//

import SwiftUI
import WebKit

struct UserRepositoriesListView: View {
    // This view expects an array of repositories
    let repositories: [GithubRepository]
    
    var body: some View {
        List { // The List itself does not take a Binding<Data> here
            if repositories.isEmpty {
                // use our new Empty State View
                EmptyStateView(
                    systemImageName: "folder.fill.badge.questionmark",
                    title: "No Repositories",
                    message: "This user has no public, non-forked repositories to display.").transition(.opacity)
            } else {
                // Here, ForEach takes your array directly because GitHubRepository is Identifiable
                ForEach(repositories) { repo in // This line should now be fine
                    // NavigationLink to WebView
                    NavigationLink(destination: WebViewContainer(url: repo.htmlUrl, title: repo.name)) {
                        LazyVStack(alignment: .leading, spacing: 5) {
                            Text(repo.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if let description = repo.description, !description.isEmpty {
                                Text(description)
                                    .font(.body)
                                    .lineLimit(3)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text("\(repo.stargazersCount)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                if let language = repo.language, !language.isEmpty {
                                    
                                    HStack {
                                        // The color circle
                                        Circle().fill(LanguageColorProvider.shared.color(for: language)) // Get color from provider
                                            .frame(width: 10, height: 10) // Set size for the circle
                                            .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 0.5)) // Optional: subtle border
                                        
                                        // The language text
                                        Text(language)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                }
                            }
                        }
                        .padding(.vertical, 5)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }.animation(.default, value: repositories)
            }
        }
        .listStyle(.plain)
    }
}

struct UserRepositoriesListView_Previews: PreviewProvider {
    static var previews: some View {
        // No repositories preview
        UserRepositoriesListView(repositories: [])
            .previewLayout(.sizeThatFits)
        // List with Repositories
        UserRepositoriesListView(repositories: [
            GithubRepository(
                id: 1,
                name: "my-awesome-repo",
                language: "Swift",
                stargazersCount: 150,
                description: "A cool project built in Swift.",
                htmlUrl: "https://github.com/octocat/my-awesome-repo",
                
                fork: false),
            GithubRepository(
                id: 2,
                name: "another-project",
                language: "Python",
                stargazersCount: 30,
                description: "Data science exploration.",
                htmlUrl: "https://github.com/octocat/another-project",
                fork: false),
            GithubRepository(
                id: 3,
                name: "old-fork",
                language: "JavaScript",
                stargazersCount: 5,
                description: "An old project I forked (this one should be filtered out by the ViewModel).",
                htmlUrl: "https://github.com/octocat/old-fork",
                fork: true)
        ])
    }
}
