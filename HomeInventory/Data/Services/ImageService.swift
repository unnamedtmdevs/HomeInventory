import UIKit

final class ImageService {
    static let shared = ImageService()

    private let storage = StorageService.shared

    private init() {}

    // MARK: - Save Photo
    func savePhoto(_ image: UIImage, quality: PhotoQuality = .medium) -> String? {
        let compressedImage = compressImage(image, quality: quality)
        return storage.savePhoto(compressedImage, quality: quality.compressionQuality)
    }
    
    func savePhoto(_ image: UIImage, quality: CGFloat) -> String? {
        // Determine PhotoQuality based on compression quality value
        let photoQuality: PhotoQuality
        if quality <= 0.4 {
            photoQuality = .low
        } else if quality <= 0.7 {
            photoQuality = .medium
        } else {
            photoQuality = .high
        }
        let compressedImage = compressImage(image, quality: photoQuality)
        return storage.savePhoto(compressedImage, quality: quality)
    }

    // MARK: - Load Photo
    func loadPhoto(_ photoID: String) -> UIImage? {
        return storage.loadPhoto(photoID)
    }

    // MARK: - Delete Photo
    func deletePhoto(_ photoID: String) {
        storage.deletePhoto(photoID)
    }

    func deletePhotos(_ photoIDs: [String]) {
        storage.deletePhotos(photoIDs)
    }

    // MARK: - Compress Image
    private func compressImage(_ image: UIImage, quality: PhotoQuality) -> UIImage {
        let maxSize: CGFloat

        switch quality {
        case .low:
            maxSize = 800
        case .medium:
            maxSize = 1200
        case .high:
            maxSize = 1600
        }

        let size = image.size
        let ratio = min(maxSize / size.width, maxSize / size.height)

        if ratio >= 1 {
            return image
        }

        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }

        return resizedImage
    }

    // MARK: - Validate Image
    func validateImage(_ image: UIImage, maxSize: CGSize = CGSize(width: 4000, height: 4000)) -> Bool {
        return image.size.width <= maxSize.width && image.size.height <= maxSize.height
    }

    // MARK: - Create Thumbnail
    func createThumbnail(_ image: UIImage, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let thumbnail = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return thumbnail
    }
}
