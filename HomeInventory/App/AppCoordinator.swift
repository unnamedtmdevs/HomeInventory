import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var isLoading = true
    @Published var hasSeenOnboarding = false

    private let storage = StorageService.shared

    func initialize() {
        AppTheme.configure()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let appState = self.storage.loadAppState()
            self.hasSeenOnboarding = appState.hasSeenOnboarding

            withAnimation {
                self.isLoading = false
            }
        }
    }
    
    func completeOnboarding() {
        var appState = storage.loadAppState()
        appState.hasSeenOnboarding = true
        storage.saveAppState(appState)
        
        withAnimation {
            hasSeenOnboarding = true
        }
    }
}

struct RootView: View {
    @StateObject private var coordinator = AppCoordinator()

    var body: some View {
        ZStack {
            if coordinator.isLoading {
                LoadingView()
            } else if !coordinator.hasSeenOnboarding {
                OnboardingView(isPresented: Binding(
                    get: { !coordinator.hasSeenOnboarding },
                    set: { _ in coordinator.completeOnboarding() }
                ))
                .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            coordinator.initialize()
        }
    }
}
