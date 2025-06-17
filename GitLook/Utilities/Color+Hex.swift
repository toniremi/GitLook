//
//  Color+Hex.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/17.
//

import SwiftUI

extension Color {
    /// Initializes a SwiftUI Color from a hexadecimal string (e.g., "#RRGGBB", "RRGGBBAA", "RRGGBB", or "RRGGBBAA").
    ///
    /// - Parameter hex: The hexadecimal color string. Supports 6-digit (RGB) and 8-digit (RGBA) formats,
    ///   with or without a leading '#'.
    /// - Returns: A SwiftUI Color initialized from the hex string, or `nil` if the string is invalid.
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        let scanner = Scanner(string: hexSanitized)

        guard scanner.scanHexInt64(&rgb) else {
            return nil // Failed to parse hex
        }

        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double

        if hexSanitized.count == 6 { // RGB format
            red = Double((rgb & 0xFF0000) >> 16) / 255.0
            green = Double((rgb & 0x00FF00) >> 8) / 255.0
            blue = Double(rgb & 0x0000FF) / 255.0
            alpha = 1.0 // Default to opaque
        } else if hexSanitized.count == 8 { // RGBA format
            red = Double((rgb & 0xFF000000) >> 24) / 255.0
            green = Double((rgb & 0x00FF0000) >> 16) / 255.0
            blue = Double((rgb & 0x0000FF00) >> 8) / 255.0
            alpha = Double(rgb & 0x000000FF) / 255.0
        } else {
            return nil // Invalid hex string length
        }

        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }

    /// Convenience static method to create a Color from a hex string, providing a fallback.
    ///
    /// - Parameters:
    ///   - hex: The hexadecimal color string.
    ///   - defaultColor: The Color to return if the hex string is invalid. Defaults to gray.
    /// - Returns: A SwiftUI Color from the hex string, or the `defaultColor` if invalid.
    static func fromHex(_ hex: String, defaultColor: Color = .gray) -> Color {
        return Color(hex: hex) ?? defaultColor
    }
}
