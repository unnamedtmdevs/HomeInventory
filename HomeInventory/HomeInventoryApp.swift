import SwiftUI

@main
struct HomeInventoryApp: App {
    init() {
        AppTheme.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
