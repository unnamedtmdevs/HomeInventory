import SwiftUI

// Helper modifier for scrollContentBackground compatibility
struct ScrollContentBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.scrollContentBackground(.hidden)
        } else {
            content.onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
        }
    }
}

struct CustomTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var isSecure: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(.appBody)
                .foregroundColor(.textSecondary)

            HStack(spacing: AppSpacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(.textTertiary)
                        .frame(width: 24)
                }

                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(.appBody)
                        .foregroundColor(.textPrimary)
                } else {
                    TextField(placeholder, text: $text)
                        .font(.appBody)
                        .foregroundColor(.textPrimary)
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .frame(height: AppSpacing.inputHeight)
            .background(Color.backgroundInput)
            .cornerRadius(AppSpacing.inputCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.inputCornerRadius)
                    .stroke(Color.borderPrimary, lineWidth: 1)
            )
        }
    }
}

struct CustomTextEditor: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var minHeight: CGFloat = 100

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(.appBody)
                .foregroundColor(.textSecondary)

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.appBody)
                        .foregroundColor(.textQuaternary)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.sm + 4)
                }

                TextEditor(text: $text)
                    .font(.appBody)
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.sm)
                    .modifier(ScrollContentBackgroundModifier())
            }
            .frame(minHeight: minHeight)
            .background(Color.backgroundInput)
            .cornerRadius(AppSpacing.inputCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.inputCornerRadius)
                    .stroke(Color.borderPrimary, lineWidth: 1)
            )
        }
    }
}
