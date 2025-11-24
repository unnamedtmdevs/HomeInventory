import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.3
    
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
                        .opacity(opacity)
                }
            }
            .ignoresSafeArea()
            
            // Main content
            VStack(spacing: AppSpacing.xl) {
                Spacer()
                
                // Large decorative icon container
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.accent1.opacity(0.4),
                                    Color.accent4.opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 30,
                                endRadius: 80
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .opacity(isAnimating ? 0.6 : 0.8)
                    
                    // Main circle with gradient
                    Circle()
                        .fill(
                            AngularGradient(
                                colors: [Color.accent1, Color.accent4, Color.accent2, Color.accent1],
                                center: .center,
                                angle: .degrees(rotationAngle)
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: Color.accent1.opacity(0.6), radius: 30, x: 0, y: 15)
                        .scaleEffect(scale)
                    
                    // Inner circle
                    Circle()
                        .fill(Color.backgroundPrimary)
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "cube.box.fill")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.accent1, Color.accent4],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(scale)
                }
                
                VStack(spacing: AppSpacing.md) {
                    Text("DomInventory")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.textPrimary, Color.textSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(isAnimating ? 1 : 0.7)
                    
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.accent2)
                            .frame(width: 10, height: 10)
                            .scaleEffect(isAnimating ? 1.2 : 1.0)
                        
                        Text("Organize your world")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.textTertiary)
                            .opacity(isAnimating ? 1 : 0.6)
                    }
                }
                
                Spacer()
                
                // Loading indicator
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.accent1, Color.accent4],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 12, height: 12)
                            .scaleEffect(isAnimating ? 1.0 : 0.6)
                            .opacity(isAnimating ? 1.0 : 0.4)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                                value: isAnimating
                            )
                    }
                }
                .padding(.bottom, AppSpacing.xxl)
            }
        }
        .onAppear {
            // Start all animations
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                scale = 1.1
            }
            
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                opacity = 0.8
            }
        }
    }
}
