import Foundation

final class SearchService {
    static let shared = SearchService()

    private let storage = StorageService.shared

    private init() {}

    // MARK: - Search Items
    func search(
        query: String,
        items: [InventoryItem],
        categories: [Category],
        caseSensitive: Bool = false
    ) -> [InventoryItem] {
        guard !query.isEmpty else { return items }

        let searchQuery = caseSensitive ? query : query.lowercased()

        return items.filter { item in
            let name = caseSensitive ? item.name : item.name.lowercased()
            let description = caseSensitive ? item.itemDescription : item.itemDescription.lowercased()
            let location = caseSensitive ? item.location : item.location.lowercased()
            let notes = caseSensitive ? item.notes : item.notes.lowercased()

            let category = categories.first { $0.id == item.categoryID }
            let categoryName = caseSensitive ? (category?.name ?? "") : (category?.name.lowercased() ?? "")

            return name.contains(searchQuery) ||
                   description.contains(searchQuery) ||
                   location.contains(searchQuery) ||
                   notes.contains(searchQuery) ||
                   categoryName.contains(searchQuery)
        }
    }

    // MARK: - Advanced Search
    func advancedSearch(
        query: String,
        items: [InventoryItem],
        categories: [Category],
        selectedCategories: Set<UUID>? = nil,
        location: String? = nil,
        importantOnly: Bool = false,
        withPhotosOnly: Bool = false,
        withoutPhotosOnly: Bool = false,
        dateRange: ClosedRange<Date>? = nil,
        priceRange: ClosedRange<Double>? = nil,
        caseSensitive: Bool = false
    ) -> [InventoryItem] {
        var results = items

        if !query.isEmpty {
            results = search(query: query, items: results, categories: categories, caseSensitive: caseSensitive)
        }

        if let selectedCategories = selectedCategories, !selectedCategories.isEmpty {
            results = results.filter { selectedCategories.contains($0.categoryID) }
        }

        if let location = location, !location.isEmpty {
            let searchLocation = caseSensitive ? location : location.lowercased()
            results = results.filter {
                let itemLocation = caseSensitive ? $0.location : $0.location.lowercased()
                return itemLocation.contains(searchLocation)
            }
        }

        if importantOnly {
            results = results.filter { $0.isImportant }
        }

        if withPhotosOnly {
            results = results.filter { !$0.photoIDs.isEmpty }
        }

        if withoutPhotosOnly {
            results = results.filter { $0.photoIDs.isEmpty }
        }

        if let dateRange = dateRange {
            results = results.filter { dateRange.contains($0.dateAdded) }
        }

        if let priceRange = priceRange {
            results = results.filter {
                guard let price = $0.purchasePrice else { return false }
                return priceRange.contains(price)
            }
        }

        return results
    }

    // MARK: - Sort by Relevance
    func sortByRelevance(query: String, items: [InventoryItem], categories: [Category]) -> [InventoryItem] {
        let searchQuery = query.lowercased()

        return items.sorted { item1, item2 in
            let score1 = calculateRelevanceScore(for: item1, query: searchQuery, categories: categories)
            let score2 = calculateRelevanceScore(for: item2, query: searchQuery, categories: categories)
            return score1 > score2
        }
    }

    private func calculateRelevanceScore(for item: InventoryItem, query: String, categories: [Category]) -> Int {
        var score = 0

        let name = item.name.lowercased()
        let description = item.itemDescription.lowercased()

        if name == query {
            score += 100
        } else if name.hasPrefix(query) {
            score += 50
        } else if name.contains(query) {
            score += 25
        }

        if description.contains(query) {
            score += 10
        }

        if item.location.lowercased().contains(query) {
            score += 5
        }

        if item.isImportant {
            score += 2
        }

        return score
    }

    // MARK: - Search History
    func addToHistory(_ query: String) {
        storage.addToSearchHistory(query)
    }

    func getSearchHistory() -> [String] {
        return storage.loadSearchHistory()
    }

    func clearSearchHistory() {
        storage.clearSearchHistory()
    }

    // MARK: - Get Locations
    func getUniqueLocations(from items: [InventoryItem]) -> [String] {
        let locations = items.map { $0.location }.filter { !$0.isEmpty }
        return Array(Set(locations)).sorted()
    }
}
