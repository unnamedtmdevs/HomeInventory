import SwiftUI
import UserNotifications

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showingExportSheet = false
    @State private var exportedCSV: String = ""

    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom header
                ScreenHeader(
                    title: "Settings",
                    subtitle: "Customize your experience",
                    icon: "gearshape.fill",
                    accentColor: .accent3
                )
                .padding(.top, 50)
                .padding(.bottom, AppSpacing.lg)

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        hapticsSection
                        
                        notificationsSection
                        
                        statisticsSection
                        
                        displayPreferencesSection
                        
                        photoSettingsSection
                        
                        searchSettingsSection
                        
                        dataManagementSection
                        
                        aboutSection
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.bottom, 120)
                }
            }
        }
        .alert("Clear All Data", isPresented: $viewModel.showingClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                viewModel.clearAllData()
            }
        } message: {
            Text("This will permanently delete all items, photos, and data. This action cannot be undone.")
        }
        .alert("Data Cleared", isPresented: $viewModel.showingClearDataSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("All data has been successfully cleared.")
        }
        .alert("Export Successful", isPresented: $viewModel.showingExportSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your data has been exported to CSV format.")
        }
    }
    
    private var hapticsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Haptics")
                .font(.appTitle)
                .foregroundColor(.textPrimary)
            
            Toggle(isOn: $viewModel.settings.hapticsEnabled) {
                HStack(spacing: AppSpacing.md) {
                    Image(systemName: "hand.tap.fill")
                        .foregroundColor(.accent1)
                        .font(.system(size: 20))
                    Text("Haptic Feedback")
                        .font(.appBody)
                        .foregroundColor(.textPrimary)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: .accent1))
            .onChange(of: viewModel.settings.hapticsEnabled) { _ in
                viewModel.saveSettings()
            }
        }
        .padding(AppSpacing.md)
        .background(Color.backgroundCard)
        .cornerRadius(AppSpacing.radiusLarge)
    }
    
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Notifications")
                .font(.appTitle)
                .foregroundColor(.textPrimary)
            
            Toggle(isOn: Binding(
                get: { viewModel.settings.notificationsEnabled },
                set: { _ in viewModel.toggleNotifications() }
            )) {
                HStack(spacing: AppSpacing.md) {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.accent2)
                        .font(.system(size: 20))
                    Text("Daily Reminders")
                        .font(.appBody)
                        .foregroundColor(.textPrimary)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: .accent2))
            
            if viewModel.settings.notificationsEnabled {
                DatePicker(
                    "Notification Time",
                    selection: $viewModel.settings.notificationTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
                .foregroundColor(.textPrimary)
                .onChange(of: viewModel.settings.notificationTime) { _ in
                    viewModel.saveSettings()
                }
                .padding(.top, AppSpacing.sm)
            }
        }
        .padding(AppSpacing.md)
        .background(Color.backgroundCard)
        .cornerRadius(AppSpacing.radiusLarge)
    }

    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Statistics")
                .font(.appTitle)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: AppSpacing.sm) {
                StatRow(icon: "archivebox.fill", title: "Total Items", value: "\(viewModel.getTotalItems())", color: .accent1)
                StatRow(icon: "folder.fill", title: "Total Categories", value: "\(viewModel.getTotalCategories())", color: .accent2)
                StatRow(icon: "photo.fill", title: "Items with Photos", value: "\(viewModel.getItemsWithPhotos())", color: .accent3)
                StatRow(icon: "internaldrive.fill", title: "Storage Used", value: viewModel.getStorageUsed(), color: .accent4)
            }
        }
        .padding(AppSpacing.md)
        .background(Color.backgroundCard)
        .cornerRadius(AppSpacing.radiusLarge)
    }

    private var displayPreferencesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Display Preferences")
                .font(.appTitle)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: AppSpacing.sm) {
                Picker("Default View", selection: $viewModel.settings.defaultViewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .onChange(of: viewModel.settings.defaultViewMode) { _ in
                    viewModel.saveSettings()
                }
                
                Toggle("Show Photos in List", isOn: $viewModel.settings.showPhotosInList)
                    .onChange(of: viewModel.settings.showPhotosInList) { _ in
                        viewModel.saveSettings()
                    }
                
                Picker("Default Sort", selection: $viewModel.settings.defaultSortOption) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .onChange(of: viewModel.settings.defaultSortOption) { _ in
                    viewModel.saveSettings()
                }
            }
        }
        .padding(AppSpacing.md)
        .background(Color.backgroundCard)
        .cornerRadius(AppSpacing.radiusLarge)
    }

    private var photoSettingsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Photo Settings")
                .font(.appTitle)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: AppSpacing.sm) {
                Picker("Photo Quality", selection: $viewModel.settings.photoQuality) {
                    ForEach(PhotoQuality.allCases, id: \.self) { quality in
                        Text(quality.displayName).tag(quality)
                    }
                }
                .onChange(of: viewModel.settings.photoQuality) { _ in
                    viewModel.saveSettings()
                }
                
                Stepper("Max Photos: \(viewModel.settings.maxPhotosPerItem)", value: $viewModel.settings.maxPhotosPerItem, in: 1...10)
                    .onChange(of: viewModel.settings.maxPhotosPerItem) { _ in
                        viewModel.saveSettings()
                    }
                
                Toggle("Auto-Compress Photos", isOn: $viewModel.settings.autoCompressPhotos)
                    .onChange(of: viewModel.settings.autoCompressPhotos) { _ in
                        viewModel.saveSettings()
                    }
            }
        }
        .padding(AppSpacing.md)
        .background(Color.backgroundCard)
        .cornerRadius(AppSpacing.radiusLarge)
    }

    private var searchSettingsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Search Settings")
                .font(.appTitle)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: AppSpacing.sm) {
                Toggle("Search History", isOn: $viewModel.settings.searchHistoryEnabled)
                    .onChange(of: viewModel.settings.searchHistoryEnabled) { _ in
                        viewModel.saveSettings()
                    }
                
                Toggle("Auto-Search", isOn: $viewModel.settings.autoSearchEnabled)
                    .onChange(of: viewModel.settings.autoSearchEnabled) { _ in
                        viewModel.saveSettings()
                    }
                
                Toggle("Case-Sensitive Search", isOn: $viewModel.settings.caseSensitiveSearch)
                    .onChange(of: viewModel.settings.caseSensitiveSearch) { _ in
                        viewModel.saveSettings()
                    }
            }
        }
        .padding(AppSpacing.md)
        .background(Color.backgroundCard)
        .cornerRadius(AppSpacing.radiusLarge)
    }

    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Data Management")
                .font(.appTitle)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: AppSpacing.sm) {
                Button(action: {
                    exportedCSV = viewModel.exportData()
                    if !exportedCSV.isEmpty {
                        showingExportSheet = true
                    }
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.accent2)
                        Text("Export to CSV")
                            .font(.appBody)
                            .foregroundColor(.textPrimary)
                        Spacer()
                    }
                    .padding(AppSpacing.md)
                    .background(Color.backgroundSecondary)
                    .cornerRadius(AppSpacing.radiusMedium)
                }
                
                Button(role: .destructive, action: {
                    viewModel.showingClearDataAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.error)
                        Text("Clear All Data")
                            .font(.appBody)
                            .foregroundColor(.error)
                        Spacer()
                    }
                    .padding(AppSpacing.md)
                    .background(Color.error.opacity(0.1))
                    .cornerRadius(AppSpacing.radiusMedium)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(Color.backgroundCard)
        .cornerRadius(AppSpacing.radiusLarge)
        .sheet(isPresented: $showingExportSheet) {
            ShareSheet(items: [exportedCSV])
        }
        .onChange(of: showingExportSheet) { isShowing in
            if !isShowing && !exportedCSV.isEmpty {
                // Show success alert after sheet is dismissed
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    viewModel.showingExportSuccess = true
                }
            }
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("About")
                .font(.appTitle)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: AppSpacing.sm) {
                HStack {
                    Text("Version")
                        .font(.appBody)
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Text(viewModel.getAppVersion())
                        .font(.appBody)
                        .foregroundColor(.textSecondary)
                }
                
                HStack {
                    Text("App Name")
                        .font(.appBody)
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Text("HomeInventory")
                        .font(.appBody)
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(Color.backgroundCard)
        .cornerRadius(AppSpacing.radiusLarge)
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 18))
            Text(title)
                .font(.appBody)
                .foregroundColor(.textPrimary)
            Spacer()
            Text(value)
                .font(.appBody)
                .foregroundColor(.textSecondary)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
