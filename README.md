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

### MVP Features

* **User List:** Browse a list of GitHub users with their avatar images and usernames.
* **User Profile:** View detailed user information including avatar, username, full name, follower count, and following count.
* **Repository List:** See a list of a user's public, non-forked repositories, displaying the repository name, primary development language, star count, and description.
* **Web View Integration:** Tap on any repository to open its GitHub page in an in-app web view.

## Polished Version Achieved

After succesfully finishing the MVP and having some more time to spare I decided to gradually continue working on the MVP to introduce QoL updates, polishes and improvements.

### Polished Version Features

* **App Onboarding & initial token input:** Included a simple app onboarding with a proper token input to better resemble a login flow from a production app.
* **User List:** Browse a list of GitHub users with their avatar images and usernames.
* **User List Sorting & Pagination:** Users can be sorted by their username and pagination has been added.
* **User Profile:** View detailed user information including avatar, username, full name, follower count, and following count.
* **Repository List:** See a list of a user's public, non-forked repositories, displaying the repository name, primary development language, star count, and description.
* **Repository List UI tweaks:** Added some tweaks like language color palette like Github native app.
* **Web View Integration:** Tap on any repository to open its GitHub page in an in-app web view.
* **Web View Loading and error:** The web view includes now loading and error handling.
* **Key Chain instead of UserDefaults:** The token is now saved in key chain instead of user defaults.
* **Better errors, loading and placeholder views:** Error messages are more complete and user friendly, there are more loading mechanisms and introduced also placeholder views for when there is no data (Ex: some users have no repositories).
* **App Polishes:** Included AppIcon with appearence as well as app theme to switch between light and dark mode both in app or following system settings.

## Authentication Challenges & Design Decisions

### The Quest for Robust OAuth (PKCE)

After completing the Minimum Viable Product (MVP), my next goal for user authentication was to implement a more robust and secure OAuth 2.0 flow, specifically leveraging the Proof Key for Code Exchange (PKCE) extension. PKCE is crucial for native and mobile applications as it mitigates the authorization code interception attack, even without the ability to securely store a client secret on the device.

### The Client Secret Dilemma

A key challenge arose when considering GitHub's API for authentication within the scope of this client-side SwiftUI application. While PKCE enhances security for public clients, the traditional Authorization Code Flow (even with PKCE) often involves an exchange of an authorization code for an access token on a **server-side component**, where a `client_secret` can be securely stored.

For a purely client-side mobile application like this portfolio project, storing a `client_secret` securely is not feasible. Furthermore, implementing the full Authorization Code Flow with PKCE would typically necessitate building and deploying a dedicated backend server to handle the secure `client_secret` and the token exchange process.

I attempted to integrate several well-known libraries to manage this flow, including:

* [OAuthSwift](https://github.com/OAuthSwift/OAuthSwift)
* [OAuth2](https://github.com/p2/OAuth2)
* [AppAuth-iOS](https://github.com/openid/AppAuth-iOS)

However, all these libraries, when configured for GitHub's Authorization Code Grant type, consistently required a `client_secret` to successfully generate an access token, confirming the need for a server-side component for this specific flow.

### Decision to Pivot

Given the time constraints and the primary objective of this project—to learn, test, and showcase SwiftUI development and GitHub API integration in a simple mobile app, not to build a production-ready authentication system—the added complexity and infrastructure requirements of a backend for OAuth with PKCE were deemed out of scope.

Therefore, for the purpose of this technical assignment and portfolio demonstration, the decision was made to utilize **GitHub Personal Access Tokens (PATs)** for authentication. While PATs are highly effective for development and personal use, and allow immediate access to the GitHub API, it's important to acknowledge their inherent security considerations in a broader context:

* **Broad Permissions:** PATs often grant wide-ranging permissions, depending on how they are scoped.
* **Long-Lived:** Unlike short-lived OAuth tokens that can be refreshed, PATs typically have a longer lifespan, increasing the risk if compromised.
* **User Responsibility:** Users are directly responsible for creating, managing, and revoking their PATs.

This approach streamlines the development for a solo client-side project, allowing focus on the core SwiftUI features and API consumption, while acknowledging the trade-offs made in authentication complexity for this specific learning context. For a production application, a comprehensive OAuth flow with a secure backend would undoubtedly be the preferred and necessary solution.


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

We acknowledge these areas for future enhancement if time allows:

* Better token storage
* Better error handling and UI feedback
* Persistance or caching
* More UI Polish and animations
* No pagination and/or filtering

### Shortcuts Taken for MVP Delivery 

~This means it has already been addressed and implemented before the deadline~

* **~Token Storage (User Defaults)~**: ~For speed of development and simplicity, the GitHub Personal Access Token is currently stored in UserDefaults.~
	* **~Improvement Area~**: ~For a production application, Keychain Services should be used for secure storage of sensitive user data like API tokens. UserDefaults is not encrypted and poses a security risk.~ 
* **~Basic Error Handling & UI Feedback~**: ~While basic error messages are displayed for network failures, the error handling UI is currently minimal.~
	* **~Improvement Area~**: ~Implement more robust and user-friendly error states, potentially with specific actions (e.g., retry buttons that are more prominent, or visually distinct error views).~
* **No Persistence Beyond Token**: User list and repository data are fetched on demand and not persisted locally beyond the current session.
	* **Improvement Area**: For enhanced UX and offline capabilities, consider implementing Core Data or Realm for local caching of user and repository data.
* **~Limited UI Polish & Animations~**: ~The UI focuses on functionality over advanced aesthetics and animations.~
	* **Improvement Area**: Enhance the user interface with custom styling, smoother transitions, and animations to improve the overall user experience.
* **~No Pagination for User Lists/Repositories~**: ~The current implementation fetches a default number of users/repositories. For users with many repositories, this might be incomplete.~
	* **Improvement Area**: Implement pagination for both the user list and repository list to efficiently load larger datasets as the user scrolls.

#### Areas for Future Improvement

* **Comprehensive Unit & UI Testing**: While the MVVM structure facilitates testing, dedicated unit tests for ViewModels and UI tests for critical user flows are essential.
* **User Search Functionality**: Add a search bar to allow users to search for specific GitHub users or repositories.
* **Favorite Users/Repositories**: Allow users to mark certain users or repositories as favorites for quick access.
* **Repository Sorting/Filtering**: Add options to sort repositories by stars, language, last updated, etc.
* **Theming/Dark Mode**: Provide support for light and dark modes.

## Introduced Dependencies during improvements
* [keychain-swift](https://github.com/evgenyneu/keychain-swift) => Helper functions for saving text in Keychain securely for iOS, OS X, tvOS and watchOS. 

## Sources used

Github List Users => [https://docs.github.com/en/rest/users/users?apiVersion=2022-11-28#list-users](https://docs.github.com/en/rest/users/users?apiVersion=2022-11-28#list-users)

Github Get User => [https://docs.github.com/en/rest/users/users?apiVersion=2022-11-28#get-a-user](https://docs.github.com/en/rest/users/users?apiVersion=2022-11-28#get-a-user)

Github List User Repositories => [https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-repositories-for-a-user](https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-repositories-for-a-user)

WebView using UIPresentable => [https://sarunw.com/posts/swiftui-webview/](https://sarunw.com/posts/swiftui-webview/)

Onboarding Flow => [https://dockui.com/templates/onboarding-flow-template](https://dockui.com/templates/onboarding-flow-template)

Custom Loading View => [https://medium.com/@garejakirit/creating-various-loading-views-in-swiftui-76e31509cdee](https://medium.com/@garejakirit/creating-various-loading-views-in-swiftui-76e31509cdee)