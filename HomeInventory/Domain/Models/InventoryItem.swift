import Foundation
import SwiftUI

struct InventoryItem: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var itemDescription: String
    var categoryID: UUID
    var location: String
    var isImportant: Bool
    var photoIDs: [String]
    var purchaseDate: Date?
    var purchasePrice: Double?
    var serialNumber: String
    var warrantyInfo: String
    var notes: String
    var colorHex: String
    var dateAdded: Date
    var lastModified: Date

    init(
        id: UUID = UUID(),
        name: String,
        itemDescription: String = "",
        categoryID: UUID,
        location: String = "",
        isImportant: Bool = false,
        photoIDs: [String] = [],
        purchaseDate: Date? = nil,
        purchasePrice: Double? = nil,
        serialNumber: String = "",
        warrantyInfo: String = "",
        notes: String = "",
        colorHex: String = "",
        dateAdded: Date = Date(),
        lastModified: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.itemDescription = itemDescription
        self.categoryID = categoryID
        self.location = location
        self.isImportant = isImportant
        self.photoIDs = photoIDs
        self.purchaseDate = purchaseDate
        self.purchasePrice = purchasePrice
        self.serialNumber = serialNumber
        self.warrantyInfo = warrantyInfo
        self.notes = notes
        self.colorHex = colorHex
        self.dateAdded = dateAdded
        self.lastModified = lastModified
    }
    
    var color: Color {
        if colorHex.isEmpty {
            return .accent2
        }
        return Color(hex: colorHex) ?? .accent2
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: InventoryItem, rhs: InventoryItem) -> Bool {
        lhs.id == rhs.id
    }
}

extension InventoryItem {
    static var preview: InventoryItem {
        InventoryItem(
            name: "Laptop",
            itemDescription: "MacBook Pro 16-inch",
            categoryID: Category.defaultCategories[0].id,
            location: "Home Office",
            isImportant: true,
            purchaseDate: Date(),
            purchasePrice: 2499.99,
            notes: "Work computer"
        )
    }
}
