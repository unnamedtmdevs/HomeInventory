import SwiftUI

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [InventoryItem] = []
    @Published var categories: [Category] = []
    @Published var searchHistory: [String] = []
    @Published var selectedCategories: Set<UUID> = []
    @Published var sortOption: SortOption = .nameAscending
    @Published var importantOnly = false
    @Published var withPhotosOnly = false
    @Published var withoutPhotosOnly = false

    private let inventoryService = InventoryService.shared
    private let categoryService = CategoryService.shared
    private let searchService = SearchService.shared
    private let settings = StorageService.shared.loadAppSettings()

    func loadData() {
        categories = categoryService.getAllCategories()
        searchHistory = searchService.getSearchHistory()
    }

    func performSearch() {
        let allItems = inventoryService.getAllItems()

        let results = searchService.advancedSearch(
            query: searchText,
            items: allItems,
            categories: categories,
            selectedCategories: selectedCategories.isEmpty ? nil : selectedCategories,
            importantOnly: importantOnly,
            withPhotosOnly: withPhotosOnly,
            withoutPhotosOnly: withoutPhotosOnly,
            caseSensitive: settings.caseSensitiveSearch
        )

        if !searchText.isEmpty {
            searchResults = searchService.sortByRelevance(query: searchText, items: results, categories: categories)
            if settings.searchHistoryEnabled {
                searchService.addToHistory(searchText)
                searchHistory = searchService.getSearchHistory()
            }
        } else {
            searchResults = inventoryService.sortItems(results, by: sortOption, categories: categories)
        }
    }

    func clearSearch() {
        searchText = ""
        searchResults.removeAll()
        selectedCategories.removeAll()
        importantOnly = false
        withPhotosOnly = false
        withoutPhotosOnly = false
    }

    func selectHistoryItem(_ query: String) {
        searchText = query
        performSearch()
    }

    func clearHistory() {
        searchService.clearSearchHistory()
        searchHistory.removeAll()
        HapticsService.shared.success()
    }

    func getCategory(for item: InventoryItem) -> Category? {
        return categories.first { $0.id == item.categoryID }
    }
}
