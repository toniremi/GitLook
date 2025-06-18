//
//  UserDetailView.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//

import SwiftUI

struct UserDetailsView: View {
    // This view expects a fully loaded user detail object
    let user: GithubUserDetail

    var body: some View {
        VStack(spacing: 10) {
            // Icon image
            AsyncImage(url: URL(string: user.avatarUrl)) { phase in
                if let image = phase.image {
                    image.resizable()
                        .transition(.opacity) // Fade in the loaded image
                } else if phase.error != nil {
                    Image(systemName: "person.circle.fill") // Placeholder for error
                        .resizable()
                        .foregroundColor(.gray)
                } else {
                    ProgressView() // Placeholder while loading
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1)) // Subtle border
            .shadow(radius: 5) // Soft shadow for depth
            .animation(.easeOut(duration: 0.3), value: user.avatarUrl)

            // User name
            Text(user.login)
                .font(.title)
                .fontWeight(.bold)

            // Full name (optional, as it can be null)
            if let name = user.name, !name.isEmpty {
                Text(name)
                    .font(.headline)
                    .foregroundColor(.gray)
            }

            // Followers and Following
            HStack(spacing: 20) {
                VStack {
                    Text("\(user.followers)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Followers")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                VStack {
                    Text("\(user.following)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Following")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // include here the email and location if available
            if let location = user.location, !location.isEmpty {
                Text(location)
                    .font(.footnote)
                    .fontWeight(.light)
            }
            
            if let email = user.email, !email.isEmpty {
                Text(email)
                    .font(.footnote)
                    .fontWeight(.light)
            }
            
        }
        .padding() // Padding inside the VStack
        .frame(maxWidth: .infinity) // Make it span the width
        .background(Color(.systemBackground).opacity(0.8)) // Background color for the card
        .cornerRadius(10)
        .shadow(radius: 2) // Subtle shadow for the card
        .padding(.horizontal) // Padding from the edges of its parent view
    }
}

struct UserDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        // for preview simply input some dummy data
        UserDetailsView(user: GithubUserDetail(
            id: 1,
            login: "octocat",
            avatarUrl: "https://avatars.githubusercontent.com/u/583231?v=4",
            name: "The Octocat",
            location: "San Francisco, USA",
            email: "octocat@github.com",
            followers: 56,
            following: 2345
        ))
        .previewLayout(.sizeThatFits) // Adjust preview size to fit content
        .padding()
    }
}
