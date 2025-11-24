import Foundation

struct AppState: Codable {
    var hasSeenOnboarding: Bool
    var totalItemsCreated: Int
    var firstItemDate: Date?
    var lastBackupDate: Date?
    var appVersion: String

    init(
        hasSeenOnboarding: Bool = false,
        totalItemsCreated: Int = 0,
        firstItemDate: Date? = nil,
        lastBackupDate: Date? = nil,
        appVersion: String = "1.0.0"
    ) {
        self.hasSeenOnboarding = hasSeenOnboarding
        self.totalItemsCreated = totalItemsCreated
        self.firstItemDate = firstItemDate
        self.lastBackupDate = lastBackupDate
        self.appVersion = appVersion
    }
}

struct AppSettings: Codable {
    var defaultViewMode: ViewMode
    var itemsPerPage: Int
    var showPhotosInList: Bool
    var defaultSortOption: SortOption
    var photoQuality: PhotoQuality
    var maxPhotosPerItem: Int
    var autoCompressPhotos: Bool
    var searchHistoryEnabled: Bool
    var autoSearchEnabled: Bool
    var caseSensitiveSearch: Bool
    var hapticsEnabled: Bool
    var notificationsEnabled: Bool
    var notificationTime: Date

    init(
        defaultViewMode: ViewMode = .grid,
        itemsPerPage: Int = 20,
        showPhotosInList: Bool = true,
        defaultSortOption: SortOption = .dateNewest,
        photoQuality: PhotoQuality = .medium,
        maxPhotosPerItem: Int = 5,
        autoCompressPhotos: Bool = true,
        searchHistoryEnabled: Bool = true,
        autoSearchEnabled: Bool = true,
        caseSensitiveSearch: Bool = false,
        hapticsEnabled: Bool = true,
        notificationsEnabled: Bool = false,
        notificationTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    ) {
        self.defaultViewMode = defaultViewMode
        self.itemsPerPage = itemsPerPage
        self.showPhotosInList = showPhotosInList
        self.defaultSortOption = defaultSortOption
        self.photoQuality = photoQuality
        self.maxPhotosPerItem = maxPhotosPerItem
        self.autoCompressPhotos = autoCompressPhotos
        self.searchHistoryEnabled = searchHistoryEnabled
        self.autoSearchEnabled = autoSearchEnabled
        self.caseSensitiveSearch = caseSensitiveSearch
        self.hapticsEnabled = hapticsEnabled
        self.notificationsEnabled = notificationsEnabled
        self.notificationTime = notificationTime
    }
}

enum ViewMode: String, Codable, CaseIterable {
    case list
    case grid

    var displayName: String {
        switch self {
        case .list: return "List"
        case .grid: return "Grid"
        }
    }
}

enum SortOption: String, Codable, CaseIterable {
    case nameAscending
    case dateNewest
    case dateOldest
    case category
    case location

    var displayName: String {
        switch self {
        case .nameAscending: return "Name (A-Z)"
        case .dateNewest: return "Newest First"
        case .dateOldest: return "Oldest First"
        case .category: return "By Category"
        case .location: return "By Location"
        }
    }
}

enum PhotoQuality: String, Codable, CaseIterable {
    case low
    case medium
    case high

    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }

    var compressionQuality: CGFloat {
        switch self {
        case .low: return 0.3
        case .medium: return 0.6
        case .high: return 0.8
        }
    }
}
