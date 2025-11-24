import SwiftUI

struct ScreenHeader: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    @State private var rotationAngle: Double = 0
    
    var body: some View {
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
                            accentColor.opacity(0.2),
                            accentColor.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 100)
                .offset(x: -AppSpacing.lg)
                
                HStack(spacing: AppSpacing.md) {
                    // Decorative icon container
                    ZStack {
                        // Outer glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        accentColor.opacity(0.3),
                                        accentColor.opacity(0.1),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 15,
                                    endRadius: 35
                                )
                            )
                            .frame(width: 70, height: 70)
                            .blur(radius: 8)
                        
                        // Main circle with gradient
                        Circle()
                            .fill(
                                AngularGradient(
                                    colors: [accentColor, accentColor.opacity(0.7), accentColor.opacity(0.5), accentColor],
                                    center: .center,
                                    angle: .degrees(rotationAngle)
                                )
                            )
                            .frame(width: 50, height: 50)
                            .shadow(color: accentColor.opacity(0.5), radius: 15, x: 0, y: 8)
                        
                        // Inner circle
                        Circle()
                            .fill(Color.backgroundPrimary)
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: icon)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [accentColor, accentColor.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .frame(width: 70)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title.uppercased())
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.textPrimary, Color.textSecondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(accentColor)
                                .frame(width: 8, height: 8)
                            
                            Text(subtitle)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.textTertiary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, AppSpacing.lg)
            }
            .padding(.horizontal, AppSpacing.lg)
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}

