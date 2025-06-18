//
//  OnboardingFlowView.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/18.
//

import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var currentPage = 0
    
    // create here our onboarding pages
    let onboardingPages: [OnboardingPage] = [
        OnboardingPage(
            assetImage: "logo",
            title: "Welcome to GitLook!",
            description: "This is a simple SwiftUI app, built as a learning, testing, and portfolio showcase project. It is not intended for production use."
        ),
        OnboardingPage(
            systemImage: "folder.fill.badge.person.crop",
            title: "Discover Features",
            description: "Explore a list of GitHub users, view their profiles for key information and public repositories, and seamlessly load selected repositories into a web view."
        ),
        OnboardingPage(
            title: "Connect Your GitHub Account",
            description: "To start exploring, please provide your GitHub Personal Access Token. This is stored securely on your device."
        )
    ]
    
    var body: some View {
        onboardingView
    }
    
    private var onboardingView: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(onboardingPages.indices, id: \.self) { index in
                    if onboardingPages[index].isTokenInputPage {
                        TokenInputOnboardingView(
                            token: $appSettings.githubPersonalAccessToken
                        )
                        .tag(index)
                    } else {
                        VStack(spacing: 32) {
                            if let assetName = onboardingPages[index].assetImage {
                                Image(assetName)
                                    .resizable() // Make it resizable for custom control
                                    .aspectRatio(contentMode: .fit) // Maintain aspect ratio
                                    .frame(width: 120, height: 120) // Adjust size as needed
                                    .clipShape(Circle()) // Example: clip to circle if it's a logo
                                    .padding()
                            } else if let systemName = onboardingPages[index].systemImage {
                                Image(systemName: systemName)
                                    .font(.system(size: 100))
                                    .foregroundStyle(.linearGradient(colors: [.gray, .primary], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .padding()
                                    .symbolEffect(.pulse)
                            }
                            
                            
                            Text(onboardingPages[index].title)
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text(onboardingPages[index].description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .tag(index)
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            if !onboardingPages[currentPage].isTokenInputPage {
                VStack(spacing: 24) {
                    HStack(spacing: 8) {
                        ForEach(0..<onboardingPages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    .padding()
                    
                    Button(action: {
                        withAnimation {
                            if currentPage < onboardingPages.count - 1 {
                                currentPage += 1
                            }
                        }
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            } else {
                Spacer().frame(height: 32)
            }
        }
    }
}

// Preview Provider
struct OnboardingFlowView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFlowView()
            .environmentObject(AppSettings())
    }
}
