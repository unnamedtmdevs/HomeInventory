import SwiftUI

struct ItemsView: View {
    @StateObject private var viewModel = ItemsViewModel()
    @State private var selectedItem: InventoryItem?
    @State private var showingItemDetail = false
    @State private var showingEditItem = false
    @State private var showingAddItem = false

    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom header with buttons
                ZStack(alignment: .topTrailing) {
                    ScreenHeader(
                        title: "Items",
                        subtitle: "All your belongings",
                        icon: "square.grid.2x2.fill",
                        accentColor: .accent2
                    )
                    .padding(.top, 50)
                    .padding(.bottom, AppSpacing.lg)
                    
                    HStack(spacing: AppSpacing.md) {
                        addItemButton
                        viewModeButton
                    }
                    .padding(.top, 50)
                    .padding(.trailing, AppSpacing.lg)
                }

                searchBar

                filterBar

                if viewModel.filteredItems.isEmpty {
                    emptyState
                } else {
                    itemsContent
                }
            }
        }
        .onAppear {
            viewModel.loadData()
        }
        .onChange(of: viewModel.showFilterSheet) { isShowing in
            if !isShowing {
                viewModel.loadData()
            }
        }
        .sheet(item: $selectedItem) { item in
            ItemDetailView(item: item, onEdit: {
                showingEditItem = true
            }, onDelete: {
                viewModel.deleteItem(item)
                selectedItem = nil
            })
        }
        .sheet(isPresented: $showingEditItem) {
            if let item = selectedItem {
                AddItemView(isPresented: $showingEditItem, editingItem: item)
            }
        }
        .onChange(of: showingEditItem) { isShowing in
            if !isShowing {
                viewModel.loadData()
                selectedItem = nil
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView(isPresented: $showingAddItem)
        }
        .onChange(of: showingAddItem) { isShowing in
            if !isShowing {
                viewModel.loadData()
            }
        }
        .onChange(of: selectedItem) { item in
            if item == nil {
                viewModel.loadData()
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.textTertiary)

                TextField("Search items...", text: $viewModel.searchText)
                    .font(.appBody)
                    .foregroundColor(.textPrimary)
                    .onChange(of: viewModel.searchText) { _ in
                        if viewModel.settings.autoSearchEnabled {
                            viewModel.applyFiltersAndSort()
                        }
                    }
                    .onSubmit {
                        viewModel.applyFiltersAndSort()
                    }

                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                        viewModel.applyFiltersAndSort()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.textTertiary)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .frame(height: 44)
            .background(Color.backgroundInput)
            .cornerRadius(AppSpacing.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                    .stroke(Color.borderPrimary, lineWidth: 1)
            )

            Button(action: {
                viewModel.showFilterSheet = true
            }) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 24))
                    .foregroundColor(.accent5)
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(Color.backgroundPrimary)
        .sheet(isPresented: $viewModel.showFilterSheet) {
            FilterSheet(viewModel: viewModel)
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                Button(action: {
                    viewModel.showSortSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                        Text(viewModel.sortOption.displayName)
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, 8)
                    .background(Color.backgroundCard)
                    .cornerRadius(AppSpacing.radiusSmall)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppSpacing.radiusSmall)
                            .stroke(Color.borderPrimary, lineWidth: 1)
                    )
                }
                .sheet(isPresented: $viewModel.showSortSheet) {
                    SortSheet(viewModel: viewModel)
                }

                if viewModel.importantOnly || viewModel.withPhotosOnly || viewModel.withoutPhotosOnly || !viewModel.selectedCategories.isEmpty {
                    Button(action: {
                        viewModel.clearFilters()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark")
                            Text("Clear Filters")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.error)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, 8)
                        .background(Color.error.opacity(0.1))
                        .cornerRadius(AppSpacing.radiusSmall)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppSpacing.radiusSmall)
                                .stroke(Color.error.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
        }
        .padding(.vertical, AppSpacing.sm)
        .background(Color.backgroundPrimary)
    }

    private var itemsContent: some View {
        ScrollView {
            if viewModel.viewMode == .grid {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], alignment: .center, spacing: AppSpacing.md) {
                    ForEach(viewModel.filteredItems) { item in
                        ItemCard(
                            item: item,
                            category: viewModel.getCategory(for: item),
                            onTap: {
                                selectedItem = item
                                showingItemDetail = true
                            },
                            onEdit: {
                                selectedItem = item
                                showingEditItem = true
                            },
                            onDelete: {
                                viewModel.deleteItem(item)
                            }
                        )
                        .opacity(viewModel.deletingItemID == item.id ? 0 : 1)
                        .scaleEffect(viewModel.deletingItemID == item.id ? 0.7 : 1.0)
                        .blur(radius: viewModel.deletingItemID == item.id ? 5 : 0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.deletingItemID)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, 100)
            } else {
                LazyVStack(spacing: AppSpacing.md) {
                    ForEach(viewModel.filteredItems) { item in
                        ItemListRow(
                            item: item,
                            category: viewModel.getCategory(for: item),
                            onTap: {
                                selectedItem = item
                                showingItemDetail = true
                            },
                            onEdit: {
                                selectedItem = item
                                showingEditItem = true
                            },
                            onDelete: {
                                viewModel.deleteItem(item)
                            }
                        )
                        .opacity(viewModel.deletingItemID == item.id ? 0 : 1)
                        .scaleEffect(viewModel.deletingItemID == item.id ? 0.7 : 1.0)
                        .blur(radius: viewModel.deletingItemID == item.id ? 5 : 0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.deletingItemID)
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, 100)
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            EmptyStateView(
                icon: "archivebox",
                title: "No items found",
                message: "Try adjusting your search or filters"
            )
            .padding(.horizontal, AppSpacing.xl)
            Spacer()
        }
    }

    private var addItemButton: some View {
        Button(action: {
            HapticsService.shared.medium()
            showingAddItem = true
        }) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(.accent1)
        }
    }

    private var viewModeButton: some View {
        Button(action: {
            withAnimation {
                viewModel.viewMode = viewModel.viewMode == .grid ? .list : .grid
                HapticsService.shared.selection()
            }
        }) {
            Image(systemName: viewModel.viewMode == .grid ? "list.bullet" : "square.grid.2x2")
                .font(.system(size: 20))
                .foregroundColor(.accent1)
        }
    }
}

struct ItemListRow: View {
    let item: InventoryItem
    let category: Category?
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showingDeleteAlert = false
    private let settings = StorageService.shared.loadAppSettings()

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.md) {
                if settings.showPhotosInList {
                    if let firstPhotoID = item.photoIDs.first,
                       let image = ImageService.shared.loadPhoto(firstPhotoID) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(AppSpacing.radiusMedium)
                    } else {
                        ZStack {
                            Color.backgroundSecondary
                            Image(systemName: "photo")
                                .foregroundColor(.textQuaternary)
                        }
                        .frame(width: 80, height: 80)
                        .cornerRadius(AppSpacing.radiusMedium)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.name)
                            .font(.appHeadline)
                            .foregroundColor(.textPrimary)
                            .lineLimit(1)

                        if item.isImportant {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.accent1)
                        }
                    }

                    if let category = category {
                        CategoryBadge(category: category)
                    }

                    if !item.location.isEmpty {
                        Text(item.location)
                            .font(.appCaption)
                            .foregroundColor(.textTertiary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.textQuaternary)
            }
            .padding(AppSpacing.md)
            .background(Color.backgroundCard)
            .cornerRadius(AppSpacing.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                    .stroke(
                        item.colorHex.isEmpty ? Color.borderPrimary : item.color.opacity(0.6),
                        lineWidth: item.colorHex.isEmpty ? 1 : 2
                    )
            )
            .shadow(
                color: item.colorHex.isEmpty ? .clear : item.color.opacity(0.15),
                radius: item.colorHex.isEmpty ? 0 : 4,
                x: 0,
                y: item.colorHex.isEmpty ? 0 : 2
            )
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }

            Button(role: .destructive, action: { showingDeleteAlert = true }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Delete Item", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive, action: onDelete)
        } message: {
            Text("Are you sure you want to delete \"\(item.name)\"?")
        }
    }
}

struct FilterSheet: View {
    @ObservedObject var viewModel: ItemsViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section("Categories") {
                    ForEach(viewModel.categories) { category in
                        Button(action: {
                            if viewModel.selectedCategories.contains(category.id) {
                                viewModel.selectedCategories.remove(category.id)
                            } else {
                                viewModel.selectedCategories.insert(category.id)
                            }
                            HapticsService.shared.selection()
                        }) {
                            HStack {
                                Image(systemName: category.iconName)
                                    .foregroundColor(category.color)
                                Text(category.name)
                                    .foregroundColor(.textPrimary)
                                Spacer()
                                if viewModel.selectedCategories.contains(category.id) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accent2)
                                }
                            }
                        }
                    }
                }

                Section("Photo Status") {
                    Toggle("Important Only", isOn: $viewModel.importantOnly)
                    Toggle("With Photos Only", isOn: $viewModel.withPhotosOnly)
                    Toggle("Without Photos Only", isOn: $viewModel.withoutPhotosOnly)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear") {
                        viewModel.clearFilters()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.applyFiltersAndSort()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct SortSheet: View {
    @ObservedObject var viewModel: ItemsViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Button(action: {
                        viewModel.sortOption = option
                        viewModel.applyFiltersAndSort()
                        HapticsService.shared.selection()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text(option.displayName)
                                .foregroundColor(.textPrimary)
                            Spacer()
                            if viewModel.sortOption == option {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accent2)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Sort By")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct ItemDetailView: View {
    let item: InventoryItem
    let onEdit: () -> Void
    let onDelete: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteAlert = false
    @State private var rotationAngle: Double = 0
    
    private let categoryService = CategoryService.shared
    private var category: Category? {
        categoryService.getCategory(by: item.categoryID)
    }

    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom header
                ZStack(alignment: .topTrailing) {
                    ScreenHeader(
                        title: item.name,
                        subtitle: category?.name ?? "Item",
                        icon: category?.iconName ?? "cube.box.fill",
                        accentColor: category?.color ?? .accent2
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
                        
                        Button(action: onEdit) {
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
                        // Photos section
                        if !item.photoIDs.isEmpty {
                            photoSection
                                .padding(.horizontal, AppSpacing.md)
                        }
                        
                        // Main info card
                        mainInfoCard
                            .padding(.horizontal, AppSpacing.md)
                        
                        // Details cards
                        if !item.location.isEmpty || item.purchasePrice != nil || item.purchaseDate != nil {
                            detailsCard
                                .padding(.horizontal, AppSpacing.md)
                        }
                        
                        // Additional info
                        if !item.serialNumber.isEmpty || !item.warrantyInfo.isEmpty || !item.notes.isEmpty {
                            additionalInfoCard
                                .padding(.horizontal, AppSpacing.md)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
        .alert("Delete Item", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to delete \"\(item.name)\"?")
        }
    }
    
    private var photoSection: some View {
        TabView {
            ForEach(item.photoIDs, id: \.self) { photoID in
                if let image = ImageService.shared.loadPhoto(photoID) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .clipped()
                        .cornerRadius(AppSpacing.radiusLarge)
                }
            }
        }
        .frame(height: 300)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
    
    private var mainInfoCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                if let category = category {
                    CategoryBadge(category: category)
                }
                
                if item.isImportant {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                        Text("Important")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.accent1)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, 4)
                    .background(Color.accent1.opacity(0.15))
                    .cornerRadius(AppSpacing.radiusSmall)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppSpacing.radiusSmall)
                            .stroke(Color.accent1.opacity(0.3), lineWidth: 1)
                    )
                }
                
                if !item.colorHex.isEmpty {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 12, height: 12)
                        Text("Color")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, 4)
                    .background(item.color.opacity(0.15))
                    .cornerRadius(AppSpacing.radiusSmall)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppSpacing.radiusSmall)
                            .stroke(item.color.opacity(0.3), lineWidth: 1)
                    )
                }
                
                Spacer()
            }
            
            if !item.itemDescription.isEmpty {
                Text(item.itemDescription)
                    .font(.appBody)
                    .foregroundColor(.textSecondary)
                    .lineSpacing(4)
            }
        }
        .padding(AppSpacing.md)
        .background(Color.backgroundCard)
        .cornerRadius(AppSpacing.radiusLarge)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                .stroke(
                    item.colorHex.isEmpty ? Color.borderPrimary : item.color.opacity(0.3),
                    lineWidth: item.colorHex.isEmpty ? 1 : 2
                )
        )
    }
    
    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Details")
                .font(.appTitle)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: AppSpacing.sm) {
                if !item.location.isEmpty {
                    DetailRow(icon: "mappin.circle.fill", title: "Location", value: item.location, color: .accent4)
                }
                
                if let price = item.purchasePrice {
                    DetailRow(icon: "dollarsign.circle.fill", title: "Price", value: String(format: "$%.2f", price), color: .accent2)
                }
                
                if let date = item.purchaseDate {
                    DetailRow(icon: "calendar.circle.fill", title: "Purchase Date", value: date.formatted(date: .abbreviated, time: .omitted), color: .accent3)
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
    
    private var additionalInfoCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Additional Information")
                .font(.appTitle)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: AppSpacing.sm) {
                if !item.serialNumber.isEmpty {
                    DetailRow(icon: "number.circle.fill", title: "Serial Number", value: item.serialNumber, color: .accent5)
                }
                
                if !item.warrantyInfo.isEmpty {
                    DetailRow(icon: "shield.fill", title: "Warranty", value: item.warrantyInfo, color: .accent1)
                }
                
                if !item.notes.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        HStack {
                            Image(systemName: "note.text")
                                .font(.system(size: 18))
                                .foregroundColor(.accent3)
                            Text("Notes")
                                .font(.appHeadline)
                                .foregroundColor(.textPrimary)
                        }
                        Text(item.notes)
                            .font(.appBody)
                            .foregroundColor(.textSecondary)
                            .lineSpacing(4)
                    }
                    .padding(AppSpacing.md)
                    .background(Color.backgroundSecondary)
                    .cornerRadius(AppSpacing.radiusMedium)
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
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    init(icon: String, title: String, value: String, color: Color = .accent2) {
        self.icon = icon
        self.title = title
        self.value = value
        self.color = color
    }

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.appCaption)
                    .foregroundColor(.textTertiary)
                Text(value)
                    .font(.appBody)
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
        }
        .padding(AppSpacing.sm)
        .background(Color.backgroundSecondary)
        .cornerRadius(AppSpacing.radiusMedium)
    }
}
