import SwiftUI

enum TabItem: String, CaseIterable {
    case home
    case items
    case categories
    case locations
    case search

    var title: String {
        switch self {
        case .home: return "Home"
        case .items: return "Items"
        case .categories: return "Categories"
        case .locations: return "Locations"
        case .search: return "Search"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .items: return "square.grid.2x2.fill"
        case .categories: return "folder.fill"
        case .locations: return "mappin.circle.fill"
        case .search: return "magnifyingglass"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    animation: animation
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                        HapticsService.shared.light()
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.backgroundCard.opacity(0.95))
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -5)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.borderPrimary.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

struct TabBarButton: View {
    let tab: TabItem
    let isSelected: Bool
    let animation: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticsService.shared.selection()
            action()
        }) {
            VStack(spacing: 6) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.accent1,
                                        Color.accent4.opacity(0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 44)
                            .shadow(color: Color.accent1.opacity(0.6), radius: 12, x: 0, y: 4)
                            .matchedGeometryEffect(id: "tab_background", in: animation)
                    }
                    
                    Image(systemName: tab.icon)
                        .font(.system(size: 22, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? .white : .textSecondary)
                        .frame(width: 60, height: 44)
                }
                
                Text(tab.title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular, design: .rounded))
                    .foregroundColor(isSelected ? .accent1 : .textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
