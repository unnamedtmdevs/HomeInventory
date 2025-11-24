import SwiftUI

struct CategoryCard: View {
    let category: Category
    let itemCount: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(category.color.opacity(0.15))
                        .frame(width: 60, height: 60)

                    Image(systemName: category.iconName)
                        .font(.system(size: 28))
                        .foregroundColor(category.color)
                }

                VStack(spacing: 4) {
                    Text(category.name)
                        .font(.appHeadline)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)

                    Text("\(itemCount) items")
                        .font(.appCaption)
                        .foregroundColor(.textTertiary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.md)
            .background(Color.backgroundCard)
            .cornerRadius(AppSpacing.radiusLarge)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                    .stroke(category.color.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: .shadowCard, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
