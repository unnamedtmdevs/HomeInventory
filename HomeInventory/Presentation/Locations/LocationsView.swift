import SwiftUI

struct LocationsView: View {
    @StateObject private var viewModel = LocationsViewModel()
    @State private var showingEditLocation = false
    @State private var locationToEdit: Location?
    @State private var locationToDelete: Location?
    @State private var showingDeleteAlert = false
    @State private var selectedLocation: Location?

    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom header with button
                ZStack(alignment: .topTrailing) {
                    ScreenHeader(
                        title: "Locations",
                        subtitle: "Organize by place",
                        icon: "mappin.circle.fill",
                        accentColor: .accent4
                    )
                    .padding(.top, 50)
                    .padding(.bottom, AppSpacing.lg)
                    
                    Button(action: {
                        showingEditLocation = false
                        locationToEdit = nil
                        viewModel.showingAddLocation = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.accent4)
                    }
                    .padding(.top, 50)
                    .padding(.trailing, AppSpacing.lg)
                }

                if viewModel.locations.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: AppSpacing.md) {
                            ForEach(viewModel.locations) { location in
                                Button(action: {
                                    selectedLocation = location
                                    HapticsService.shared.selection()
                                }) {
                                    LocationCard(
                                        location: location,
                                        itemCount: viewModel.getItemCount(for: location.id)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .contextMenu {
                                    Button {
                                        locationToEdit = location
                                        showingEditLocation = true
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    
                                    Button(role: .destructive) {
                                        locationToDelete = location
                                        showingDeleteAlert = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .opacity(viewModel.deletingLocationID == location.id ? 0 : 1)
                                .scaleEffect(viewModel.deletingLocationID == location.id ? 0.7 : 1.0)
                                .blur(radius: viewModel.deletingLocationID == location.id ? 5 : 0)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.deletingLocationID)
                            }
                        }
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadLocations()
        }
        .onChange(of: viewModel.showingAddLocation) { isShowing in
            if !isShowing {
                viewModel.loadLocations()
            }
        }
        .onChange(of: showingEditLocation) { isShowing in
            if !isShowing {
                viewModel.loadLocations()
            }
        }
        .sheet(isPresented: $viewModel.showingAddLocation) {
            AddLocationView(
                isPresented: $viewModel.showingAddLocation,
                onSave: {
                    viewModel.loadLocations()
                }
            )
        }
        .sheet(isPresented: $showingEditLocation) {
            if let location = locationToEdit {
                AddLocationView(
                    isPresented: $showingEditLocation,
                    editingLocation: location,
                    onSave: {
                        viewModel.loadLocations()
                    }
                )
            }
        }
        .sheet(item: $selectedLocation) { location in
            LocationDetailView(
                location: location,
                onEdit: {
                    locationToEdit = location
                    selectedLocation = nil
                    showingEditLocation = true
                },
                onDelete: {
                    locationToDelete = location
                    selectedLocation = nil
                    showingDeleteAlert = true
                }
            )
        }
        .alert("Delete Location", isPresented: $showingDeleteAlert) {
            if let location = locationToDelete, viewModel.canDeleteLocation(location) {
                Button("Cancel", role: .cancel) {
                    locationToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    viewModel.deleteLocation(location)
                    locationToDelete = nil
                }
            } else {
                Button("OK", role: .cancel) {
                    locationToDelete = nil
                }
            }
        } message: {
            if let location = locationToDelete {
                if !viewModel.canDeleteLocation(location) {
                    Text("You cannot delete the last location. Please create another location first.")
                } else {
                    let itemCount = viewModel.getItemCount(for: location.id)
                    if itemCount > 0 {
                        Text("This will delete '\(location.name)' and \(itemCount) item\(itemCount == 1 ? "" : "s") will lose this location. This action cannot be undone.")
                    } else {
                        Text("This will permanently delete '\(location.name)'. This action cannot be undone.")
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            EmptyStateView(
                icon: "mappin.circle",
                title: "No locations",
                message: "Create your first location to get started"
            )
            .padding(.horizontal, AppSpacing.xl)
            Spacer()
        }
    }
}

struct LocationCard: View {
    let location: Location
    let itemCount: Int
    
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(location.color.opacity(0.15))
                    .frame(width: 70, height: 70)
                
                Image(systemName: location.iconName)
                    .font(.system(size: 32))
                    .foregroundColor(location.color)
            }
            
            VStack(spacing: 4) {
                Text(location.name)
                    .font(.appHeadline)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                Text("\(itemCount) item\(itemCount == 1 ? "" : "s")")
                    .font(.appCaption)
                    .foregroundColor(.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.md)
        .background(Color.backgroundCard)
        .cornerRadius(AppSpacing.radiusLarge)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                .stroke(location.color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct AddLocationView: View {
    @Binding var isPresented: Bool
    let editingLocation: Location?
    let onSave: (() -> Void)?
    @State private var name: String = ""
    @State private var selectedIcon: String = "mappin.circle.fill"
    @State private var selectedColor: Color = .accent2

    private let locationService = LocationService.shared
    
    init(isPresented: Binding<Bool>, editingLocation: Location? = nil, onSave: (() -> Void)? = nil) {
        self._isPresented = isPresented
        self.editingLocation = editingLocation
        self.onSave = onSave
    }

    private let iconOptions = [
        "mappin.circle.fill", "house.fill", "car.fill", "briefcase.fill",
        "sofa.fill", "bed.double.fill", "fork.knife", "shower.fill",
        "archivebox.fill", "building.2.fill", "door.left.hand.open", "cabinet.fill",
        "square.grid.2x2.fill", "cube.box.fill", "tray.fill", "bag.fill"
    ]

    private let colorOptions: [Color] = [
        .accent1, .accent2, .accent3, .accent4, .accent5, .accent6
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    previewSection

                    CustomTextField(
                        title: "Location Name",
                        placeholder: "Enter name",
                        text: $name,
                        icon: "tag.fill"
                    )

                    iconPickerSection

                    colorPickerSection

                    CustomButton(
                        title: editingLocation == nil ? "Create Location" : "Save Changes",
                        icon: "checkmark.circle.fill",
                        style: .primary
                    ) {
                        saveLocation()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.xxl)
            }
            .background(Color.backgroundPrimary.ignoresSafeArea())
            .navigationTitle(editingLocation == nil ? "New Location" : "Edit Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
        .onAppear {
            if let location = editingLocation {
                name = location.name
                selectedIcon = location.iconName
                selectedColor = location.color
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    private var previewSection: some View {
        VStack(spacing: AppSpacing.md) {
            Text("Preview")
                .font(.appTitle)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                Circle()
                    .fill(selectedColor.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: selectedIcon)
                    .font(.system(size: 48))
                    .foregroundColor(selectedColor)
            }
            .frame(maxWidth: .infinity)

            Text(name.isEmpty ? "Location Name" : name)
                .font(.appHeadline)
                .foregroundColor(.textPrimary)
        }
        .padding(AppSpacing.md)
        .background(Color.backgroundCard)
        .cornerRadius(AppSpacing.radiusLarge)
    }

    private var iconPickerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Icon")
                .font(.appTitle)
                .foregroundColor(.textPrimary)

            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 60))
            ], spacing: AppSpacing.md) {
                ForEach(iconOptions, id: \.self) { icon in
                    Button(action: {
                        selectedIcon = icon
                        HapticsService.shared.selection()
                    }) {
                        Image(systemName: icon)
                            .font(.system(size: 28))
                            .foregroundColor(selectedIcon == icon ? selectedColor : .textSecondary)
                            .frame(width: 60, height: 60)
                            .background(selectedIcon == icon ? selectedColor.opacity(0.15) : Color.backgroundCard)
                            .cornerRadius(AppSpacing.radiusMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                                    .stroke(selectedIcon == icon ? selectedColor : Color.borderPrimary, lineWidth: selectedIcon == icon ? 2 : 1)
                            )
                    }
                }
            }
        }
    }

    private var colorPickerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Color")
                .font(.appTitle)
                .foregroundColor(.textPrimary)

            HStack(spacing: AppSpacing.md) {
                ForEach(colorOptions, id: \.self) { color in
                    Button(action: {
                        selectedColor = color
                        HapticsService.shared.selection()
                    }) {
                        Circle()
                            .fill(color)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.borderPrimary, lineWidth: 1)
                            )
                    }
                }
            }
        }
    }

    private func saveLocation() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        if let editingLocation = editingLocation {
            var updatedLocation = editingLocation
            updatedLocation.name = trimmedName
            updatedLocation.iconName = selectedIcon
            updatedLocation.colorHex = selectedColor.toHex() ?? editingLocation.colorHex
            locationService.updateLocation(updatedLocation)
        } else {
            let newLocation = Location(
                name: trimmedName,
                iconName: selectedIcon,
                colorHex: selectedColor.toHex() ?? "#43A047",
                isDefault: false
            )
            locationService.createLocation(newLocation)
        }
        
        HapticsService.shared.success()
        onSave?()
        isPresented = false
    }
}

struct LocationDetailView: View {
    let location: Location
    let onEdit: () -> Void
    let onDelete: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteAlert = false
    @State private var showingEditLocation = false
    @State private var items: [InventoryItem] = []
    @State private var selectedItem: InventoryItem?
    @State private var showingItemDetail = false
    
    private let inventoryService = InventoryService.shared
    private let categoryService = CategoryService.shared
    
    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom header
                ZStack(alignment: .topTrailing) {
                    ScreenHeader(
                        title: location.name,
                        subtitle: "\(items.count) item\(items.count == 1 ? "" : "s")",
                        icon: location.iconName,
                        accentColor: location.color
                    )
                    .padding(.top, 50)
                    .padding(.bottom, AppSpacing.lg)
                    
                    HStack(spacing: AppSpacing.md) {
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.error)
                        }
                        
                        Button(action: {
                            showingEditLocation = true
                            HapticsService.shared.selection()
                        }) {
                            Image(systemName: "pencil.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.accent2)
                        }
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.textTertiary)
                        }
                    }
                    .padding(.top, 50)
                    .padding(.trailing, AppSpacing.lg)
                }

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Info card
                        infoCard
                            .padding(.horizontal, AppSpacing.md)
                        
                        // Items list
                        if items.isEmpty {
                            emptyItemsState
                                .padding(.horizontal, AppSpacing.md)
                        } else {
                            itemsSection
                                .padding(.horizontal, AppSpacing.md)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .onAppear {
            loadItems()
        }
        .alert("Delete Location", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to delete \"\(location.name)\"? All items in this location will lose their location assignment.")
        }
        .sheet(item: $selectedItem) { item in
            ItemDetailView(
                item: item,
                onEdit: {},
                onDelete: {
                    loadItems()
                }
            )
        }
        .onChange(of: selectedItem) { item in
            if item == nil {
                loadItems()
            }
        }
        .sheet(isPresented: $showingEditLocation) {
            AddLocationView(
                isPresented: $showingEditLocation,
                editingLocation: location,
                onSave: {
                    loadItems()
                    onEdit()
                }
            )
        }
        .onChange(of: showingEditLocation) { isShowing in
            if !isShowing {
                loadItems()
            }
        }
    }
    
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    location.color.opacity(0.3),
                                    location.color.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: location.iconName)
                        .font(.system(size: 36))
                        .foregroundColor(location.color)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(items.count)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(location.color)
                    
                    Text("item\(items.count == 1 ? "" : "s")")
                        .font(.appCaption)
                        .foregroundColor(.textTertiary)
                }
            }
            
            if let lastUsed = location.lastUsed {
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.textTertiary)
                    Text("Last used: \(lastUsed.formatted(date: .abbreviated, time: .omitted))")
                        .font(.appCaption)
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(Color.backgroundCard)
        .cornerRadius(AppSpacing.radiusLarge)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                .stroke(location.color.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Items")
                .font(.appTitle)
                .foregroundColor(.textPrimary)
            
            LazyVStack(spacing: AppSpacing.md) {
                ForEach(items) { item in
                    Button(action: {
                        selectedItem = item
                        showingItemDetail = true
                        HapticsService.shared.selection()
                    }) {
                        LocationItemRow(
                            item: item,
                            category: categoryService.getCategory(by: item.categoryID)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(AppSpacing.md)
        .background(Color.backgroundCard)
        .cornerRadius(AppSpacing.radiusLarge)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                .stroke(Color.borderPrimary, lineWidth: 1)
        )
    }
    
    private var emptyItemsState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "cube.box")
                .font(.system(size: 48))
                .foregroundColor(.textQuaternary)
            
            Text("No items in this location")
                .font(.appHeadline)
                .foregroundColor(.textSecondary)
            
            Text("Add items and assign them to this location")
                .font(.appCaption)
                .foregroundColor(.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
        .background(Color.backgroundCard)
        .cornerRadius(AppSpacing.radiusLarge)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                .stroke(Color.borderPrimary, lineWidth: 1)
        )
    }
    
    private func loadItems() {
        let allItems = inventoryService.getAllItems()
        items = allItems.filter { $0.location == location.name }
            .sorted { $0.dateAdded > $1.dateAdded }
    }
}

struct LocationItemRow: View {
    let item: InventoryItem
    let category: Category?
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Photo or placeholder
            if let firstPhotoID = item.photoIDs.first,
               let image = ImageService.shared.loadPhoto(firstPhotoID) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(AppSpacing.radiusMedium)
            } else {
                ZStack {
                    Color.backgroundSecondary
                    Image(systemName: "photo")
                        .font(.system(size: 24))
                        .foregroundColor(.textQuaternary)
                }
                .frame(width: 60, height: 60)
                .cornerRadius(AppSpacing.radiusMedium)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.appHeadline)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    
                    if item.isImportant {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.accent1)
                    }
                }
                
                if let category = category {
                    HStack(spacing: 4) {
                        Image(systemName: category.iconName)
                            .font(.system(size: 10))
                            .foregroundColor(category.color)
                        Text(category.name)
                            .font(.appCaption)
                            .foregroundColor(.textTertiary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.textTertiary)
        }
        .padding(AppSpacing.sm)
        .background(Color.backgroundSecondary)
        .cornerRadius(AppSpacing.radiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                .stroke(
                    item.colorHex.isEmpty ? Color.clear : item.color.opacity(0.4),
                    lineWidth: item.colorHex.isEmpty ? 0 : 1.5
                )
        )
    }
}

