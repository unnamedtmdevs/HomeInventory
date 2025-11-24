import Foundation

final class CategoryService {
    static let shared = CategoryService()

    private let storage = StorageService.shared
    private var categories: [Category] = []

    private init() {
        loadCategories()
    }

    // MARK: - Load Categories
    func loadCategories() {
        categories = storage.loadCategories()
        if categories.isEmpty {
            categories = Category.defaultCategories
            storage.saveCategories(categories)
        }
    }

    // MARK: - Get Categories
    func getAllCategories() -> [Category] {
        loadCategories() // Reload from storage to ensure data is up-to-date
        return categories
    }

    func getCategory(by id: UUID) -> Category? {
        return categories.first { $0.id == id }
    }

    func getDefaultCategories() -> [Category] {
        return categories.filter { $0.isDefault }
    }

    func getCustomCategories() -> [Category] {
        return categories.filter { !$0.isDefault }
    }

    // MARK: - Create Category
    func createCategory(_ category: Category) {
        categories.append(category)
        storage.saveCategories(categories)
    }

    // MARK: - Update Category
    func updateCategory(_ category: Category) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
            storage.saveCategories(categories)
        }
    }

    // MARK: - Delete Category
    func deleteCategory(_ category: Category, moveItemsTo defaultCategoryID: UUID? = nil) {
        categories.removeAll { $0.id == category.id }
        storage.saveCategories(categories)

        if let defaultCategoryID = defaultCategoryID {
            let inventoryService = InventoryService.shared
            let items = inventoryService.getItems(for: category.id)
            inventoryService.updateCategoryForItems(items.map { $0.id }, to: defaultCategoryID)
        }
    }

    // MARK: - Update Item Count
    func updateItemCount(for categoryID: UUID, count: Int) {
        if let index = categories.firstIndex(where: { $0.id == categoryID }) {
            categories[index].itemCount = count
            categories[index].lastUsed = Date()
            storage.saveCategories(categories)
        }
    }

    func refreshItemCounts() {
        let inventoryService = InventoryService.shared
        for index in categories.indices {
            let count = inventoryService.getItemsCount(for: categories[index].id)
            categories[index].itemCount = count
        }
        storage.saveCategories(categories)
    }

    // MARK: - Category Statistics
    func getCategoryStatistics(for categoryID: UUID) -> CategoryStatistics {
        let inventoryService = InventoryService.shared
        let items = inventoryService.getItems(for: categoryID)

        let totalItems = items.count
        let itemsWithPhotos = items.filter { !$0.photoIDs.isEmpty }.count
        let locations = Set(items.map { $0.location }.filter { !$0.isEmpty })
        let mostRecent = items.max { $0.dateAdded < $1.dateAdded }

        return CategoryStatistics(
            totalItems: totalItems,
            itemsWithPhotos: itemsWithPhotos,
            uniqueLocations: locations.count,
            mostRecentItem: mostRecent
        )
    }

    // MARK: - Get "Other" Category
    func getOtherCategory() -> Category? {
        return categories.first { $0.name == "Other" && $0.isDefault }
    }
}

struct CategoryStatistics {
    let totalItems: Int
    let itemsWithPhotos: Int
    let uniqueLocations: Int
    let mostRecentItem: InventoryItem?
}
