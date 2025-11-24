import SwiftUI

struct CustomButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyleType
    let action: () -> Void

    init(
        title: String,
        icon: String? = nil,
        style: ButtonStyleType = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticsService.shared.medium()
            action()
        }) {
            HStack(spacing: AppSpacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                }

                Text(title)
                    .font(.system(size: 18, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: AppSpacing.buttonHeight)
            .background(style.backgroundColor)
            .foregroundColor(style.foregroundColor)
            .cornerRadius(AppSpacing.buttonCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius)
                    .stroke(style.borderColor, lineWidth: style.borderWidth)
            )
            .shadow(color: style.shadowColor, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

enum ButtonStyleType {
    case primary
    case secondary
    case destructive

    var backgroundColor: Color {
        switch self {
        case .primary: return .accent1
        case .secondary: return .backgroundCard
        case .destructive: return .error
        }
    }

    var foregroundColor: Color {
        switch self {
        case .primary, .destructive: return .textPrimary
        case .secondary: return .textPrimary
        }
    }

    var borderColor: Color {
        switch self {
        case .primary, .destructive: return .clear
        case .secondary: return .borderPrimary
        }
    }

    var borderWidth: CGFloat {
        switch self {
        case .primary, .destructive: return 0
        case .secondary: return 1
        }
    }

    var shadowColor: Color {
        switch self {
        case .primary, .destructive: return .shadowPrimary
        case .secondary: return .clear
        }
    }
}
