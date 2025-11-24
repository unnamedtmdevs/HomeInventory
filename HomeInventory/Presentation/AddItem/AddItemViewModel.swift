import SwiftUI
import PhotosUI

@MainActor
final class AddItemViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var itemDescription: String = ""
    @Published var selectedCategory: Category?
    @Published var location: String = ""
    @Published var isImportant: Bool = false
    @Published var photos: [UIImage] = []
    @Published var photoIDs: [String] = []
    @Published var purchaseDate: Date?
    @Published var purchasePrice: String = ""
    @Published var serialNumber: String = ""
    @Published var warrantyInfo: String = ""
    @Published var notes: String = ""
    @Published var selectedColor: Color = .accent2
    @Published var showingImagePicker = false
    @Published var showingCamera = false
    @Published var showingCategoryPicker = false
    @Published var showingLocationPicker = false
    @Published var hasDate = false

    var categories: [Category] = []
    var locations: [Location] = []
    var editingItem: InventoryItem?

    private let inventoryService = InventoryService.shared
    private let categoryService = CategoryService.shared
    private let locationService = LocationService.shared
    private let imageService = ImageService.shared
    private let settings = StorageService.shared.loadAppSettings()

    init(editingItem: InventoryItem? = nil) {
        self.editingItem = editingItem
        loadCategories()
        loadLocations()

        if let item = editingItem {
            loadItemData(item)
        } else if let firstCategory = categories.first {
            selectedCategory = firstCategory
        }
    }

    func loadCategories() {
        categories = categoryService.getAllCategories()
    }
    
    func loadLocations() {
        locations = locationService.getAllLocations()
    }

    private func loadItemData(_ item: InventoryItem) {
        name = item.name
        itemDescription = item.itemDescription
        selectedCategory = categories.first { $0.id == item.categoryID }
        location = item.location
        isImportant = item.isImportant
        photoIDs = item.photoIDs
        purchaseDate = item.purchaseDate
        hasDate = item.purchaseDate != nil
        if let price = item.purchasePrice {
            purchasePrice = String(format: "%.2f", price)
        }
        serialNumber = item.serialNumber
        warrantyInfo = item.warrantyInfo
        notes = item.notes
        selectedColor = item.color

        for photoID in item.photoIDs {
            if let image = imageService.loadPhoto(photoID) {
                photos.append(image)
            }
        }
    }

    func addPhoto(_ image: UIImage) {
        if photos.count < settings.maxPhotosPerItem {
            photos.append(image)
            HapticsService.shared.success()
        }
    }

    func removePhoto(at index: Int) {
        photos.remove(at: index)
        if index < photoIDs.count {
            imageService.deletePhoto(photoIDs[index])
            photoIDs.remove(at: index)
        }
        HapticsService.shared.light()
    }

    func canSave() -> Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && selectedCategory != nil
    }

    func saveItem() -> Bool {
        guard canSave() else { return false }

        var savedPhotoIDs: [String] = []

        for (index, photo) in photos.enumerated() {
            if index < photoIDs.count {
                savedPhotoIDs.append(photoIDs[index])
            } else {
                // Use compression quality based on settings
                var quality = settings.photoQuality.compressionQuality
                if settings.autoCompressPhotos && quality > 0.5 {
                    // Additional compression if auto-compress is enabled
                    quality = min(quality * 0.9, 0.7)
                }
                if let photoID = imageService.savePhoto(photo, quality: quality) {
                    savedPhotoIDs.append(photoID)
                }
            }
        }

        let price = Double(purchasePrice)

        if let editingItem = editingItem {
            var updatedItem = editingItem
            updatedItem.name = name.trimmingCharacters(in: .whitespaces)
            updatedItem.itemDescription = itemDescription
            updatedItem.categoryID = selectedCategory!.id
            updatedItem.location = location
            updatedItem.isImportant = isImportant
            updatedItem.photoIDs = savedPhotoIDs
            updatedItem.purchaseDate = hasDate ? purchaseDate : nil
            updatedItem.purchasePrice = price
            updatedItem.serialNumber = serialNumber
            updatedItem.warrantyInfo = warrantyInfo
            updatedItem.notes = notes
            updatedItem.colorHex = selectedColor.toHex() ?? ""

            inventoryService.updateItem(updatedItem)
        } else {
            let newItem = InventoryItem(
                name: name.trimmingCharacters(in: .whitespaces),
                itemDescription: itemDescription,
                categoryID: selectedCategory!.id,
                location: location,
                isImportant: isImportant,
                photoIDs: savedPhotoIDs,
                purchaseDate: hasDate ? purchaseDate : nil,
                purchasePrice: price,
                serialNumber: serialNumber,
                warrantyInfo: warrantyInfo,
                notes: notes,
                colorHex: selectedColor.toHex() ?? ""
            )

            inventoryService.createItem(newItem)
        }

        categoryService.refreshItemCounts()
        HapticsService.shared.success()
        return true
    }

    func resetForm() {
        name = ""
        itemDescription = ""
        location = ""
        isImportant = false
        photos.removeAll()
        photoIDs.removeAll()
        purchaseDate = nil
        hasDate = false
        purchasePrice = ""
        serialNumber = ""
        warrantyInfo = ""
        notes = ""
        selectedColor = .accent2
        selectedCategory = categories.first
    }
}
