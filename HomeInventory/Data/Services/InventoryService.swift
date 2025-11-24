import Foundation

final class InventoryService {
    static let shared = InventoryService()

    private let storage = StorageService.shared
    private var items: [InventoryItem] = []

    private init() {
        loadItems()
    }

    // MARK: - Load Items
    func loadItems() {
        items = storage.loadItems()
    }

    // MARK: - Get Items
    func getAllItems() -> [InventoryItem] {
        loadItems() // Reload from storage to ensure data is up-to-date
        return items
    }

    func getItem(by id: UUID) -> InventoryItem? {
        return items.first { $0.id == id }
    }

    func getItems(for categoryID: UUID) -> [InventoryItem] {
        return items.filter { $0.categoryID == categoryID }
    }

    func getImportantItems() -> [InventoryItem] {
        return items.filter { $0.isImportant }
    }

    func getItemsWithPhotos() -> [InventoryItem] {
        return items.filter { !$0.photoIDs.isEmpty }
    }

    func getItemsWithoutPhotos() -> [InventoryItem] {
        return items.filter { $0.photoIDs.isEmpty }
    }

    func getRecentItems(limit: Int = 5) -> [InventoryItem] {
        return Array(items.sorted { $0.dateAdded > $1.dateAdded }.prefix(limit))
    }

    // MARK: - Create Item
    func createItem(_ item: InventoryItem) {
        items.append(item)
        storage.saveItems(items)
        LocationService.shared.refreshItemCounts()
    }

    // MARK: - Update Item
    func updateItem(_ item: InventoryItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            var updatedItem = item
            updatedItem.lastModified = Date()
            items[index] = updatedItem
            storage.saveItems(items)
            LocationService.shared.refreshItemCounts()
        }
    }

    // MARK: - Delete Item
    func deleteItem(_ item: InventoryItem) {
        items.removeAll { $0.id == item.id }
        storage.deletePhotos(item.photoIDs)
        storage.saveItems(items)
        LocationService.shared.refreshItemCounts()
    }

    func deleteItems(_ itemsToDelete: [InventoryItem]) {
        let idsToDelete = Set(itemsToDelete.map { $0.id })
        items.removeAll { idsToDelete.contains($0.id) }
        itemsToDelete.forEach { storage.deletePhotos($0.photoIDs) }
        storage.saveItems(items)
        LocationService.shared.refreshItemCounts()
    }

    // MARK: - Filter Items
    func filterItems(
        items: [InventoryItem],
        categories: Set<UUID>? = nil,
        location: String? = nil,
        importantOnly: Bool = false,
        withPhotosOnly: Bool = false,
        withoutPhotosOnly: Bool = false
    ) -> [InventoryItem] {
        var filtered = items

        if let categories = categories, !categories.isEmpty {
            filtered = filtered.filter { categories.contains($0.categoryID) }
        }

        if let location = location, !location.isEmpty {
            filtered = filtered.filter { $0.location.localizedCaseInsensitiveContains(location) }
        }

        if importantOnly {
            filtered = filtered.filter { $0.isImportant }
        }

        if withPhotosOnly {
            filtered = filtered.filter { !$0.photoIDs.isEmpty }
        }

        if withoutPhotosOnly {
            filtered = filtered.filter { $0.photoIDs.isEmpty }
        }

        return filtered
    }

    // MARK: - Sort Items
    func sortItems(_ items: [InventoryItem], by sortOption: SortOption, categories: [Category] = []) -> [InventoryItem] {
        switch sortOption {
        case .nameAscending:
            return items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .dateNewest:
            return items.sorted { $0.dateAdded > $1.dateAdded }
        case .dateOldest:
            return items.sorted { $0.dateAdded < $1.dateAdded }
        case .category:
            return items.sorted { item1, item2 in
                let cat1 = categories.first { $0.id == item1.categoryID }?.name ?? ""
                let cat2 = categories.first { $0.id == item2.categoryID }?.name ?? ""
                return cat1.localizedCaseInsensitiveCompare(cat2) == .orderedAscending
            }
        case .location:
            return items.sorted { $0.location.localizedCaseInsensitiveCompare($1.location) == .orderedAscending }
        }
    }

    // MARK: - Update Category for Items
    func updateCategoryForItems(_ itemIDs: [UUID], to categoryID: UUID) {
        for id in itemIDs {
            if let index = items.firstIndex(where: { $0.id == id }) {
                items[index].categoryID = categoryID
                items[index].lastModified = Date()
            }
        }
        storage.saveItems(items)
    }

    // MARK: - Statistics
    func getTotalItemsCount() -> Int {
        return items.count
    }

    func getItemsCount(for categoryID: UUID) -> Int {
        return items.filter { $0.categoryID == categoryID }.count
    }

    func getItemsWithPhotosCount() -> Int {
        return items.filter { !$0.photoIDs.isEmpty }.count
    }

    func getUniqueLocations() -> [String] {
        let locations = items.map { $0.location }.filter { !$0.isEmpty }
        return Array(Set(locations)).sorted()
    }

    func getMostCommonCategory(categories: [Category]) -> Category? {
        let categoryCounts = Dictionary(grouping: items, by: { $0.categoryID })
            .mapValues { $0.count }
        guard let mostCommonID = categoryCounts.max(by: { $0.value < $1.value })?.key else {
            return nil
        }
        return categories.first { $0.id == mostCommonID }
    }
}
