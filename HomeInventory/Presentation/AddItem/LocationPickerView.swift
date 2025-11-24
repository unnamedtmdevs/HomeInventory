import SwiftUI

struct LocationPickerView: View {
    let locations: [Location]
    @Binding var selectedLocationName: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom header
                ZStack(alignment: .topTrailing) {
                    ScreenHeader(
                        title: "Select Location",
                        subtitle: "Choose a location",
                        icon: "mappin.circle.fill",
                        accentColor: .accent4
                    )
                    .padding(.top, 50)
                    .padding(.bottom, AppSpacing.lg)
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.textTertiary)
                    }
                    .padding(.top, 50)
                    .padding(.trailing, AppSpacing.lg)
                }

                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: AppSpacing.md) {
                        // No Location option
                        LocationPickerCard(
                            iconName: "xmark.circle.fill",
                            name: "No Location",
                            color: .textTertiary,
                            isSelected: selectedLocationName.isEmpty
                        ) {
                            selectedLocationName = ""
                            HapticsService.shared.selection()
                            presentationMode.wrappedValue.dismiss()
                        }
                        
                        ForEach(locations) { location in
                            LocationPickerCard(
                                iconName: location.iconName,
                                name: location.name,
                                color: location.color,
                                isSelected: selectedLocationName == location.name
                            ) {
                                selectedLocationName = location.name
                                HapticsService.shared.selection()
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

struct LocationPickerCard: View {
    let iconName: String
    let name: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(color.opacity(isSelected ? 0.3 : 0.15))
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 32))
                        .foregroundColor(color)
                    
                    if isSelected {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        color.opacity(0.4),
                                        color.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                            .overlay(
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                            )
                    }
                }
                
                VStack(spacing: 4) {
                    Text(name)
                        .font(.appHeadline)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.md)
            .background(Color.backgroundCard)
            .cornerRadius(AppSpacing.radiusLarge)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                    .stroke(
                        isSelected ? color.opacity(0.6) : Color.borderPrimary,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? color.opacity(0.3) : .clear,
                radius: isSelected ? 8 : 0,
                x: 0,
                y: isSelected ? 4 : 0
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

