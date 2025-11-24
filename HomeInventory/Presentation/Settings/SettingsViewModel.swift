import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings
    @Published var showingClearDataAlert = false
    @Published var showingExportSuccess = false
    @Published var showingClearDataSuccess = false
    @Published var showingNotificationPermissionAlert = false
    @Published var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined

    private let storage = StorageService.shared
    private let inventoryService = InventoryService.shared
    private let categoryService = CategoryService.shared
    private let notificationService = NotificationService.shared

    init() {
        settings = storage.loadAppSettings()
        checkNotificationPermission()
    }
    
    func checkNotificationPermission() {
        notificationService.checkAuthorizationStatus { [weak self] status in
            self?.notificationPermissionStatus = status
        }
    }

    func saveSettings() {
        storage.saveAppSettings(settings)
        
        // Update notifications if enabled
        if settings.notificationsEnabled {
            notificationService.scheduleDailyNotification(at: settings.notificationTime)
        } else {
            notificationService.cancelAllNotifications()
        }
        
        HapticsService.shared.success()
    }

    func getTotalItems() -> Int {
        return inventoryService.getTotalItemsCount()
    }

    func getTotalCategories() -> Int {
        return categoryService.getAllCategories().count
    }

    func getItemsWithPhotos() -> Int {
        return inventoryService.getItemsWithPhotosCount()
    }

    func getStorageUsed() -> String {
        return "N/A"
    }

    func exportData() -> String {
        let items = inventoryService.getAllItems()
        let categories = categoryService.getAllCategories()
        return storage.exportToCSV(items: items, categories: categories)
    }

    func clearAllData() {
        storage.clearAllData()
        inventoryService.loadItems()
        categoryService.loadCategories()
        HapticsService.shared.success()
        showingClearDataSuccess = true
    }

    func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    func requestNotificationPermission() {
        notificationService.requestAuthorization { [weak self] granted in
            if granted {
                self?.settings.notificationsEnabled = true
                self?.saveSettings()
            }
            self?.checkNotificationPermission()
        }
    }
    
    func toggleNotifications() {
        if settings.notificationsEnabled {
            // Turning off
            settings.notificationsEnabled = false
            notificationService.cancelAllNotifications()
            saveSettings()
        } else {
            // Turning on - need permission
            if notificationPermissionStatus == .authorized {
                settings.notificationsEnabled = true
                saveSettings()
            } else {
                requestNotificationPermission()
            }
        }
    }
}
