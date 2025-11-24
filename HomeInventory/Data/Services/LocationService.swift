import Foundation

final class LocationService {
    static let shared = LocationService()

    private let storage = StorageService.shared
    private var locations: [Location] = []

    private init() {
        loadLocations()
    }

    // MARK: - Load Locations
    func loadLocations() {
        locations = storage.loadLocations()
        if locations.isEmpty {
            locations = Location.defaultLocations
            storage.saveLocations(locations)
        }
    }

    // MARK: - Get Locations
    func getAllLocations() -> [Location] {
        loadLocations() // Reload from storage to ensure data is up-to-date
        return locations
    }

    func getLocation(by id: UUID) -> Location? {
        return locations.first { $0.id == id }
    }
    
    func getLocation(by name: String) -> Location? {
        return locations.first { $0.name == name }
    }

    func getDefaultLocations() -> [Location] {
        return locations.filter { $0.isDefault }
    }

    func getCustomLocations() -> [Location] {
        return locations.filter { !$0.isDefault }
    }

    // MARK: - Create Location
    func createLocation(_ location: Location) {
        locations.append(location)
        storage.saveLocations(locations)
    }

    // MARK: - Update Location
    func updateLocation(_ location: Location) {
        if let index = locations.firstIndex(where: { $0.id == location.id }) {
            let oldLocation = locations[index]
            let oldName = oldLocation.name
            let newName = location.name
            
            // Update items if location name changed
            if oldName != newName {
                let inventoryService = InventoryService.shared
                let items = inventoryService.getAllItems()
                let itemsWithLocation = items.filter { $0.location == oldName }
                
                for item in itemsWithLocation {
                    var updatedItem = item
                    updatedItem.location = newName
                    inventoryService.updateItem(updatedItem)
                }
            }
            
            locations[index] = location
            storage.saveLocations(locations)
        }
    }

    // MARK: - Delete Location
    func deleteLocation(_ location: Location) {
        // Clear location from items that use this location
        let inventoryService = InventoryService.shared
        let items = inventoryService.getAllItems()
        let itemsWithLocation = items.filter { $0.location == location.name }
        
        for item in itemsWithLocation {
            var updatedItem = item
            updatedItem.location = ""
            inventoryService.updateItem(updatedItem)
        }
        
        locations.removeAll { $0.id == location.id }
        storage.saveLocations(locations)
    }
    
    // MARK: - Refresh Item Counts
    func refreshItemCounts() {
        let inventoryService = InventoryService.shared
        let allItems = inventoryService.getAllItems()
        
        for index in locations.indices {
            let locationName = locations[index].name
            let count = allItems.filter { $0.location == locationName }.count
            locations[index].itemCount = count
            if count > 0 {
                locations[index].lastUsed = allItems
                    .filter { $0.location == locationName }
                    .max(by: { $0.dateAdded < $1.dateAdded })?.dateAdded
            }
        }
        
        storage.saveLocations(locations)
    }
    
    // MARK: - Get Other Location
    func getOtherLocation() -> Location? {
        return locations.first { $0.name == "Other" && $0.isDefault }
    }
}

