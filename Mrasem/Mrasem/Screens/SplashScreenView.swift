import SwiftUI

/// S-001: Splash Screen
/// Dark brown background, Mrasem Arabic logo centered, white bottom decorative icons
struct SplashScreenView: View {
    @State private var bottomOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark brown background (#31231B) per Figma
                Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Full logo group: Arabic calligraphy + Mrasem + Exclusively Saudi + Est.2018
                    Image("mrasem-logo")
                        .resizable()
                        .renderingMode(.original)
                        .interpolation(.high)
                        .antialiased(true)
                        .scaledToFit()
                        .frame(width: 262, height: 137)
                    
                    Spacer()
                    
                    // Bottom Decorative Patterns — white icons on dark background
                    ScrollingIconsView(offset: $bottomOffset, direction: .right)
                        .frame(height: 59)
                        .padding(.horizontal, 5)
                        .padding(.bottom, 12)
                }
            }
            .onAppear {
                startAnimations(screenWidth: geometry.size.width)
            }
        }
        .ignoresSafeArea()
    }
    
    private func startAnimations(screenWidth: CGFloat) {
        withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
            bottomOffset = screenWidth
        }
    }
}

/// Scrolling icons view with infinite loop effect
struct ScrollingIconsView: View {
    @Binding var offset: CGFloat
    let direction: ScrollDirection
    
    enum ScrollDirection {
        case left, right
    }
    
    var body: some View {
        GeometryReader { geometry in
            let iconWidth = geometry.size.width
            
            HStack(spacing: 0) {
                ForEach(0..<2, id: \.self) { _ in
                    Image("bottom-icons")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconWidth, height: geometry.size.height)
                }
            }
            .frame(width: iconWidth * 2, height: geometry.size.height)
            .offset(x: direction == .left ? offset : -offset)
        }
        .clipped()
    }
}

#Preview {
    SplashScreenView()
}
