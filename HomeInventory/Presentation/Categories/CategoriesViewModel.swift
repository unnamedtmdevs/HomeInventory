import SwiftUI

@MainActor
final class CategoriesViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var showingAddCategory = false
    @Published var deletingCategoryID: UUID?

    private let categoryService = CategoryService.shared
    private let inventoryService = InventoryService.shared

    func loadCategories() {
        categoryService.refreshItemCounts()
        categories = categoryService.getAllCategories()
    }

    func getItemCount(for categoryID: UUID) -> Int {
        return inventoryService.getItemsCount(for: categoryID)
    }

    func canDeleteCategory(_ category: Category) -> Bool {
        let allCategories = categoryService.getAllCategories()
        return allCategories.count > 1
    }
    
    func deleteCategory(_ category: Category) {
        // Check if this is the last category
        guard canDeleteCategory(category) else {
            return
        }
        
        // Start deletion animation
        deletingCategoryID = category.id
        
        // Animate removal with delay
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            // Wait for animation to complete
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self = self else { return }
            
            let allCategories = self.categoryService.getAllCategories()
            
            // Try to find "Other" category first, otherwise use any other category
            if let otherCategory = self.categoryService.getOtherCategory(), otherCategory.id != category.id {
                self.categoryService.deleteCategory(category, moveItemsTo: otherCategory.id)
            } else if let firstOtherCategory = allCategories.first(where: { $0.id != category.id }) {
                self.categoryService.deleteCategory(category, moveItemsTo: firstOtherCategory.id)
            } else {
                // Fallback: delete without moving items (shouldn't happen)
                self.categoryService.deleteCategory(category, moveItemsTo: nil)
            }
            
            self.deletingCategoryID = nil
            self.loadCategories()
            HapticsService.shared.success()
        }
    }

    func getCategoryStatistics(for categoryID: UUID) -> CategoryStatistics {
        return categoryService.getCategoryStatistics(for: categoryID)
    }
}
