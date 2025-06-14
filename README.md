# GitLook

A Swift-based iOS client application for Browse GitHub user profiles and their public repositories.
Overview

This iOS application provides a straightforward way to explore GitHub's vast network. Users can browse a list of GitHub users, dive into their detailed profiles, and view their original (non-forked) repositories. For convenience, tapping on any repository will open its corresponding GitHub page directly within the app's web view.
Features

## Minimum Viable Product (MVP) Achieved

This project successfully implements the core features as outlined in the minimum specifications:

* **User List Screen**: Displays a scrollable list of GitHub users, each featuring their icon image and username. Tapping a row seamlessly navigates to the User Repository Screen.
* **User Repository Screen**: 
	* **Detailed User Information**: At the top, a dedicated section presents the user's icon image, username, full name, number of followers, number of following and as extra location and email if available.
	* **Repository List**: Below the user details, a comprehensive list of their non-forked repositories is displayed. Each row includes the repository name, development language, number of stars, and description.
* **Web View Integration**: Tapping any repository in the list will display its GitHub URL in an in-app WebView, providing a quick way to access the full repository details.

## MVP Features

* User List: Browse a list of GitHub users with their avatar images and usernames.
* User Profile: View detailed user information including avatar, username, full name, follower count, and following count.
* Repository List: See a list of a user's public, non-forked repositories, displaying the repository name, primary development language, star count, and description.
* Web View Integration: Tap on any repository to open its GitHub page in an in-app web view.

## Project Branches

This project utilizes a clear branching strategy to illustrate its development lifecycle:

* [mvp branch](https://github.com/toniremi/GitLook/tree/mvp): This branch represents the Minimum Viable Product (MVP). It contains the core features and functionality as initially defined, delivered rapidly to establish a baseline.
* [main branch](https://github.com/toniremi/GitLook): This branch serves as the primary development line. It contains all the features from the mvp branch plus subsequent incremental improvements, refinements, and new features. It showcases the continuous evolution and enhancement of the application beyond its initial MVP release.

## Getting Started

To run this project locally, you'll need Xcode 15+ and an iOS device or simulator running iOS 17+.
as well as a Github Personal Access Token (PAT)

The GitHub API has strict rate limits for unauthenticated requests. To ensure a smooth experience, it's highly recommended to use a Personal Access Token (PAT) with your GitHub account.

Generate a Personal Access Token (PAT):

1.  Go to your [GitHub](https://github.com/) `Settings` > `Developer settings` > `Personal access tokens` > `Tokens (classic)`.
2. Click **Generate new token (classic)**.
3. Give it a descriptive name (e.g., "Github App").
4. Select the following scopes:
	* **public_repo**
	* **read:user**
5. Generate the token and copy it immediately as you won't see it again.

### Adding the PAT into the app.

When you launch the app, you will be presented automatically with an App Setup page to insert the PAT. 
Paste your generated PAT into the designated field. Then click on **Save Token**.
The app will then use this token for authenticated API requests.

## Technical Details

This application is built entirely in SwiftUI, leveraging Swift's Concurrency (async/await) for network operations. Data fetching is handled using URLSession, and JSON parsing is done with Codable. The repository web view utilizes WKWebView wrapped in a UIViewRepresentable. 
The architecture broadly follows the **MVVM (Model-View-ViewModel)** pattern for clear separation of concerns, promoting maintainability and testability.

## Design and Development Considerations (Shortcuts & Improvements)

To deliver this MVP quickly (aprox. 5-6 hours) and demonstrate core functionality, certain design and implementation decisions were made.
We acknowledge these areas for future enhancement:

### Shortcuts Taken for MVP Delivery 

~This means it has already been addressed and implemented~

* **~Token Storage (User Defaults)~**: ~For speed of development and simplicity, the GitHub Personal Access Token is currently stored in UserDefaults.~
	* **~Improvement Area~**: ~For a production application, Keychain Services should be used for secure storage of sensitive user data like API tokens. UserDefaults is not encrypted and poses a security risk.~ 
* **~Basic Error Handling & UI Feedback~**: ~While basic error messages are displayed for network failures, the error handling UI is currently minimal.~
	* **~Improvement Area~**: ~Implement more robust and user-friendly error states, potentially with specific actions (e.g., retry buttons that are more prominent, or visually distinct error views).~
* **No Persistence Beyond Token**: User list and repository data are fetched on demand and not persisted locally beyond the current session.
	* **Improvement Area**: For enhanced UX and offline capabilities, consider implementing Core Data or Realm for local caching of user and repository data.
* **Limited UI Polish & Animations**: The UI focuses on functionality over advanced aesthetics and animations.
	* **Improvement Area**: Enhance the user interface with custom styling, smoother transitions, and animations to improve the overall user experience.
* **No Pagination for User Lists/Repositories**: The current implementation fetches a default number of users/repositories. For users with many repositories, this might be incomplete.
	* **Improvement Area**: Implement pagination for both the user list and repository list to efficiently load larger datasets as the user scrolls.

#### Areas for Future Improvement

* **Comprehensive Unit & UI Testing**: While the MVVM structure facilitates testing, dedicated unit tests for ViewModels and UI tests for critical user flows are essential.
* **User Search Functionality**: Add a search bar to allow users to search for specific GitHub users or repositories.
* **Favorite Users/Repositories**: Allow users to mark certain users or repositories as favorites for quick access.
* **Repository Sorting/Filtering**: Add options to sort repositories by stars, language, last updated, etc.
* **Theming/Dark Mode**: Provide support for light and dark modes.

## Introduced Dependencies during improvements
* [keychain-swift](https://github.com/evgenyneu/keychain-swift) => Helper functions for saving text in Keychain securely for iOS, OS X, tvOS and watchOS. 

## Sources used to complete the MVP

Github List Users => [https://docs.github.com/en/rest/users/users?apiVersion=2022-11-28#list-users](https://docs.github.com/en/rest/users/users?apiVersion=2022-11-28#list-users)

Github Get User => [https://docs.github.com/en/rest/users/users?apiVersion=2022-11-28#get-a-user](https://docs.github.com/en/rest/users/users?apiVersion=2022-11-28#get-a-user)

Github List User Repositories => [https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-repositories-for-a-user](https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-repositories-for-a-user)

WebView using UIPresentable => [https://sarunw.com/posts/swiftui-webview/](https://sarunw.com/posts/swiftui-webview/)

