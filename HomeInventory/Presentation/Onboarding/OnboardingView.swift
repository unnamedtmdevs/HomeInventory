import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "cube.box.fill",
            title: "Welcome",
            description: "Organize your belongings with ease. Track everything you own in one beautiful place.",
            accentColor: .accent1
        ),
        OnboardingPage(
            icon: "square.grid.2x2.fill",
            title: "Manage Items",
            description: "Add items with photos, descriptions, and details. Keep track of what you have and where it is.",
            accentColor: .accent2
        ),
        OnboardingPage(
            icon: "folder.fill",
            title: "Organize by Category",
            description: "Create custom categories and organize your items by type. Find what you need instantly.",
            accentColor: .accent3
        ),
        OnboardingPage(
            icon: "mappin.circle.fill",
            title: "Track Locations",
            description: "Assign locations to your items. Know exactly where everything is stored in your home.",
            accentColor: .accent4
        ),
        OnboardingPage(
            icon: "magnifyingglass",
            title: "Search & Filter",
            description: "Quickly find any item with powerful search and filtering options. Your inventory at your fingertips.",
            accentColor: .accent5
        )
    ]
    
    var body: some View {
        ZStack {
            // Animated background
            ZStack {
                LinearGradient(
                    colors: [
                        Color.backgroundPrimary,
                        Color.backgroundSecondary,
                        Color(hex: "#0f1624") ?? Color.backgroundPrimary
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Decorative circles
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
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .indexViewStyle(.page(backgroundDisplayMode: .never))
                
                // Page indicators and button
                VStack(spacing: AppSpacing.lg) {
                    // Page indicators
                    HStack(spacing: AppSpacing.sm) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? pages[index].accentColor : Color.textTertiary.opacity(0.3))
                                .frame(width: currentPage == index ? 12 : 8, height: currentPage == index ? 12 : 8)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                        }
                    }
                    .padding(.bottom, AppSpacing.md)
                    
                    // Action button
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                            HapticsService.shared.selection()
                        } else {
                            completeOnboarding()
                        }
                    }) {
                        HStack(spacing: AppSpacing.sm) {
                            Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                            
                            Image(systemName: currentPage < pages.count - 1 ? "arrow.right" : "checkmark.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(
                            LinearGradient(
                                colors: [
                                    pages[currentPage].accentColor,
                                    pages[currentPage].accentColor.opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(AppSpacing.radiusLarge)
                        .shadow(color: pages[currentPage].accentColor.opacity(0.4), radius: 12, x: 0, y: 6)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.bottom, AppSpacing.xxl)
                }
            }
        }
    }
    
    private func completeOnboarding() {
        HapticsService.shared.success()
        withAnimation {
            isPresented = false
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let accentColor: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var rotationAngle: Double = 0
    @State private var scale: CGFloat = 0.9
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let isIPad = width > 500
            let isCompactWidth = width < 360
            let iconSize: CGFloat = isIPad ? 120 : (isCompactWidth ? 95 : 105)
            let titleSize: CGFloat = isIPad ? 42 : (isCompactWidth ? 34 : 36)
            let descriptionSize: CGFloat = isIPad ? 20 : (isCompactWidth ? 17 : 18)
            let horizontalPadding: CGFloat = isCompactWidth ? AppSpacing.md : AppSpacing.xl
            let topPadding: CGFloat = isIPad ? 100 : (isCompactWidth ? 60 : 80)
            let bottomPadding: CGFloat = isIPad ? 200 : (isCompactWidth ? 130 : 150)
            
            VStack(spacing: AppSpacing.xl) {
                Spacer()
                
                // Icon container
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    page.accentColor.opacity(0.3),
                                    page.accentColor.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 60
                            )
                        )
                        .frame(width: iconSize + 60, height: iconSize + 60)
                        .blur(radius: 15)
                    
                    // Main circle with gradient
                    Circle()
                        .fill(
                            AngularGradient(
                                colors: [
                                    page.accentColor,
                                    page.accentColor.opacity(0.7),
                                    page.accentColor.opacity(0.5),
                                    page.accentColor
                                ],
                                center: .center,
                                angle: .degrees(rotationAngle)
                            )
                        )
                        .frame(width: iconSize, height: iconSize)
                        .shadow(color: page.accentColor.opacity(0.5), radius: 25, x: 0, y: 12)
                        .scaleEffect(scale)
                    
                    // Inner circle
                    Circle()
                        .fill(Color.backgroundPrimary)
                        .frame(width: iconSize * 0.7, height: iconSize * 0.7)
                    
                    Image(systemName: page.icon)
                        .font(.system(size: iconSize * 0.4, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [page.accentColor, page.accentColor.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(scale)
                }
                
                // Text content
                VStack(spacing: AppSpacing.md) {
                    Text(page.title)
                        .font(.system(size: titleSize, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.textPrimary, Color.textSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .allowsTightening(false)
                        .fixedSize(horizontal: false, vertical: true)
                        .layoutPriority(1)
                        .padding(.horizontal, horizontalPadding)

                    Text(page.description)
                        .font(.system(size: descriptionSize, weight: .medium, design: .rounded))
                        .foregroundColor(.textTertiary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .lineLimit(nil)
                        .allowsTightening(false)
                        .fixedSize(horizontal: false, vertical: true)
                        .layoutPriority(0.9)
                        .padding(.horizontal, horizontalPadding)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, topPadding)
            .padding(.bottom, bottomPadding)
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                scale = 1.0
            }
        }
    }
}

