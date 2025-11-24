import SwiftUI

struct AppTypography {

    // MARK: - Font Sizes
    enum FontSize {
        static let display: CGFloat = 32
        static let title: CGFloat = 24
        static let headline: CGFloat = 20
        static let body: CGFloat = 18
        static let caption: CGFloat = 14
    }

    // MARK: - Font Weights
    enum FontWeight {
        static let display = Font.Weight.bold
        static let title = Font.Weight.semibold
        static let headline = Font.Weight.medium
        static let body = Font.Weight.regular
        static let caption = Font.Weight.light
    }

    // MARK: - Custom Fonts (Nunito)
    static let customFontName = "Nunito"

    // MARK: - Font Styles
    static func display() -> Font {
        .custom(customFontName, size: FontSize.display)
        .weight(FontWeight.display)
    }

    static func title() -> Font {
        .custom(customFontName, size: FontSize.title)
        .weight(FontWeight.title)
    }

    static func headline() -> Font {
        .custom(customFontName, size: FontSize.headline)
        .weight(FontWeight.headline)
    }

    static func body() -> Font {
        .custom(customFontName, size: FontSize.body)
        .weight(FontWeight.body)
    }

    static func caption() -> Font {
        .custom(customFontName, size: FontSize.caption)
        .weight(FontWeight.caption)
    }
}

// MARK: - Font Extension for Easy Use
extension Font {
    static let appDisplay = AppTypography.display()
    static let appTitle = AppTypography.title()
    static let appHeadline = AppTypography.headline()
    static let appBody = AppTypography.body()
    static let appCaption = AppTypography.caption()
}

// MARK: - Text Style Modifiers
struct DisplayTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.appDisplay)
            .foregroundColor(.textPrimary)
    }
}

struct TitleTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.appTitle)
            .foregroundColor(.textPrimary)
    }
}

struct HeadlineTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.appHeadline)
            .foregroundColor(.textPrimary)
    }
}

struct BodyTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.appBody)
            .foregroundColor(.textSecondary)
    }
}

struct CaptionTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.appCaption)
            .foregroundColor(.textTertiary)
    }
}

// MARK: - View Extension for Text Styles
extension View {
    func displayTextStyle() -> some View {
        modifier(DisplayTextStyle())
    }

    func titleTextStyle() -> some View {
        modifier(TitleTextStyle())
    }

    func headlineTextStyle() -> some View {
        modifier(HeadlineTextStyle())
    }

    func bodyTextStyle() -> some View {
        modifier(BodyTextStyle())
    }

    func captionTextStyle() -> some View {
        modifier(CaptionTextStyle())
    }
}
