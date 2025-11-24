import SwiftUI

// MARK: - Color Palette
// A single file with the project's color palette
// For easy import into any project without additional steps

extension Color {
    
    // MARK: - Main background colors
    /// Primary dark app background
    static let backgroundPrimary = Color(hex: "#1a1a2e") ?? .black
    
    /// Secondary dark background for cards and sections
    static let backgroundSecondary = Color(hex: "#16213e") ?? .black
    
    /// Semi-transparent background for cards
    static let backgroundCard = Color.white.opacity(0.05)
    
    /// Background for input fields
    static let backgroundInput = Color.white.opacity(0.1)
    
    // MARK: - Primary Colors
    /// Main red app color
    static let primary = Color(hex: "#D32F2F") ?? .red
    
    /// Lighter shade of the primary color
    static let primaryLight = Color(hex: "#B71C1C") ?? .red
    
    /// Darker shade of the primary color
    static let primaryDark = primary.opacity(0.8)
    
    // MARK: - Secondary Colors
    /// Main blue color
    static let secondary = Color(hex: "#2196F3") ?? .blue
    
    /// Lighter shade of the secondary color
    static let secondaryLight = secondary.opacity(0.8)
    
    /// Darker shade of the secondary color
    static let secondaryDark = Color(hex: "#1976D2") ?? .blue
    
    // MARK: - Accent Colors
    /// Purple accent - used for the calculator
    static let accent1 = Color(hex: "#6A1B9A") ?? .purple
    
    /// Green accent - used for history and currency
    static let accent2 = Color(hex: "#43A047") ?? .green
    
    /// Orange accent - used for tips and settings
    static let accent3 = Color(hex: "#FF5722") ?? .orange
    
    /// Dark purple accent - used for settings
    static let accent4 = Color(hex: "#9C27B0") ?? .purple
    
    /// Gray-blue accent - used for data management
    static let accent5 = Color(hex: "#607D8B") ?? .gray
    
    /// Pink accent - used for profile and quick actions
    static let accent6 = Color(hex: "#E91E63") ?? .pink
    
    // MARK: - Status Colors
    /// Success color
    static let success = Color(hex: "#4CAF50") ?? .green
    
    /// Light shade of success
    static let successLight = success.opacity(0.1)
    
    /// Border for success elements
    static let successBorder = success.opacity(0.3)
    
    /// Error color
    static let error = Color(hex: "#F44336") ?? .red
    
    /// Light shade of error
    static let errorLight = error.opacity(0.1)
    
    /// Border for error elements
    static let errorBorder = error.opacity(0.3)
    
    /// Warning color
    static let warning = Color(hex: "#FF5722") ?? .orange
    
    /// Light shade of warning
    static let warningLight = warning.opacity(0.1)
    
    /// Border for warning elements
    static let warningBorder = warning.opacity(0.3)
    
    // MARK: - Text Colors
    /// Primary text color (white)
    static let textPrimary = Color.white
    
    /// Secondary text color (80% opacity)
    static let textSecondary = Color.white.opacity(0.8)
    
    /// Tertiary text color (70% opacity)
    static let textTertiary = Color.white.opacity(0.7)
    
    /// Quaternary text color (60% opacity)
    static let textQuaternary = Color.white.opacity(0.6)
    
    /// Disabled text (30% opacity)
    static let textDisabled = Color.white.opacity(0.3)
    
    // MARK: - Border Colors
    /// Primary border color
    static let borderPrimary = Color.white.opacity(0.2)
    
    /// Secondary border color
    static let borderSecondary = Color.white.opacity(0.1)
    
    /// Accent border color
    static let borderAccent = Color.white.opacity(0.15)
    
    // MARK: - Shadow Colors
    /// Primary shadow color
    static let shadowPrimary = Color.black.opacity(0.3)
    
    /// Secondary shadow color
    static let shadowSecondary = Color.black.opacity(0.2)
    
    /// Shadow color for cards
    static let shadowCard = Color.black.opacity(0.15)
    
    // MARK: - Additional colors for gradients
    /// Gradient colors for onboarding
    static let onboardingGradient1 = [accent1, accent2]
    static let onboardingGradient2 = [accent2, accent3]
    static let onboardingGradient3 = [accent3, accent1]
    
    /// Gradient colors for settings
    static let settingsGradient = [accent4, accent5]
    
    /// Gradient colors for tab bar
    static let tabBarGradient = [backgroundCard.opacity(0.95), backgroundSecondary.opacity(0.9)]
}

// MARK: - HEX Color Extension
extension Color {
    /// Create color from HEX string
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Convert color to HEX string
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        let hex = String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        return hex
    }
    
    /// Get RGB components of the color
    var rgbComponents: (red: Double, green: Double, blue: Double, alpha: Double)? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        return (
            red: Double(components[0]),
            green: Double(components[1]),
            blue: Double(components[2]),
            alpha: components.count > 3 ? Double(components[3]) : 1.0
        )
    }
    
    /// Create a lighter version of the color
    func lighter(by percentage: CGFloat = 0.3) -> Color {
        guard let components = rgbComponents else { return self }
        return Color(
            red: min(1.0, components.red + percentage),
            green: min(1.0, components.green + percentage),
            blue: min(1.0, components.blue + percentage),
            opacity: components.alpha
        )
    }
    
    /// Create a darker version of the color
    func darker(by percentage: CGFloat = 0.3) -> Color {
        guard let components = rgbComponents else { return self }
        return Color(
            red: max(0.0, components.red - percentage),
            green: max(0.0, components.green - percentage),
            blue: max(0.0, components.blue - percentage),
            opacity: components.alpha
        )
    }
}

// MARK: - Predefined Gradients
extension LinearGradient {
    /// Main app gradient
    static let primaryGradient = LinearGradient(
        colors: [Color.primary, Color.primaryLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Gradient for cards
    static let cardGradient = LinearGradient(
        colors: [Color.backgroundCard, Color.backgroundCard.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Gradient for buttons
    static let buttonGradient = LinearGradient(
        colors: [Color.accent1, Color.accent1.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Gradient for headers
    static let headerGradient = LinearGradient(
        colors: [Color.accent4, Color.accent5],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Gradient for tab bar
    static let tabBarGradient = LinearGradient(
        colors: [Color.backgroundCard.opacity(0.95), Color.backgroundSecondary.opacity(0.9)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Color Utilities
struct ColorUtilities {
    /// Check if the color is light
    static func isLightColor(_ color: Color) -> Bool {
        guard let components = color.rgbComponents else { return false }
        let brightness = (components.red * 299 + components.green * 587 + components.blue * 114) / 1000
        return brightness > 0.5
    }
    
    /// Get contrasting color (black or white)
    static func contrastColor(for color: Color) -> Color {
        return isLightColor(color) ? .black : .white
    }
    
    /// Create a random accent color
    static func randomAccentColor() -> Color {
        let accentColors = [Color.accent1, Color.accent2, Color.accent3, Color.accent4, Color.accent5, Color.accent6]
        return accentColors.randomElement() ?? Color.accent1
    }
    
    /// Get accent color by index (for cyclic use)
    static func accentColor(at index: Int) -> Color {
        let accentColors = [Color.accent1, Color.accent2, Color.accent3, Color.accent4, Color.accent5, Color.accent6]
        return accentColors[index % accentColors.count]
    }
}

// MARK: - Color Constants for Use in Code
struct AppColors {
    // Main colors
    static let primary = Color.primary
    static let secondary = Color.secondary
    static let background = Color.backgroundPrimary
    static let surface = Color.backgroundSecondary
    
    // Accent colors
    static let accent1 = Color.accent1
    static let accent2 = Color.accent2
    static let accent3 = Color.accent3
    static let accent4 = Color.accent4
    static let accent5 = Color.accent5
    static let accent6 = Color.accent6
    
    // Text colors
    static let textPrimary = Color.textPrimary
    static let textSecondary = Color.textSecondary
    static let textTertiary = Color.textTertiary
    
    // Status colors
    static let success = Color.success
    static let error = Color.error
    static let warning = Color.warning
}

/*
 USAGE:
 
 1. Import into project:
    import SwiftUI
    // Copy the contents of this file into the project
 
 2. Using colors:
    Color.backgroundPrimary
    Color.accent1
    Color.textPrimary
    LinearGradient.primaryGradient
 
 3. Using utilities:
    ColorUtilities.isLightColor(Color.accent1)
    ColorUtilities.contrastColor(for: Color.backgroundPrimary)
    ColorUtilities.randomAccentColor()
 
 4. HEX conversion:
    Color(hex: "#FF5722")
    Color.accent3.toHex()
 
 5. Color modification:
    Color.accent1.lighter(by: 0.2)
    Color.accent1.darker(by: 0.3)
 
 ALL COLORS ARE ORGANIZED BY CATEGORIES:
 - Background colors (background)
 - Primary colors (primary/secondary)
 - Accent colors (accent1-accent6)
 - Status colors (success/error/warning)
 - Text colors (text)
 - Border colors (border)
 - Shadow colors (shadow)
*/
