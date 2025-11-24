import UIKit

final class HapticsService {
    static let shared = HapticsService()

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    private init() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notification.prepare()
        selectionGenerator.prepare()
    }

    // MARK: - Impact Feedback
    func light() {
        impactLight.impactOccurred()
        impactLight.prepare()
    }

    func medium() {
        impactMedium.impactOccurred()
        impactMedium.prepare()
    }

    func heavy() {
        impactHeavy.impactOccurred()
        impactHeavy.prepare()
    }

    // MARK: - Notification Feedback
    func success() {
        notification.notificationOccurred(.success)
        notification.prepare()
    }

    func warning() {
        notification.notificationOccurred(.warning)
        notification.prepare()
    }

    func error() {
        notification.notificationOccurred(.error)
        notification.prepare()
    }

    // MARK: - Selection Feedback
    func selection() {
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }
}
