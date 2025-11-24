import Foundation
import SwiftUI

struct Location: Identifiable, Codable, Hashable {
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

    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
}

extension Location {
    static let defaultLocations: [Location] = [
        Location(
            name: "Living Room",
            iconName: "sofa.fill",
            colorHex: "#43A047",
            isDefault: true
        ),
        Location(
            name: "Bedroom",
            iconName: "bed.double.fill",
            colorHex: "#6A1B9A",
            isDefault: true
        ),
        Location(
            name: "Kitchen",
            iconName: "fork.knife",
            colorHex: "#FF5722",
            isDefault: true
        ),
        Location(
            name: "Bathroom",
            iconName: "shower.fill",
            colorHex: "#2196F3",
            isDefault: true
        ),
        Location(
            name: "Garage",
            iconName: "car.fill",
            colorHex: "#607D8B",
            isDefault: true
        ),
        Location(
            name: "Storage",
            iconName: "archivebox.fill",
            colorHex: "#9C27B0",
            isDefault: true
        )
    ]
}

