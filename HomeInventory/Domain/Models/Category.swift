import Foundation
import SwiftUI

struct Category: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var iconName: String
    var colorHex: String
    var itemCount: Int
    var lastUsed: Date?
    var isDefault: Bool

    init(
        id: UUID = UUID(),
        name: String,
        iconName: String,
        colorHex: String,
        itemCount: Int = 0,
        lastUsed: Date? = nil,
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.itemCount = itemCount
        self.lastUsed = lastUsed
        self.isDefault = isDefault
    }

    var color: Color {
        Color(hex: colorHex) ?? .accent2
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }
}

extension Category {
    static let defaultCategories: [Category] = [
        Category(
            name: "Electronics",
            iconName: "laptopcomputer",
            colorHex: "#6A1B9A",
            isDefault: true
        ),
        Category(
            name: "Furniture",
            iconName: "bed.double.fill",
            colorHex: "#43A047",
            isDefault: true
        ),
        Category(
            name: "Clothing",
            iconName: "tshirt.fill",
            colorHex: "#FF5722",
            isDefault: true
        ),
        Category(
            name: "Books",
            iconName: "book.fill",
            colorHex: "#9C27B0",
            isDefault: true
        ),
        Category(
            name: "Kitchen",
            iconName: "fork.knife",
            colorHex: "#607D8B",
            isDefault: true
        ),
        Category(
            name: "Tools",
            iconName: "hammer.fill",
            colorHex: "#E91E63",
            isDefault: true
        ),
        Category(
            name: "Other",
            iconName: "square.grid.2x2.fill",
            colorHex: "#607D8B",
            isDefault: true
        )
    ]

    static var preview: Category {
        defaultCategories[0]
    }
}
