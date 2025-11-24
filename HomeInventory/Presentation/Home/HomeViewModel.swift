import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var items: [InventoryItem] = []
    @Published var categories: [Category] = []
    @Published var recentItems: [InventoryItem] = []
    @Published var totalItems: Int = 0
    @Published var itemsWithPhotos: Int = 0
    @Published var totalCategories: Int = 0
    @Published var mostCommonCategory: Category?

    private let inventoryService = InventoryService.shared
    private let categoryService = CategoryService.shared

    func loadData() {
        items = inventoryService.getAllItems()
        categories = categoryService.getAllCategories()
        recentItems = inventoryService.getRecentItems(limit: 5)

        calculateStatistics()
    }

    private func calculateStatistics() {
        totalItems = inventoryService.getTotalItemsCount()
        itemsWithPhotos = inventoryService.getItemsWithPhotosCount()
        totalCategories = categories.count
        mostCommonCategory = inventoryService.getMostCommonCategory(categories: categories)
    }

    func getItemCount(for categoryID: UUID) -> Int {
        return inventoryService.getItemsCount(for: categoryID)
    }

    func getCategory(for item: InventoryItem) -> Category? {
        return categories.first { $0.id == item.categoryID }
    }
}
