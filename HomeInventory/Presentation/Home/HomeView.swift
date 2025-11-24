import SwiftUI

// Note: Text tracking removed for iOS 15 compatibility
// Tracking can be added via custom fonts or UIKit if needed

// MARK: - Custom Shape for iOS 15+ compatibility
struct UnevenRoundedRectangle: Shape {
    var topLeadingRadius: CGFloat
    var bottomLeadingRadius: CGFloat
    var bottomTrailingRadius: CGFloat
    var topTrailingRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let tl = topLeadingRadius
        let bl = bottomLeadingRadius
        let br = bottomTrailingRadius
        let tr = topTrailingRadius
        
        path.move(to: CGPoint(x: tl, y: 0))
        path.addLine(to: CGPoint(x: rect.width - tr, y: 0))
        path.addQuadCurve(to: CGPoint(x: rect.width, y: tr), control: CGPoint(x: rect.width - tr/2, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - br))
        path.addQuadCurve(to: CGPoint(x: rect.width - br, y: rect.height), control: CGPoint(x: rect.width, y: rect.height - br/2))
        path.addLine(to: CGPoint(x: bl, y: rect.height))
        path.addQuadCurve(to: CGPoint(x: 0, y: rect.height - bl), control: CGPoint(x: bl/2, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addQuadCurve(to: CGPoint(x: tl, y: 0), control: CGPoint(x: 0, y: tl/2))
        path.closeSubpath()
        
        return path
    }
}

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Binding var selectedTab: TabItem
    @State private var showingAddItem = false
    @State private var showingSettings = false
    @State private var animateStats = false
    @State private var rotationAngle: Double = 0

    var body: some View {
        ZStack {
            // Animated background with multiple gradients
            ZStack {
                // Base gradient
                LinearGradient(
                    colors: [
                        Color.backgroundPrimary,
                        Color.backgroundSecondary,
                        Color(hex: "#0f1624") ?? Color.backgroundPrimary
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Animated decorative circles
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.accent1.opacity(0.15 - Double(index) * 0.05),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 200
                            )
                        )
                        .frame(width: 400, height: 400)
                        .offset(
                            x: index == 0 ? -100 : (index == 1 ? 150 : 0),
                            y: index == 0 ? -150 : (index == 1 ? 200 : -50)
                        )
                        .blur(radius: 40)
                        .rotationEffect(.degrees(rotationAngle + Double(index) * 45))
                }
            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    rotationAngle = 360
                }
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.xl) {
                    // Custom header with creative design
                    headerSection
                        .padding(.top, 50)
                        .padding(.bottom, AppSpacing.lg)

                    statisticsSection
                        .padding(.horizontal, AppSpacing.md)

                    recentItemsSection
                        .padding(.horizontal, AppSpacing.md)

                    categoriesSection
                        .padding(.horizontal, AppSpacing.md)

                    quickActionsSection
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.bottom, AppSpacing.xl)
                }
                .padding(.bottom, 120)
            }
        }
        .onAppear {
            viewModel.loadData()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateStats = true
            }
        }
        .onChange(of: selectedTab) { _ in
            // Reload data when returning to home tab
            if selectedTab == .home {
                viewModel.loadData()
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
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .onChange(of: showingSettings) { isShowing in
            if !isShowing {
                viewModel.loadData()
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Creative header with angled design
            ZStack(alignment: .leading) {
                // Decorative background shape
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 30,
                    bottomTrailingRadius: 30,
                    topTrailingRadius: 0
                )
                .fill(
                    LinearGradient(
                        colors: [
                            Color.accent1.opacity(0.2),
                            Color.accent4.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 120)
                .offset(x: -AppSpacing.lg)
                
                HStack(spacing: AppSpacing.md) {
                    // Large decorative icon container
                    ZStack {
                        // Outer glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.accent1.opacity(0.3),
                                        Color.accent4.opacity(0.1),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 50
                                )
                            )
                            .frame(width: 100, height: 100)
                            .blur(radius: 10)
                        
                        // Main circle with gradient
                        Circle()
                            .fill(
                                AngularGradient(
                                    colors: [Color.accent1, Color.accent4, Color.accent2, Color.accent1],
                                    center: .center,
                                    angle: .degrees(rotationAngle)
                                )
                            )
                            .frame(width: 70, height: 70)
                            .shadow(color: Color.accent1.opacity(0.5), radius: 20, x: 0, y: 10)
                        
                        // Inner circle
                        Circle()
                            .fill(Color.backgroundPrimary)
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "cube.box.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.accent1, Color.accent4],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .frame(width: 100)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Home")
                            .font(.system(size: UIScreen.main.bounds.width < 360 ? 28 : 32, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.textPrimary, Color.textSecondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.accent2)
                                .frame(width: 8, height: 8)
                            
                            Text("Organize your world")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.textTertiary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    
                    // Settings button
                    Button(action: {
                        showingSettings = true
                        HapticsService.shared.selection()
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.accent4.opacity(0.3),
                                            Color.accent1.opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                                .shadow(color: Color.accent4.opacity(0.4), radius: 10, x: 0, y: 4)
                            
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.accent4, Color.accent1],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .frame(width: 50)
                }
                .padding(.horizontal, AppSpacing.lg)
            }
            .padding(.horizontal, AppSpacing.lg)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    private var statisticsSection: some View {
        VStack(spacing: AppSpacing.lg) {
            // Section header with decorative line
            HStack(spacing: AppSpacing.md) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.accent1, Color.accent4],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 4, height: 24)
                    .cornerRadius(2)
                
                Text("QUICK STATS")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, AppSpacing.md)

            // Creative grid layout with equal sizes
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: AppSpacing.lg),
                    GridItem(.flexible(), spacing: AppSpacing.lg)
                ],
                alignment: .center,
                spacing: AppSpacing.lg,
                pinnedViews: []
            ) {
                StatCard(
                    title: "Total Items",
                    value: "\(viewModel.totalItems)",
                    icon: "archivebox.fill",
                    gradient: [Color.accent1, Color.accent1.opacity(0.6)],
                    offset: 0,
                    delay: 0.1,
                    isLarge: true,
                    animateStats: animateStats
                )

                StatCard(
                    title: "Categories",
                    value: "\(viewModel.totalCategories)",
                    icon: "square.grid.2x2.fill",
                    gradient: [Color.accent2, Color.accent2.opacity(0.6)],
                    offset: 0,
                    delay: 0.2,
                    isLarge: true,
                    animateStats: animateStats
                )

                StatCard(
                    title: "With Photos",
                    value: "\(viewModel.itemsWithPhotos)",
                    icon: "camera.fill",
                    gradient: [Color.accent3, Color.accent3.opacity(0.6)],
                    offset: 0,
                    delay: 0.3,
                    isLarge: true,
                    animateStats: animateStats
                )

                StatCard(
                    title: "Most Common",
                    value: viewModel.mostCommonCategory?.name ?? "None",
                    icon: "chart.bar.fill",
                    gradient: [Color.accent4, Color.accent4.opacity(0.6)],
                    offset: 0,
                    delay: 0.4,
                    isLarge: true,
                    animateStats: animateStats
                )
            }
            .padding(.top, AppSpacing.sm)
            .padding(.horizontal, AppSpacing.xs)
        }
    }

    private var recentItemsSection: some View {
        VStack(spacing: AppSpacing.lg) {
            // Section header with icon
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.accent1.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "clock.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.accent1)
                }
                
                Text("RECENT ADDITIONS")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)

                Spacer()

                Button(action: {
                    HapticsService.shared.selection()
                    selectedTab = .items
                }) {
                    HStack(spacing: 4) {
                        Text("VIEW ALL")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.accent1)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.accent1)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)

            if viewModel.recentItems.isEmpty {
                EmptyStateView(
                    icon: "archivebox",
                    title: "No items yet",
                    message: "Add your first item to get started"
                )
            } else {
                VStack(spacing: AppSpacing.lg) {
                    ForEach(Array(viewModel.recentItems.enumerated()), id: \.element.id) { index, item in
                        RecentItemRow(
                            item: item,
                            category: viewModel.getCategory(for: item),
                            index: index
                        )
                        .opacity(animateStats ? 1 : 0)
                        .scaleEffect(animateStats ? 1 : 0.95)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8)
                            .delay(Double(index) * 0.1),
                            value: animateStats
                        )
                    }
                }
                .padding(.top, AppSpacing.sm)
            }
        }
    }

    private var categoriesSection: some View {
        VStack(spacing: AppSpacing.lg) {
            // Section header
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.accent2.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.accent2)
                }
                
                Text("CATEGORIES")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)

                Spacer()

                Button(action: {
                    HapticsService.shared.selection()
                    selectedTab = .categories
                }) {
                    HStack(spacing: 4) {
                        Text("VIEW ALL")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.accent2)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.accent2)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)

            if viewModel.categories.isEmpty {
                EmptyStateView(
                    icon: "folder",
                    title: "No categories",
                    message: "Create your first category"
                )
            } else {
            ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.lg) {
                        ForEach(Array(viewModel.categories.prefix(6).enumerated()), id: \.element.id) { index, category in
                        CategoryQuickAccessCard(
                            category: category,
                                itemCount: viewModel.getItemCount(for: category.id),
                                index: index
                        ) {
                                HapticsService.shared.selection()
                            selectedTab = .categories
                            }
                            .opacity(animateStats ? 1 : 0)
                            .scaleEffect(animateStats ? 1 : 0.9)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.8)
                                .delay(Double(index) * 0.1),
                                value: animateStats
                            )
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                }
                .padding(.top, AppSpacing.sm)
            }
        }
    }

    private var quickActionsSection: some View {
        VStack(spacing: AppSpacing.lg) {
            // Section header
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.accent3.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.accent3)
                }
                
                Text("QUICK ACTIONS")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, AppSpacing.md)

            VStack(spacing: AppSpacing.md) {
                // Large primary action button with creative design
                Button(action: {
                    HapticsService.shared.medium()
                    showingAddItem = true
                }) {
                    ZStack {
                        // Background with gradient
                        UnevenRoundedRectangle(
                            topLeadingRadius: 20,
                            bottomLeadingRadius: 20,
                            bottomTrailingRadius: 20,
                            topTrailingRadius: 20
                        )
                        .fill(
                            LinearGradient(
                                colors: [Color.accent1, Color.accent4, Color.accent2],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 70)
                        
                        // Decorative elements
                        HStack {
                            Spacer()
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 100, height: 100)
                                .offset(x: 30, y: -20)
                                .blur(radius: 20)
                        }
                        
                        HStack(spacing: AppSpacing.lg) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.25))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("ADD NEW ITEM")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    }
                    .shadow(color: Color.accent1.opacity(0.5), radius: 20, x: 0, y: 10)
                }
                .buttonStyle(ScaleButtonStyle())

                // Secondary actions in creative layout
                HStack(spacing: AppSpacing.md) {
                    ActionButton(
                    icon: "magnifyingglass",
                        title: "SEARCH",
                        gradient: [Color.accent2, Color.accent2.opacity(0.7)],
                        action: {
                            HapticsService.shared.light()
                    selectedTab = .search
                        }
                    )
                    
                    ActionButton(
                        icon: "list.bullet",
                        title: "ALL ITEMS",
                        gradient: [Color.accent3, Color.accent3.opacity(0.7)],
                        action: {
                            HapticsService.shared.light()
                            selectedTab = .items
                        }
                    )
                }
            }
        }
        .padding(.bottom, AppSpacing.lg)
    }
}

// MARK: - StatCard with creative design
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: [Color]
    let offset: CGFloat
    let delay: Double
    let isLarge: Bool
    let animateStats: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background with creative shape
            UnevenRoundedRectangle(
                topLeadingRadius: isLarge ? 25 : 20,
                bottomLeadingRadius: isLarge ? 25 : 20,
                bottomTrailingRadius: isLarge ? 25 : 20,
                topTrailingRadius: isLarge ? 25 : 20
            )
            .fill(
                LinearGradient(
                    colors: [
                        gradient[0].opacity(0.2),
                        gradient[1].opacity(0.1),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                UnevenRoundedRectangle(
                    topLeadingRadius: isLarge ? 25 : 20,
                    bottomLeadingRadius: isLarge ? 25 : 20,
                    bottomTrailingRadius: isLarge ? 25 : 20,
                    topTrailingRadius: isLarge ? 25 : 20
                )
                .stroke(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
            )
            
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                // Icon with creative background
                ZStack {
                    Circle()
                        .fill(
                            AngularGradient(
                                colors: gradient + [gradient[0]],
                                center: .center,
                                angle: .degrees(45)
                            )
                        )
                        .frame(width: isLarge ? 50 : 40, height: isLarge ? 50 : 40)
                    
            Image(systemName: icon)
                        .font(.system(size: isLarge ? 22 : 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(.system(size: isLarge ? 32 : 26, weight: .black, design: .rounded))
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.6)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(title.uppercased())
                        .font(.system(size: isLarge ? 12 : 10, weight: .bold, design: .rounded))
                        .foregroundColor(.textTertiary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(isLarge ? AppSpacing.lg : AppSpacing.md)
        }
        .frame(height: isLarge ? 160 : 130)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: isLarge ? 25 : 20,
                bottomLeadingRadius: isLarge ? 25 : 20,
                bottomTrailingRadius: isLarge ? 25 : 20,
                topTrailingRadius: isLarge ? 25 : 20
            )
        )
        .opacity(animateStats ? 1 : 0)
        .scaleEffect(animateStats ? 1 : 0.9)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.8)
            .delay(delay),
            value: animateStats
        )
    }
}

// MARK: - RecentItemRow with asymmetric design
struct RecentItemRow: View {
    let item: InventoryItem
    let category: Category?
    let index: Int

    var body: some View {
        HStack(spacing: 0) {
            // Image with creative border
            ZStack {
            if let firstPhotoID = item.photoIDs.first,
               let image = ImageService.shared.loadPhoto(firstPhotoID) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 20,
                                bottomLeadingRadius: index % 2 == 0 ? 0 : 20,
                                bottomTrailingRadius: 20,
                                topTrailingRadius: index % 2 == 0 ? 20 : 0
                            )
                        )
            } else {
                ZStack {
                        LinearGradient(
                            colors: [
                                Color.backgroundSecondary.opacity(0.8),
                                Color.backgroundSecondary.opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                    Image(systemName: "photo")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.textTertiary)
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 20,
                            bottomLeadingRadius: index % 2 == 0 ? 0 : 20,
                            bottomTrailingRadius: 20,
                            topTrailingRadius: index % 2 == 0 ? 20 : 0
                        )
                    )
                }
            }
            .overlay(
                UnevenRoundedRectangle(
                    topLeadingRadius: 20,
                    bottomLeadingRadius: index % 2 == 0 ? 0 : 20,
                    bottomTrailingRadius: 20,
                    topTrailingRadius: index % 2 == 0 ? 20 : 0
                )
                .stroke(
                    LinearGradient(
                        colors: [
                            (item.colorHex.isEmpty ? (category?.color ?? Color.accent1) : item.color).opacity(0.8),
                            (item.colorHex.isEmpty ? (category?.color ?? Color.accent1) : item.color).opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
            )

            // Content with asymmetric padding
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(item.name.uppercased())
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                    
                    if item.isImportant {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.accent1)
                    }
                }

                if let category = category {
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(category.color)
                            .frame(width: 4, height: 16)
                        
                        Text(category.name.uppercased())
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(category.color)
                    }
                }

                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 11))
                        .foregroundColor(.textQuaternary)

                Text(item.dateAdded.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textQuaternary)
                }
            }
            .padding(.leading, AppSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.textTertiary)
                .padding(.trailing, AppSpacing.md)
        }
        .background(
            ZStack {
                Color.backgroundCard.opacity(0.7)
                
                LinearGradient(
                    colors: [
                        (item.colorHex.isEmpty ? (category?.color ?? Color.accent1) : item.color).opacity(0.1),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        )
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: index % 2 == 0 ? 25 : 0,
                bottomTrailingRadius: 25,
                topTrailingRadius: index % 2 == 0 ? 0 : 25
            )
        )
        .overlay(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: index % 2 == 0 ? 25 : 0,
                bottomTrailingRadius: 25,
                topTrailingRadius: index % 2 == 0 ? 0 : 25
            )
            .stroke(
                LinearGradient(
                    colors: [
                        Color.borderPrimary.opacity(0.4),
                        Color.borderPrimary.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.5
            )
        )
        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
        .padding(.vertical, AppSpacing.xs)
    }
}

// MARK: - CategoryQuickAccessCard with unique shape
struct CategoryQuickAccessCard: View {
    let category: Category
    let itemCount: Int
    let index: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: AppSpacing.md) {
                ZStack {
                    // Creative background shape
                    UnevenRoundedRectangle(
                        topLeadingRadius: 20,
                        bottomLeadingRadius: 20,
                        bottomTrailingRadius: 20,
                        topTrailingRadius: 20
                    )
                    .fill(
                        AngularGradient(
                            colors: [
                                category.color.opacity(0.3),
                                category.color.opacity(0.15),
                                category.color.opacity(0.05),
                                category.color.opacity(0.15)
                            ],
                            center: .center,
                            angle: .degrees(Double(index) * 45)
                        )
                    )
                    .frame(width: 70, height: 70)
                    .shadow(color: category.color.opacity(0.4), radius: 12, x: 0, y: 6)

                    Image(systemName: category.iconName)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(category.color)
                }

                VStack(spacing: 6) {
                    Text(category.name.uppercased())
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Text("\(itemCount)")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(category.color)
                        
                        Text(itemCount == 1 ? "item" : "items")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.textTertiary)
                    }
                }
            }
            .frame(width: 120)
            .padding(.vertical, AppSpacing.lg)
            .padding(.horizontal, AppSpacing.sm)
            .background(
                ZStack {
                    Color.backgroundCard.opacity(0.7)
                    
                    LinearGradient(
                        colors: [
                            category.color.opacity(0.12),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            )
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 25,
                    bottomLeadingRadius: 25,
                    bottomTrailingRadius: 25,
                    topTrailingRadius: 25
                )
            )
            .overlay(
                UnevenRoundedRectangle(
                    topLeadingRadius: 25,
                    bottomLeadingRadius: 25,
                    bottomTrailingRadius: 25,
                    topTrailingRadius: 25
                )
                .stroke(
                    LinearGradient(
                        colors: [
                            category.color.opacity(0.6),
                            category.color.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
            )
            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - ActionButton component
struct ActionButton: View {
    let icon: String
    let title: String
    let gradient: [Color]
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .shadow(color: gradient[0].opacity(0.4), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.lg)
            .background(
                ZStack {
                    Color.backgroundCard.opacity(0.6)
                    
                    LinearGradient(
                        colors: [
                            gradient[0].opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            )
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 20,
                    bottomLeadingRadius: 20,
                    bottomTrailingRadius: 20,
                    topTrailingRadius: 20
                )
            )
            .overlay(
                UnevenRoundedRectangle(
                    topLeadingRadius: 20,
                    bottomLeadingRadius: 20,
                    bottomTrailingRadius: 20,
                    topTrailingRadius: 20
                )
                .stroke(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - EmptyStateView with creative design
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            ZStack {
                // Multiple circles for depth
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.accent1.opacity(0.3 - Double(index) * 0.1),
                                    Color.accent4.opacity(0.2 - Double(index) * 0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 100 + CGFloat(index) * 20, height: 100 + CGFloat(index) * 20)
                }
                
            Image(systemName: icon)
                    .font(.system(size: 50, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.accent1, Color.accent4],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: AppSpacing.sm) {
                Text(title.uppercased())
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.textPrimary)

                Text(message)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.md)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
        .background(
            ZStack {
                Color.backgroundCard.opacity(0.5)
                
                LinearGradient(
                    colors: [
                        Color.accent1.opacity(0.08),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 30,
                bottomLeadingRadius: 30,
                bottomTrailingRadius: 30,
                topTrailingRadius: 30
            )
        )
        .overlay(
            UnevenRoundedRectangle(
                topLeadingRadius: 30,
                bottomLeadingRadius: 30,
                bottomTrailingRadius: 30,
                topTrailingRadius: 30
            )
            .stroke(
                LinearGradient(
                    colors: [
                        Color.borderPrimary.opacity(0.4),
                        Color.borderPrimary.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.5
            )
        )
    }
}
