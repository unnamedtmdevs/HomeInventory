import Foundation
import UIKit

final class StorageService {
    static let shared = StorageService()

    private init() {}

    private enum Keys {
        static let items = "inventory_items"
        static let categories = "inventory_categories"
        static let locations = "inventory_locations"
        static let appState = "app_state"
        static let appSettings = "app_settings"
        static let searchHistory = "search_history"
        static let photosDirectory = "InventoryPhotos"
    }

    // MARK: - Items
    func saveItems(_ items: [InventoryItem]) {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: Keys.items)
        }
    }

    func loadItems() -> [InventoryItem] {
        guard let data = UserDefaults.standard.data(forKey: Keys.items),
              let items = try? JSONDecoder().decode([InventoryItem].self, from: data) else {
            return []
        }
        return items
    }

    // MARK: - Categories
    func saveCategories(_ categories: [Category]) {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: Keys.categories)
        }
    }

    func loadCategories() -> [Category] {
        guard let data = UserDefaults.standard.data(forKey: Keys.categories),
              let categories = try? JSONDecoder().decode([Category].self, from: data) else {
            return Category.defaultCategories
        }
        return categories
    }
    
    // MARK: - Locations
    func saveLocations(_ locations: [Location]) {
        if let encoded = try? JSONEncoder().encode(locations) {
            UserDefaults.standard.set(encoded, forKey: Keys.locations)
        }
    }

    func loadLocations() -> [Location] {
        guard let data = UserDefaults.standard.data(forKey: Keys.locations),
              let locations = try? JSONDecoder().decode([Location].self, from: data) else {
            return []
        }
        return locations
    }

    // MARK: - App State
    func saveAppState(_ state: AppState) {
        if let encoded = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(encoded, forKey: Keys.appState)
        }
    }

    func loadAppState() -> AppState {
        guard let data = UserDefaults.standard.data(forKey: Keys.appState),
              let state = try? JSONDecoder().decode(AppState.self, from: data) else {
            return AppState()
        }
        return state
    }

    // MARK: - App Settings
    func saveAppSettings(_ settings: AppSettings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: Keys.appSettings)
        }
    }

    func loadAppSettings() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: Keys.appSettings),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return AppSettings()
        }
        return settings
    }

    // MARK: - Search History
    func saveSearchHistory(_ history: [String]) {
        UserDefaults.standard.set(history, forKey: Keys.searchHistory)
    }

    func loadSearchHistory() -> [String] {
        UserDefaults.standard.stringArray(forKey: Keys.searchHistory) ?? []
    }

    func addToSearchHistory(_ query: String) {
        var history = loadSearchHistory()
        history.removeAll { $0 == query }
        history.insert(query, at: 0)
        if history.count > 20 {
            history = Array(history.prefix(20))
        }
        saveSearchHistory(history)
    }

    func clearSearchHistory() {
        UserDefaults.standard.removeObject(forKey: Keys.searchHistory)
    }

    // MARK: - Photos Directory
    private func getPhotosDirectory() -> URL? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let photosDirectory = documentDirectory.appendingPathComponent(Keys.photosDirectory)
        if !FileManager.default.fileExists(atPath: photosDirectory.path) {
            try? FileManager.default.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
        }
        return photosDirectory
    }

    // MARK: - Photo Storage
    func savePhoto(_ image: UIImage, quality: CGFloat = 0.6) -> String? {
        guard let photosDirectory = getPhotosDirectory(),
              let imageData = image.jpegData(compressionQuality: quality) else {
            return nil
        }

        let photoID = UUID().uuidString
        let photoURL = photosDirectory.appendingPathComponent("\(photoID).jpg")

        do {
            try imageData.write(to: photoURL)
            return photoID
        } catch {
            return nil
        }
    }

    func loadPhoto(_ photoID: String) -> UIImage? {
        guard let photosDirectory = getPhotosDirectory() else {
            return nil
        }
        let photoURL = photosDirectory.appendingPathComponent("\(photoID).jpg")
        guard let imageData = try? Data(contentsOf: photoURL) else {
            return nil
        }
        return UIImage(data: imageData)
    }

    func deletePhoto(_ photoID: String) {
        guard let photosDirectory = getPhotosDirectory() else {
            return
        }
        let photoURL = photosDirectory.appendingPathComponent("\(photoID).jpg")
        try? FileManager.default.removeItem(at: photoURL)
    }

    func deletePhotos(_ photoIDs: [String]) {
        photoIDs.forEach { deletePhoto($0) }
    }

    // MARK: - Clear All Data
    func clearAllData() {
        UserDefaults.standard.removeObject(forKey: Keys.items)
        UserDefaults.standard.removeObject(forKey: Keys.categories)
        UserDefaults.standard.removeObject(forKey: Keys.locations)
        UserDefaults.standard.removeObject(forKey: Keys.searchHistory)

        if let photosDirectory = getPhotosDirectory() {
            try? FileManager.default.removeItem(at: photosDirectory)
        }
    }

    // MARK: - Export Data
    func exportToCSV(items: [InventoryItem], categories: [Category]) -> String {
        var csv = "Name,Description,Category,Location,Important,Purchase Date,Purchase Price,Serial Number,Warranty,Notes,Date Added\n"

        for item in items {
            let category = categories.first { $0.id == item.categoryID }?.name ?? "Unknown"
            let important = item.isImportant ? "Yes" : "No"
            let purchaseDate = item.purchaseDate?.formatted(date: .abbreviated, time: .omitted) ?? ""
            let price = item.purchasePrice.map { String(format: "%.2f", $0) } ?? ""
            let dateAdded = item.dateAdded.formatted(date: .abbreviated, time: .omitted)

            let row = "\"\(item.name)\",\"\(item.itemDescription)\",\"\(category)\",\"\(item.location)\",\"\(important)\",\"\(purchaseDate)\",\"\(price)\",\"\(item.serialNumber)\",\"\(item.warrantyInfo)\",\"\(item.notes)\",\"\(dateAdded)\"\n"
            csv += row
        }

        return csv
    }
}
