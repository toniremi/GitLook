//
//  Error.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//

import SwiftUI

struct ErrorView: View {
    let message: String
    var actionTitle: String? = nil
    var retryAction: (() -> Void)? // A closure to be called when "Retry" is tapped

    // create an init so we can construct this view with loading text optionally
    init(message: String, actionTitle: String? = nil, retryAction: (() -> Void)? ) {
        // required options
        self.message = message
        // optionals
        self.actionTitle = actionTitle
        self.retryAction = retryAction
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle.fill") // A clear error icon
                .font(.largeTitle)
                .foregroundColor(.red)

            Text("Oops! Something went wrong.")
                .font(.headline)
                .multilineTextAlignment(.center)

            Text(message) // The specific error message from the ViewModel
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // include a button with the retry action only if there is one present
            if let action = retryAction {
                Button(action: action) {
                    // use Retry as the default action title
                    Text(actionTitle ?? "Retry")
                        .font(.headline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Make it fill available space
        .background(Color(.systemBackground).opacity(0.8)) // Slightly transparent background
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding() // Padding from the screen edges
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(message: "Failed to load data due to a network connection issue. Please check your internet connection and try again.", retryAction: {})
            .previewLayout(.sizeThatFits)
    }
}
