import SwiftUI

@MainActor
final class ItemsViewModel: ObservableObject {
    @Published var items: [InventoryItem] = []
    @Published var filteredItems: [InventoryItem] = []
    @Published var categories: [Category] = []
    @Published var searchText: String = ""
    @Published var selectedCategories: Set<UUID> = []
    @Published var viewMode: ViewMode = .grid
    @Published var sortOption: SortOption = .dateNewest
    @Published var showFilterSheet = false
    @Published var showSortSheet = false
    @Published var importantOnly = false
    @Published var withPhotosOnly = false
    @Published var withoutPhotosOnly = false
    @Published var selectedLocation: String = ""
    @Published var deletingItemID: UUID?

    private let inventoryService = InventoryService.shared
    private let categoryService = CategoryService.shared
    private let searchService = SearchService.shared
    var settings: AppSettings {
        StorageService.shared.loadAppSettings()
    }

    init() {
        let initialSettings = StorageService.shared.loadAppSettings()
        viewMode = initialSettings.defaultViewMode
        sortOption = initialSettings.defaultSortOption
    }

    func loadData() {
        items = inventoryService.getAllItems()
        categories = categoryService.getAllCategories()
        // Reload settings to get latest values
        let latestSettings = StorageService.shared.loadAppSettings()
        viewMode = latestSettings.defaultViewMode
        sortOption = latestSettings.defaultSortOption
        applyFiltersAndSort()
    }

    func applyFiltersAndSort() {
        var result = items

        if !searchText.isEmpty {
            result = searchService.search(
                query: searchText,
                items: result,
                categories: categories,
                caseSensitive: settings.caseSensitiveSearch
            )
        }

        result = inventoryService.filterItems(
            items: result,
            categories: selectedCategories.isEmpty ? nil : selectedCategories,
            location: selectedLocation.isEmpty ? nil : selectedLocation,
            importantOnly: importantOnly,
            withPhotosOnly: withPhotosOnly,
            withoutPhotosOnly: withoutPhotosOnly
        )

        result = inventoryService.sortItems(result, by: sortOption, categories: categories)

        filteredItems = result
    }

    func getCategory(for item: InventoryItem) -> Category? {
        return categories.first { $0.id == item.categoryID }
    }

    func deleteItem(_ item: InventoryItem) {
        // Start deletion animation
        deletingItemID = item.id
        
        // Animate removal with delay
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            // Wait for animation to complete
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self = self else { return }
            self.inventoryService.deleteItem(item)
            self.deletingItemID = nil
            self.loadData()
            HapticsService.shared.success()
        }
    }

    func clearFilters() {
        searchText = ""
        selectedCategories.removeAll()
        selectedLocation = ""
        importantOnly = false
        withPhotosOnly = false
        withoutPhotosOnly = false
        applyFiltersAndSort()
    }

    func getUniqueLocations() -> [String] {
        return inventoryService.getUniqueLocations()
    }
}
