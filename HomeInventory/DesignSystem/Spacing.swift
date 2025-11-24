import SwiftUI

struct AppSpacing {

    // MARK: - Spacing Values
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48

    // MARK: - Corner Radius
    static let radiusSmall: CGFloat = 8
    static let radiusMedium: CGFloat = 12
    static let radiusLarge: CGFloat = 16
    static let radiusXLarge: CGFloat = 20

    // MARK: - Shadow
    static let shadowRadius: CGFloat = 8
    static let shadowX: CGFloat = 0
    static let shadowY: CGFloat = 4

    // MARK: - Border
    static let borderWidth: CGFloat = 1
    static let borderWidthThick: CGFloat = 2

    // MARK: - Touch Target
    static let minTouchTarget: CGFloat = 44

    // MARK: - Card
    static let cardPadding: CGFloat = md
    static let cardCornerRadius: CGFloat = radiusLarge

    // MARK: - Button
    static let buttonHeight: CGFloat = 56
    static let buttonCornerRadius: CGFloat = radiusMedium
    static let buttonPadding: EdgeInsets = EdgeInsets(top: md, leading: lg, bottom: md, trailing: lg)

    // MARK: - Input Field
    static let inputHeight: CGFloat = 48
    static let inputCornerRadius: CGFloat = radiusMedium
    static let inputPadding: CGFloat = md
}

// MARK: - View Extensions for Spacing
extension View {
    func cardStyle() -> some View {
        self
            .padding(AppSpacing.cardPadding)
            .background(Color.backgroundCard)
            .cornerRadius(AppSpacing.cardCornerRadius)
            .shadow(color: .shadowCard, radius: AppSpacing.shadowRadius, x: AppSpacing.shadowX, y: AppSpacing.shadowY)
    }

    func primaryButtonStyle() -> some View {
        self
            .frame(height: AppSpacing.buttonHeight)
            .frame(maxWidth: .infinity)
            .background(Color.accent1)
            .foregroundColor(.textPrimary)
            .cornerRadius(AppSpacing.buttonCornerRadius)
            .shadow(color: .shadowPrimary, radius: AppSpacing.shadowRadius, x: AppSpacing.shadowX, y: AppSpacing.shadowY)
    }

    func secondaryButtonStyle() -> some View {
        self
            .frame(height: AppSpacing.buttonHeight)
            .frame(maxWidth: .infinity)
            .background(Color.backgroundCard)
            .foregroundColor(.textPrimary)
            .cornerRadius(AppSpacing.buttonCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius)
                    .stroke(Color.borderPrimary, lineWidth: AppSpacing.borderWidth)
            )
    }

    func inputFieldStyle() -> some View {
        self
            .frame(height: AppSpacing.inputHeight)
            .padding(.horizontal, AppSpacing.inputPadding)
            .background(Color.backgroundInput)
            .cornerRadius(AppSpacing.inputCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.inputCornerRadius)
                    .stroke(Color.borderPrimary, lineWidth: AppSpacing.borderWidth)
            )
    }
}

// MARK: - Button Styles
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
