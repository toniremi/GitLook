//
//  EmptyStateView.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//

import SwiftUI

struct EmptyStateView: View {
    // SFSymbol name for the icon
    let systemImageName: String
    // Main title, e.g., "No Users Found"
    let title: String
    // Explanatory message
    let message: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: systemImageName)
                .font(.largeTitle)
                .foregroundColor(.secondary) // A muted color for empty states

            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Make it fill available space
    }
}

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView(
            systemImageName: "person.2.fill",
            title: "No Users Found",
            message: "It seems there are no GitHub users to display right now. Try refreshing the list.")
            .previewLayout(.sizeThatFits)
    }
}
