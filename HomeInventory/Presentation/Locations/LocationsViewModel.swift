import SwiftUI

@MainActor
final class LocationsViewModel: ObservableObject {
    @Published var locations: [Location] = []
    @Published var showingAddLocation = false
    @Published var deletingLocationID: UUID?

    private let locationService = LocationService.shared
    private let inventoryService = InventoryService.shared

    func loadLocations() {
        locationService.refreshItemCounts()
        locations = locationService.getAllLocations()
    }

    func getItemCount(for locationID: UUID) -> Int {
        let location = locationService.getLocation(by: locationID)
        return location?.itemCount ?? 0
    }

    func canDeleteLocation(_ location: Location) -> Bool {
        let allLocations = locationService.getAllLocations()
        return allLocations.count > 1
    }
    
    func deleteLocation(_ location: Location) {
        guard canDeleteLocation(location) else {
            return
        }
        
        deletingLocationID = location.id
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            // Wait for animation to complete
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self = self else { return }
            self.locationService.deleteLocation(location)
            self.deletingLocationID = nil
            self.loadLocations()
            HapticsService.shared.success()
        }
    }
}

