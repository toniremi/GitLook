//
//  TokenInputOnboardingView.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/18.
//

import SwiftUI

struct TokenInputOnboardingView: View {
    @Binding var token: String // Bind directly to the token in AppSettings

    @State private var internalTokenInput: String = ""
    @State private var showSaveConfirmation: Bool = false // Can be removed if not used for UI feedback

    var isTokenValid: Bool {
        !internalTokenInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && internalTokenInput.count > 10 // Basic validation
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Enter Your GitHub Token")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("A Personal Access Token (PAT) is required to access GitHub's public API. It's stored securely on your device.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            SecureField("GitHub Personal Access Token", text: $internalTokenInput)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 32)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            Button(action: {
                // Save the token
                token = internalTokenInput.trimmingCharacters(in: .whitespacesAndNewlines)
            }) {
                Text("Start using GitLook")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isTokenValid ? Color.green : Color.gray)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .disabled(!isTokenValid)

            Spacer()
        }
        .onAppear {
            internalTokenInput = token
        }
        // Optional: If you want a quick visual confirmation after saving
        .alert(isPresented: $showSaveConfirmation) {
            Alert(title: Text("Token Saved!"), message: Text("You can now start using GitLook."), dismissButton: .default(Text("OK")))
        }
    }
}

