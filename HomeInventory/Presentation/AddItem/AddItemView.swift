import SwiftUI
import PhotosUI

struct AddItemView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel: AddItemViewModel
    @State private var showingSaveAndAddAnother = false
    @State private var showingImageSourcePicker = false
    @State private var showingPermissionAlert = false
    @State private var permissionAlertMessage = ""
    @State private var permissionType: PermissionType = .camera
    
    enum PermissionType {
        case camera
        case photoLibrary
    }

    init(isPresented: Binding<Bool>, editingItem: InventoryItem? = nil) {
        self._isPresented = isPresented
        self._viewModel = StateObject(wrappedValue: AddItemViewModel(editingItem: editingItem))
    }

    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom header
                ZStack(alignment: .topTrailing) {
                    ScreenHeader(
                        title: viewModel.editingItem == nil ? "Add Item" : "Edit Item",
                        subtitle: viewModel.editingItem == nil ? "Create new item" : "Update item details",
                        icon: "plus.circle.fill",
                        accentColor: .accent1
                    )
                    .padding(.top, 50)
                    .padding(.bottom, AppSpacing.lg)
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.textTertiary)
                    }
                    .padding(.top, 50)
                    .padding(.trailing, AppSpacing.lg)
                }

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        photoSection
                            .padding(.horizontal, AppSpacing.md)

                        basicInfoSection
                            .padding(.horizontal, AppSpacing.md)

                        additionalDetailsSection
                            .padding(.horizontal, AppSpacing.md)

                        actionButtons
                            .padding(.horizontal, AppSpacing.md)
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .confirmationDialog("Add Photo", isPresented: $showingImageSourcePicker) {
            Button("Camera") {
                HapticsService.shared.light()
                requestCameraPermission()
            }
            Button("Photo Library") {
                HapticsService.shared.light()
                requestPhotoLibraryPermission()
            }
            Button("Cancel", role: .cancel) { }
        }
        .alert("Permission Required", isPresented: $showingPermissionAlert) {
            Button("Settings") {
                PermissionService.shared.openSettings()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(permissionAlertMessage)
        }
        .sheet(isPresented: $viewModel.showingImagePicker) {
            ImagePicker(image: Binding(
                get: { nil },
                set: { image in
                    if let image = image {
                        viewModel.addPhoto(image)
                    }
                }
            ), sourceType: .photoLibrary)
        }
        .sheet(isPresented: $viewModel.showingCamera) {
            ImagePicker(image: Binding(
                get: { nil },
                set: { image in
                    if let image = image {
                        viewModel.addPhoto(image)
                    }
                }
            ), sourceType: .camera)
        }
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Photos")
                .font(.appTitle)
                .foregroundColor(.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    Button(action: {
                        HapticsService.shared.medium()
                        showingImageSourcePicker = true
                    }) {
                        ZStack {
                            LinearGradient(
                                colors: [
                                    Color.accent2.opacity(0.2),
                                    Color.accent1.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            VStack(spacing: AppSpacing.sm) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.accent2, Color.accent1],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                Text("Add Photo")
                                    .font(.appCaption)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        .frame(width: 120, height: 120)
                        .cornerRadius(AppSpacing.radiusLarge)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                .foregroundColor(.accent2.opacity(0.5))
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .contentShape(Rectangle())

                    ForEach(Array(viewModel.photos.enumerated()), id: \.offset) { index, photo in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: photo)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipped()
                                .cornerRadius(AppSpacing.radiusLarge)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                                        .stroke(Color.borderPrimary, lineWidth: 1)
                                )

                            Button(action: {
                                viewModel.removePhoto(at: index)
                                HapticsService.shared.light()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.error)
                                    .background(Color.white.clipShape(Circle()))
                            }
                            .offset(x: 8, y: -8)
                        }
                    }
                }
            }

            Text("Up to \(StorageService.shared.loadAppSettings().maxPhotosPerItem) photos")
                .font(.appCaption)
                .foregroundColor(.textTertiary)
        }
        .padding(AppSpacing.md)
        .background(Color.backgroundCard)
        .cornerRadius(AppSpacing.radiusLarge)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                .stroke(Color.borderPrimary, lineWidth: 1)
        )
    }

    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Basic Information")
                .font(.appTitle)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: AppSpacing.md) {
                CustomTextField(
                    title: "Name *",
                    placeholder: "Item name",
                    text: $viewModel.name,
                    icon: "tag.fill"
                )

                CustomTextEditor(
                    title: "Description",
                    placeholder: "Add a description...",
                    text: $viewModel.itemDescription,
                    minHeight: 80
                )

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Category *")
                        .font(.appBody)
                        .foregroundColor(.textSecondary)

                    Button(action: {
                        viewModel.showingCategoryPicker = true
                    }) {
                        HStack {
                            if let category = viewModel.selectedCategory {
                                Image(systemName: category.iconName)
                                    .foregroundColor(category.color)
                                Text(category.name)
                                    .foregroundColor(.textPrimary)
                            } else {
                                Text("Select category")
                                    .foregroundColor(.textTertiary)
                            }
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.textTertiary)
                        }
                        .font(.appBody)
                        .padding(.horizontal, AppSpacing.md)
                        .frame(height: AppSpacing.inputHeight)
                        .background(Color.backgroundInput)
                        .cornerRadius(AppSpacing.inputCornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppSpacing.inputCornerRadius)
                                .stroke(Color.borderPrimary, lineWidth: 1)
                        )
                    }
                    .sheet(isPresented: $viewModel.showingCategoryPicker) {
                        CategoryPickerView(
                            categories: viewModel.categories,
                            selectedCategory: $viewModel.selectedCategory
                        )
                    }
                }

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Location")
                        .font(.appBody)
                        .foregroundColor(.textSecondary)

                    Button(action: {
                        viewModel.showingLocationPicker = true
                    }) {
                        HStack {
                            if let location = viewModel.locations.first(where: { $0.name == viewModel.location }) {
                                Image(systemName: location.iconName)
                                    .foregroundColor(location.color)
                                Text(location.name)
                                    .foregroundColor(.textPrimary)
                            } else if !viewModel.location.isEmpty {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.textTertiary)
                                Text(viewModel.location)
                                    .foregroundColor(.textPrimary)
                            } else {
                                Text("Select location (optional)")
                                    .foregroundColor(.textTertiary)
                            }
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.textTertiary)
                        }
                        .font(.appBody)
                        .padding(.horizontal, AppSpacing.md)
                        .frame(height: AppSpacing.inputHeight)
                        .background(Color.backgroundInput)
                        .cornerRadius(AppSpacing.inputCornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppSpacing.inputCornerRadius)
                                .stroke(Color.borderPrimary, lineWidth: 1)
                        )
                    }
                    .sheet(isPresented: $viewModel.showingLocationPicker) {
                        LocationPickerView(
                            locations: viewModel.locations,
                            selectedLocationName: $viewModel.location
                        )
                    }
                }

                Toggle(isOn: $viewModel.isImportant) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.accent1)
                        Text("Mark as Important")
                            .font(.appBody)
                            .foregroundColor(.textPrimary)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .accent1))
                
                // Color picker
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Item Color")
                        .font(.appBody)
                        .foregroundColor(.textSecondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.sm) {
                            ForEach(itemColorOptions, id: \.self) { color in
                                Button(action: {
                                    viewModel.selectedColor = color
                                    HapticsService.shared.light()
                                }) {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Circle()
                                                .stroke(viewModel.selectedColor == color ? Color.white : Color.clear, lineWidth: 2)
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(Color.borderPrimary, lineWidth: 1)
                                        )
                                        .shadow(color: viewModel.selectedColor == color ? color.opacity(0.5) : .clear, radius: 4, x: 0, y: 2)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 4)
                    }
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
    
    private var itemColorOptions: [Color] {
        [
            .accent1, .accent2, .accent3, .accent4, .accent5, .accent6,
            .red, .orange, .yellow, .green, .blue, .purple, .pink,
            .cyan, .mint, .teal, .indigo
        ]
    }

    private var additionalDetailsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Additional Details")
                .font(.appTitle)
                .foregroundColor(.textPrimary)

            VStack(spacing: AppSpacing.md) {
                Toggle(isOn: $viewModel.hasDate) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.accent3)
                        Text("Purchase Date")
                            .font(.appBody)
                            .foregroundColor(.textPrimary)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .accent3))
                .padding(AppSpacing.md)
                .background(Color.backgroundSecondary)
                .cornerRadius(AppSpacing.radiusMedium)

                if viewModel.hasDate {
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { viewModel.purchaseDate ?? Date() },
                            set: { viewModel.purchaseDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding(AppSpacing.md)
                    .background(Color.backgroundSecondary)
                    .cornerRadius(AppSpacing.radiusMedium)
                }

                CustomTextField(
                    title: "Purchase Price",
                    placeholder: "0.00",
                    text: $viewModel.purchasePrice,
                    icon: "dollarsign.circle.fill"
                )
                .keyboardType(.decimalPad)

                CustomTextField(
                    title: "Serial Number",
                    placeholder: "Serial number",
                    text: $viewModel.serialNumber,
                    icon: "number.circle.fill"
                )

                CustomTextField(
                    title: "Warranty Info",
                    placeholder: "Warranty information",
                    text: $viewModel.warrantyInfo,
                    icon: "shield.fill"
                )

                CustomTextEditor(
                    title: "Notes",
                    placeholder: "Additional notes...",
                    text: $viewModel.notes,
                    minHeight: 100
                )
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

    private var actionButtons: some View {
        VStack(spacing: AppSpacing.sm) {
            CustomButton(
                title: viewModel.editingItem == nil ? "Save Item" : "Update Item",
                icon: "checkmark.circle.fill",
                style: .primary
            ) {
                if viewModel.saveItem() {
                    isPresented = false
                }
            }
            .disabled(!viewModel.canSave())
            .opacity(viewModel.canSave() ? 1.0 : 0.6)

            if viewModel.editingItem == nil {
                CustomButton(
                    title: "Save & Add Another",
                    icon: "plus.circle.fill",
                    style: .secondary
                ) {
                    if viewModel.saveItem() {
                        viewModel.resetForm()
                    }
                }
                .disabled(!viewModel.canSave())
                .opacity(viewModel.canSave() ? 1.0 : 0.6)
            }
        }
    }
    
    // MARK: - Permission Handling
    private func requestCameraPermission() {
        let permissionService = PermissionService.shared
        let status = permissionService.checkCameraPermission()
        
        switch status {
        case .authorized:
            viewModel.showingCamera = true
        case .notDetermined:
            permissionService.requestCameraPermission { granted in
                if granted {
                    viewModel.showingCamera = true
                } else {
                    showPermissionDeniedAlert(for: .camera)
                }
            }
        case .denied, .restricted:
            showPermissionDeniedAlert(for: .camera)
        @unknown default:
            showPermissionDeniedAlert(for: .camera)
        }
    }
    
    private func requestPhotoLibraryPermission() {
        let permissionService = PermissionService.shared
        let status = permissionService.checkPhotoLibraryPermission()
        
        switch status {
        case .authorized, .limited:
            viewModel.showingImagePicker = true
        case .notDetermined:
            permissionService.requestPhotoLibraryPermission { granted in
                if granted {
                    viewModel.showingImagePicker = true
                } else {
                    showPermissionDeniedAlert(for: .photoLibrary)
                }
            }
        case .denied, .restricted:
            showPermissionDeniedAlert(for: .photoLibrary)
        @unknown default:
            showPermissionDeniedAlert(for: .photoLibrary)
        }
    }
    
    private func showPermissionDeniedAlert(for type: PermissionType) {
        permissionType = type
        switch type {
        case .camera:
            permissionAlertMessage = "Camera access is required to take photos. Please enable it in Settings."
        case .photoLibrary:
            permissionAlertMessage = "Photo library access is required to select photos. Please enable it in Settings."
        }
        showingPermissionAlert = true
    }
}

struct CategoryPickerView: View {
    let categories: [Category]
    @Binding var selectedCategory: Category?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom header
                ZStack(alignment: .topTrailing) {
                    ScreenHeader(
                        title: "Select Category",
                        subtitle: "Choose a category",
                        icon: "folder.fill",
                        accentColor: .accent2
                    )
                    .padding(.top, 50)
                    .padding(.bottom, AppSpacing.lg)
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.textTertiary)
                    }
                    .padding(.top, 50)
                    .padding(.trailing, AppSpacing.lg)
                }

                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: AppSpacing.md) {
                        ForEach(categories) { category in
                            CategoryPickerCard(
                                category: category,
                                isSelected: selectedCategory?.id == category.id
                            ) {
                                selectedCategory = category
                                HapticsService.shared.selection()
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

struct CategoryPickerCard: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(category.color.opacity(isSelected ? 0.3 : 0.15))
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: category.iconName)
                        .font(.system(size: 32))
                        .foregroundColor(category.color)
                    
                    if isSelected {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        category.color.opacity(0.4),
                                        category.color.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                            .overlay(
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                            )
                    }
                }
                
                VStack(spacing: 4) {
                    Text(category.name)
                        .font(.appHeadline)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.md)
            .background(Color.backgroundCard)
            .cornerRadius(AppSpacing.radiusLarge)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                    .stroke(
                        isSelected ? category.color.opacity(0.6) : Color.borderPrimary,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? category.color.opacity(0.3) : .clear,
                radius: isSelected ? 8 : 0,
                x: 0,
                y: isSelected ? 4 : 0
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
