import SwiftUI

struct CategoriesView: View {
    @StateObject private var viewModel = CategoriesViewModel()
    @State private var showingAddCategory = false
    @State private var showingEditCategory = false
    @State private var selectedCategory: Category?
    @State private var categoryToEdit: Category?
    @State private var categoryToDelete: Category?
    @State private var showingDeleteAlert = false

    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom header with button
                ZStack(alignment: .topTrailing) {
                    ScreenHeader(
                        title: "Categories",
                        subtitle: "Organize by type",
                        icon: "folder.fill",
                        accentColor: .accent2
                    )
                    .padding(.top, 50)
                    .padding(.bottom, AppSpacing.lg)
                    
                    Button(action: {
                        showingAddCategory = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.accent2)
                    }
                    .padding(.top, 50)
                    .padding(.trailing, AppSpacing.lg)
                }

                if viewModel.categories.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: AppSpacing.md) {
                            ForEach(viewModel.categories) { category in
                                CategoryCard(
                                    category: category,
                                    itemCount: viewModel.getItemCount(for: category.id)
                                ) {
                                    selectedCategory = category
                                }
                                .contextMenu {
                                    Button {
                                        categoryToEdit = category
                                        showingEditCategory = true
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    
                                    Button(role: .destructive) {
                                        categoryToDelete = category
                                        showingDeleteAlert = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .opacity(viewModel.deletingCategoryID == category.id ? 0 : 1)
                                .scaleEffect(viewModel.deletingCategoryID == category.id ? 0.7 : 1.0)
                                .blur(radius: viewModel.deletingCategoryID == category.id ? 5 : 0)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.deletingCategoryID)
                            }
                        }
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadCategories()
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView(
                isPresented: $showingAddCategory,
                onSave: {
                    viewModel.loadCategories()
                }
            )
        }
        .onChange(of: showingAddCategory) { isShowing in
            if !isShowing {
                viewModel.loadCategories()
            }
        }
        .sheet(isPresented: $showingEditCategory) {
            if let category = categoryToEdit {
                AddCategoryView(
                    isPresented: $showingEditCategory,
                    editingCategory: category,
                    onSave: {
                        viewModel.loadCategories()
                    }
                )
            }
        }
        .onChange(of: showingEditCategory) { isShowing in
            if !isShowing {
                viewModel.loadCategories()
                categoryToEdit = nil
            }
        }
        .sheet(item: $selectedCategory) { category in
            CategoryDetailView(category: category)
        }
        .onChange(of: selectedCategory) { category in
            if category == nil {
                viewModel.loadCategories()
            }
        }
        .alert("Delete Category", isPresented: $showingDeleteAlert) {
            if let category = categoryToDelete, viewModel.canDeleteCategory(category) {
                Button("Cancel", role: .cancel) {
                    categoryToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    viewModel.deleteCategory(category)
                    categoryToDelete = nil
                }
            } else {
                Button("OK", role: .cancel) {
                    categoryToDelete = nil
                }
            }
        } message: {
            if let category = categoryToDelete {
                if !viewModel.canDeleteCategory(category) {
                    Text("You cannot delete the last category. Please create another category first.")
                } else {
                    let itemCount = viewModel.getItemCount(for: category.id)
                    if itemCount > 0 {
                        Text("This will delete '\(category.name)' and move \(itemCount) item\(itemCount == 1 ? "" : "s") to another category. This action cannot be undone.")
                    } else {
                        Text("This will permanently delete '\(category.name)'. This action cannot be undone.")
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            EmptyStateView(
                icon: "folder",
                title: "No categories",
                message: "Create your first category to get started"
            )
            .padding(.horizontal, AppSpacing.xl)
            Spacer()
        }
    }
}

struct CategoryDetailView: View {
    let category: Category
    @StateObject private var viewModel = ItemsViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedItem: InventoryItem?
    @State private var showingItemDetail = false
    @State private var showingEditCategory = false
    @State private var showingDeleteAlert = false
    
    private let categoryService = CategoryService.shared
    private let inventoryService = InventoryService.shared
    
    var canDelete: Bool {
        categoryService.getAllCategories().count > 1
    }

    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom header
                ZStack(alignment: .topTrailing) {
                    ScreenHeader(
                        title: category.name,
                        subtitle: "\(viewModel.filteredItems.count) item\(viewModel.filteredItems.count == 1 ? "" : "s")",
                        icon: category.iconName,
                        accentColor: category.color
                    )
                    .padding(.top, 50)
                    .padding(.bottom, AppSpacing.lg)
                    
                    HStack(spacing: AppSpacing.md) {
                        if canDelete {
                            Button(action: {
                                showingDeleteAlert = true
                            }) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.error)
                            }
                        }
                        
                        Button(action: {
                            showingEditCategory = true
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
                        if viewModel.filteredItems.isEmpty {
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
            viewModel.loadData()
            viewModel.selectedCategories = [category.id]
            viewModel.applyFiltersAndSort()
        }
        .sheet(item: $selectedItem) { item in
            ItemDetailView(
                item: item,
                onEdit: {},
                onDelete: {
                    viewModel.loadData()
                    viewModel.selectedCategories = [category.id]
                    viewModel.applyFiltersAndSort()
                }
            )
        }
        .onChange(of: selectedItem) { item in
            if item == nil {
                viewModel.loadData()
                viewModel.selectedCategories = [category.id]
                viewModel.applyFiltersAndSort()
            }
        }
        .sheet(isPresented: $showingEditCategory) {
            AddCategoryView(
                isPresented: $showingEditCategory,
                editingCategory: category,
                onSave: {
                    // Reload data after editing
                }
            )
        }
        .onChange(of: showingEditCategory) { isShowing in
            if !isShowing {
                viewModel.loadData()
                viewModel.selectedCategories = [category.id]
                viewModel.applyFiltersAndSort()
            }
        }
        .alert("Delete Category", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteCategory()
            }
        } message: {
            let itemCount = viewModel.filteredItems.count
            if itemCount > 0 {
                Text("This will delete '\(category.name)' and move \(itemCount) item\(itemCount == 1 ? "" : "s") to another category. This action cannot be undone.")
            } else {
                Text("This will permanently delete '\(category.name)'. This action cannot be undone.")
            }
        }
    }
    
    private func deleteCategory() {
        // Find another category to move items to
        let allCategories = categoryService.getAllCategories()
        if let otherCategory = categoryService.getOtherCategory(), otherCategory.id != category.id {
            categoryService.deleteCategory(category, moveItemsTo: otherCategory.id)
        } else if let firstOtherCategory = allCategories.first(where: { $0.id != category.id }) {
            categoryService.deleteCategory(category, moveItemsTo: firstOtherCategory.id)
        }
        
        HapticsService.shared.success()
        presentationMode.wrappedValue.dismiss()
    }
    
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    category.color.opacity(0.3),
                                    category.color.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: category.iconName)
                        .font(.system(size: 36))
                        .foregroundColor(category.color)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(viewModel.filteredItems.count)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(category.color)
                    
                    Text("item\(viewModel.filteredItems.count == 1 ? "" : "s")")
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
                .stroke(category.color.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Items")
                .font(.appTitle)
                .foregroundColor(.textPrimary)
            
            LazyVStack(spacing: AppSpacing.md) {
                ForEach(viewModel.filteredItems) { item in
                    Button(action: {
                        selectedItem = item
                        showingItemDetail = true
                        HapticsService.shared.selection()
                    }) {
                        CategoryItemRow(
                            item: item,
                            category: category
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
            Image(systemName: "archivebox")
                .font(.system(size: 48))
                .foregroundColor(.textQuaternary)
            
            Text("No items in this category")
                .font(.appHeadline)
                .foregroundColor(.textSecondary)
            
            Text("Add items and assign them to this category")
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
}

struct CategoryItemRow: View {
    let item: InventoryItem
    let category: Category
    
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
                
                if !item.location.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.textTertiary)
                        Text(item.location)
                            .font(.appCaption)
                            .foregroundColor(.textTertiary)
                            .lineLimit(1)
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

struct AddCategoryView: View {
    @Binding var isPresented: Bool
    let editingCategory: Category?
    let onSave: (() -> Void)?
    @State private var name: String = ""
    @State private var selectedIcon: String = "folder.fill"
    @State private var selectedColor: Color = .accent2

    private let categoryService = CategoryService.shared
    
    init(isPresented: Binding<Bool>, editingCategory: Category? = nil, onSave: (() -> Void)? = nil) {
        self._isPresented = isPresented
        self.editingCategory = editingCategory
        self.onSave = onSave
    }

    private let iconOptions = [
        "folder.fill", "house.fill", "car.fill", "briefcase.fill",
        "book.fill", "heart.fill", "star.fill", "music.note",
        "gamecontroller.fill", "camera.fill", "paintbrush.fill", "hammer.fill",
        "wrench.fill", "scissors", "leaf.fill", "flame.fill",
        "laptopcomputer", "bed.double.fill", "tshirt.fill", "fork.knife",
        "square.grid.2x2.fill", "cube.box.fill", "archivebox.fill", "tray.fill"
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
                        title: "Category Name",
                        placeholder: "Enter name",
                        text: $name,
                        icon: "tag.fill"
                    )

                    iconPickerSection

                    colorPickerSection

                    CustomButton(
                        title: editingCategory == nil ? "Create Category" : "Save Changes",
                        icon: "checkmark.circle.fill",
                        style: .primary
                    ) {
                        saveCategory()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.xl)
            }
            .background(Color.backgroundPrimary.ignoresSafeArea())
            .navigationTitle(editingCategory == nil ? "New Category" : "Edit Category")
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
            if let category = editingCategory {
                name = category.name
                selectedIcon = category.iconName
                selectedColor = category.color
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

            Text(name.isEmpty ? "Category Name" : name)
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

    private func saveCategory() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        if let editingCategory = editingCategory {
            // Update existing category
            var updatedCategory = editingCategory
            updatedCategory.name = trimmedName
            updatedCategory.iconName = selectedIcon
            updatedCategory.colorHex = selectedColor.toHex() ?? editingCategory.colorHex
            categoryService.updateCategory(updatedCategory)
        } else {
            // Create new category
            let newCategory = Category(
                name: trimmedName,
                iconName: selectedIcon,
                colorHex: selectedColor.toHex() ?? "#43A047",
                isDefault: false
            )
            categoryService.createCategory(newCategory)
        }
        
        HapticsService.shared.success()
        onSave?()
        isPresented = false
    }
}
