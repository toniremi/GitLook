GitLook

A Swift-based iOS client application for Browse GitHub user profiles and their public repositories.
Overview

This iOS application provides a straightforward way to explore GitHub's vast network. Users can browse a list of GitHub users, dive into their detailed profiles, and view their original (non-forked) repositories. For convenience, tapping on any repository will open its corresponding GitHub page directly within the app's web view.
Features

    User List: Browse a list of GitHub users with their avatar images and usernames.
    User Profile: View detailed user information including avatar, username, full name, follower count, and following count.
    Repository List: See a list of a user's public, non-forked repositories, displaying the repository name, primary development language, star count, and description.
    Web View Integration: Tap on any repository to open its GitHub page in an in-app web view.

Getting Started

To run this project locally, you'll need Xcode 15+ and an iOS device or simulator running iOS 17+.
Personal Access Token (PAT)

The GitHub API has strict rate limits for unauthenticated requests. To ensure a smooth experience, it's highly recommended to use a Personal Access Token (PAT) with your GitHub account.

    Generate a PAT:
        Go to your GitHub Settings > Developer settings > Personal access tokens > Tokens (classic).
        Click Generate new token (classic).
        Give it a descriptive name (e.g., "OctoPeek App").
        Select the following scopes:
            public_repo
            read:user
        Generate the token and copy it immediately as you won't see it again.

    Add PAT to the App:
        When you launch the app, navigate to the Settings screen (or similar input screen provided).
        Paste your generated PAT into the designated field. The app will then use this token for authenticated API requests, significantly increasing your rate limit.

Technical Details

This application is built entirely in SwiftUI, leveraging Swift's Concurrency (async/await) for network operations. Data fetching is handled using URLSession, and JSON parsing is done with Codable. The repository web view utilizes WKWebView wrapped in a UIViewRepresentable.
