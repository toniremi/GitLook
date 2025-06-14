//
//  Error.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/14.
//

import SwiftUI

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void // A closure to be called when "Retry" is tapped

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

            Button(action: retryAction) {
                Text("Retry")
                    .font(.headline)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Make it fill available space
        .background(Color.white.opacity(0.8)) // Slightly transparent background
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
