import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: TabItem = .home

    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                contentView

                Spacer()

                CustomTabBar(selectedTab: $selectedTab)
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch selectedTab {
        case .home:
            HomeView(selectedTab: $selectedTab)
        case .items:
            ItemsView()
        case .categories:
            CategoriesView()
        case .locations:
            LocationsView()
        case .search:
            SearchView()
        }
    }
}
