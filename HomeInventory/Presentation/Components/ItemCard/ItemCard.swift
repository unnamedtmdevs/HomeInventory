import SwiftUI

struct ItemCard: View {
    let item: InventoryItem
    let category: Category?
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var showingDeleteAlert = false

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                if let firstPhotoID = item.photoIDs.first,
                   let image = ImageService.shared.loadPhoto(firstPhotoID) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 140)
                        .clipped()
                        .cornerRadius(AppSpacing.radiusMedium)
                } else {
                    placeholderImage
                }

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack {
                        Text(item.name)
                            .font(.appHeadline)
                            .foregroundColor(.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Spacer()

                        if item.isImportant {
                            Image(systemName: "star.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.accent1)
                        }
                    }

                    if let category = category {
                        CategoryBadge(category: category)
                    }

                    if !item.location.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.textTertiary)

                            Text(item.location)
                                .font(.appCaption)
                                .foregroundColor(.textTertiary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                    }

                    Text(item.dateAdded.formatted(date: .abbreviated, time: .omitted))
                        .font(.appCaption)
                        .foregroundColor(.textQuaternary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.md)
            .background(Color.backgroundCard)
            .cornerRadius(AppSpacing.radiusLarge)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                    .stroke(
                        item.colorHex.isEmpty ? Color.borderPrimary : item.color.opacity(0.6),
                        lineWidth: item.colorHex.isEmpty ? 1 : 2
                    )
            )
            .shadow(
                color: item.colorHex.isEmpty ? .clear : item.color.opacity(0.2),
                radius: item.colorHex.isEmpty ? 0 : 8,
                x: 0,
                y: item.colorHex.isEmpty ? 0 : 4
            )
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }

            Button(role: .destructive, action: { showingDeleteAlert = true }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Delete Item", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive, action: onDelete)
        } message: {
            Text("Are you sure you want to delete \"\(item.name)\"?")
        }
    }

    private var placeholderImage: some View {
        ZStack {
            Color.backgroundSecondary

            Image(systemName: "photo")
                .font(.system(size: 48))
                .foregroundColor(.textQuaternary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .cornerRadius(AppSpacing.radiusMedium)
    }
}

struct CategoryBadge: View {
    let category: Category

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: category.iconName)
                .font(.system(size: 12))

            Text(category.name)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(category.color)
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, 4)
        .background(category.color.opacity(0.15))
        .cornerRadius(AppSpacing.radiusSmall)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.radiusSmall)
                .stroke(category.color.opacity(0.3), lineWidth: 1)
        )
    }
}
