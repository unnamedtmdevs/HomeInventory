import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var selectedItem: InventoryItem?
    @State private var showingItemDetail = false
    @State private var showingFilters = false
    private let settings = StorageService.shared.loadAppSettings()

    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom header
                ScreenHeader(
                    title: "Search",
                    subtitle: "Find anything quickly",
                    icon: "magnifyingglass",
                    accentColor: .accent5
                )
                .padding(.top, 50)
                .padding(.bottom, AppSpacing.lg)

                searchBar

                if viewModel.searchText.isEmpty {
                    searchHistorySection
                } else if viewModel.searchResults.isEmpty {
                    emptyResults
                } else {
                    searchResultsSection
                }
            }
        }
        .onAppear {
            viewModel.loadData()
        }
        .sheet(item: $selectedItem) { item in
            ItemDetailView(item: item, onEdit: {}, onDelete: {
                viewModel.performSearch()
            })
        }
        .onChange(of: selectedItem) { item in
            if item == nil {
                viewModel.performSearch()
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    private var searchBar: some View {
        HStack(spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.accent5)

                TextField("Search items, categories, locations...", text: $viewModel.searchText)
                    .font(.appBody)
                    .foregroundColor(.textPrimary)
                    .onChange(of: viewModel.searchText) { _ in
                        if settings.autoSearchEnabled {
                            viewModel.performSearch()
                        }
                    }
                    .onSubmit {
                        viewModel.performSearch()
                    }

                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.clearSearch()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.textTertiary)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .frame(height: 50)
            .background(Color.backgroundInput)
            .cornerRadius(AppSpacing.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                    .stroke(Color.accent5.opacity(0.3), lineWidth: 2)
            )

            Button(action: {
                showingFilters = true
            }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 24))
                    .foregroundColor(.accent5)
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.md)
        .background(Color.backgroundPrimary)
        .sheet(isPresented: $showingFilters) {
            SearchFiltersView(viewModel: viewModel)
        }
        .onChange(of: showingFilters) { isShowing in
            if !isShowing {
                viewModel.performSearch()
            }
        }
    }

    private var searchHistorySection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                if !viewModel.searchHistory.isEmpty {
                    HStack {
                        Text("Recent Searches")
                            .font(.appTitle)
                            .foregroundColor(.textPrimary)

                        Spacer()

                        Button("Clear") {
                            viewModel.clearHistory()
                        }
                        .font(.appBody)
                        .foregroundColor(.error)
                    }

                    ForEach(viewModel.searchHistory, id: \.self) { query in
                        Button(action: {
                            viewModel.selectHistoryItem(query)
                        }) {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                    .foregroundColor(.textTertiary)

                                Text(query)
                                    .font(.appBody)
                                    .foregroundColor(.textPrimary)

                                Spacer()

                                Image(systemName: "arrow.up.left")
                                    .font(.system(size: 14))
                                    .foregroundColor(.textQuaternary)
                            }
                            .padding(AppSpacing.md)
                            .background(Color.backgroundCard)
                            .cornerRadius(AppSpacing.radiusMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                                    .stroke(Color.borderPrimary, lineWidth: 1)
                            )
                        }
                    }
                } else {
                    VStack(spacing: AppSpacing.md) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.accent5)

                        Text("Search your inventory")
                            .font(.appTitle)
                            .foregroundColor(.textPrimary)

                        Text("Find items by name, description, category, or location")
                            .font(.appBody)
                            .foregroundColor(.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, AppSpacing.xxl)
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.bottom, 100)
        }
    }

    private var searchResultsSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack {
                    Text("\(viewModel.searchResults.count) results")
                        .font(.appHeadline)
                        .foregroundColor(.textSecondary)

                    Spacer()
                }
                .padding(.horizontal, AppSpacing.md)

                LazyVStack(spacing: AppSpacing.md) {
                    ForEach(viewModel.searchResults) { item in
                        SearchResultRow(
                            item: item,
                            category: viewModel.getCategory(for: item),
                            searchQuery: viewModel.searchText
                        ) {
                            selectedItem = item
                            showingItemDetail = true
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, 100)
            }
        }
    }

    private var emptyResults: some View {
        VStack {
            Spacer()
            EmptyStateView(
                icon: "magnifyingglass",
                title: "No results found",
                message: "Try different keywords or check your filters"
            )
            .padding(.horizontal, AppSpacing.xl)
            Spacer()
        }
    }
}

struct SearchResultRow: View {
    let item: InventoryItem
    let category: Category?
    let searchQuery: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.md) {
                if let firstPhotoID = item.photoIDs.first,
                   let image = ImageService.shared.loadPhoto(firstPhotoID) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 70)
                        .clipped()
                        .cornerRadius(AppSpacing.radiusMedium)
                } else {
                    ZStack {
                        Color.backgroundSecondary
                        Image(systemName: "photo")
                            .foregroundColor(.textQuaternary)
                    }
                    .frame(width: 70, height: 70)
                    .cornerRadius(AppSpacing.radiusMedium)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.name)
                            .font(.appHeadline)
                            .foregroundColor(.textPrimary)
                            .lineLimit(1)

                        if item.isImportant {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.accent1)
                        }
                    }

                    if let category = category {
                        HStack(spacing: 4) {
                            Image(systemName: category.iconName)
                                .font(.system(size: 12))
                                .foregroundColor(category.color)
                            Text(category.name)
                                .font(.appCaption)
                                .foregroundColor(category.color)
                        }
                    }

                    if !item.itemDescription.isEmpty {
                        Text(item.itemDescription)
                            .font(.appCaption)
                            .foregroundColor(.textTertiary)
                            .lineLimit(2)
                    }

                    if !item.location.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 10))
                            Text(item.location)
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.textQuaternary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.textQuaternary)
            }
            .padding(AppSpacing.md)
            .background(Color.backgroundCard)
            .cornerRadius(AppSpacing.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                    .stroke(Color.accent5.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SearchFiltersView: View {
    @ObservedObject var viewModel: SearchViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom header
                ZStack(alignment: .topTrailing) {
                    ScreenHeader(
                        title: "Search Filters",
                        subtitle: "Refine your search",
                        icon: "slider.horizontal.3",
                        accentColor: .accent5
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
                    VStack(spacing: AppSpacing.lg) {
                        // Categories section
                        categoriesSection
                            .padding(.horizontal, AppSpacing.md)
                        
                        // Filters section
                        filtersSection
                            .padding(.horizontal, AppSpacing.md)
                        
                        // Action buttons
                        actionButtons
                            .padding(.horizontal, AppSpacing.md)
                    }
                    .padding(.bottom, 100)
                }
            }
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Categories")
                .font(.appTitle)
                .foregroundColor(.textPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppSpacing.md) {
                ForEach(viewModel.categories) { category in
                    Button(action: {
                        if viewModel.selectedCategories.contains(category.id) {
                            viewModel.selectedCategories.remove(category.id)
                        } else {
                            viewModel.selectedCategories.insert(category.id)
                        }
                        HapticsService.shared.selection()
                    }) {
                        FilterCategoryCard(
                            category: category,
                            isSelected: viewModel.selectedCategories.contains(category.id)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(AppSpacing.md)
        .background(Color.backgroundCard)
        .cornerRadius(AppSpacing.radiusLarge)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                .stroke(Color.borderPrimary, lineWidth: 1)
        )
    }
    
    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Filters")
                .font(.appTitle)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: AppSpacing.sm) {
                Toggle(isOn: $viewModel.importantOnly) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.accent1)
                            .font(.system(size: 18))
                        Text("Important Only")
                            .font(.appBody)
                            .foregroundColor(.textPrimary)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .accent1))
                .padding(AppSpacing.md)
                .background(Color.backgroundSecondary)
                .cornerRadius(AppSpacing.radiusMedium)
                
                Toggle(isOn: $viewModel.withPhotosOnly) {
                    HStack {
                        Image(systemName: "photo.fill")
                            .foregroundColor(.accent3)
                            .font(.system(size: 18))
                        Text("With Photos Only")
                            .font(.appBody)
                            .foregroundColor(.textPrimary)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .accent3))
                .padding(AppSpacing.md)
                .background(Color.backgroundSecondary)
                .cornerRadius(AppSpacing.radiusMedium)
                
                Toggle(isOn: $viewModel.withoutPhotosOnly) {
                    HStack {
                        Image(systemName: "photo")
                            .foregroundColor(.textTertiary)
                            .font(.system(size: 18))
                        Text("Without Photos Only")
                            .font(.appBody)
                            .foregroundColor(.textPrimary)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .accent5))
                .padding(AppSpacing.md)
                .background(Color.backgroundSecondary)
                .cornerRadius(AppSpacing.radiusMedium)
            }
        }
        .padding(AppSpacing.md)
        .background(Color.backgroundCard)
        .cornerRadius(AppSpacing.radiusLarge)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                .stroke(Color.borderPrimary, lineWidth: 1)
        )
    }
    
    private var actionButtons: some View {
        VStack(spacing: AppSpacing.sm) {
            CustomButton(
                title: "Apply Filters",
                icon: "checkmark.circle.fill",
                style: .primary
            ) {
                viewModel.performSearch()
                presentationMode.wrappedValue.dismiss()
            }
            
            CustomButton(
                title: "Clear All",
                icon: "xmark.circle.fill",
                style: .secondary
            ) {
                viewModel.selectedCategories.removeAll()
                viewModel.importantOnly = false
                viewModel.withPhotosOnly = false
                viewModel.withoutPhotosOnly = false
                HapticsService.shared.light()
            }
        }
    }
}

struct FilterCategoryCard: View {
    let category: Category
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            ZStack {
                Circle()
                    .fill(category.color.opacity(isSelected ? 0.3 : 0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: category.iconName)
                    .font(.system(size: 28))
                    .foregroundColor(category.color)
                
                if isSelected {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    category.color.opacity(0.4),
                                    category.color.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        )
                }
            }
            
            Text(category.name)
                .font(.appCaption)
                .foregroundColor(.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.sm)
        .background(Color.backgroundSecondary)
        .cornerRadius(AppSpacing.radiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                .stroke(
                    isSelected ? category.color.opacity(0.6) : Color.borderPrimary,
                    lineWidth: isSelected ? 2 : 1
                )
        )
        .shadow(
            color: isSelected ? category.color.opacity(0.3) : .clear,
            radius: isSelected ? 8 : 0,
            x: 0,
            y: isSelected ? 4 : 0
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
