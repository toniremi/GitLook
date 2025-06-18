//
//  LanguageColorProvider.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/17.
//

import Foundation
import SwiftUI // Import SwiftUI for the Color type

class LanguageColorProvider {
    // We'll use a singleton pattern so it's initialized only once
    static let shared = LanguageColorProvider()
    
    private var languageColors: LanguageColorsData?

    // Private initializer to enforce singleton pattern
    private init() {
        loadColors()
    }

    // Loads the colors.json file from the app bundle
    private func loadColors() {
        // Find the URL for colors.json in the main bundle
        guard let url = Bundle.main.url(forResource: "githublangs", withExtension: "json") else {
            print("Error: githublangs.json not found in app bundle.")
            return
        }

        do {
            let data = try Data(contentsOf: url) // Load data from the URL
            let decoder = JSONDecoder()
            // Decode the JSON data into our LanguageColorsData [String: String]
            languageColors = try decoder.decode(LanguageColorsData.self, from: data)
            print("Successfully loaded language colors from colors.json.")
        } catch {
            print("Error decoding language colors JSON: \(error.localizedDescription)")
            languageColors = nil
        }
    }


    // Public method to get a SwiftUI.Color for a given programming language name
    func color(for language: String?) -> Color {
        guard let language = language else {
            // Return a default color (e.g., gray) if the language is nil
            return .gray
        }
        
        // Try to find the language directly in the loaded data
        if let hex = languageColors?[language] {
            return Color.fromHex(hex)
        }
        
        // Fallback: If direct match fails, try a case-insensitive match.
        // Some languages might have slight casing differences.
        for (key, hex) in languageColors ?? [:] {
            if key.lowercased() == language.lowercased() {
                return Color.fromHex(hex)
            }
        }
        
        // Return a default color if the language is not found in the palette
        print("Warning: Color not found for language: \(language). Using default gray.")
        return .gray
    }
}
