import SwiftUI

struct OnboardingView: View {
    var onSkip: (() -> Void)? = nil
    var onNext: (() -> Void)? = nil
    @EnvironmentObject private var languageManager: LanguageManager
    
    var body: some View {
        ZStack {
            // Background Image (local asset for instant loading)
            Image("welcoming-background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            // Dark overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        languageManager.toggle()
                    }) {
                        Text(languageManager.current == .english ? "عربي" : "English")
                            .font(.custom("ExpoArabic-Medium", size: 14))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 17)
                }
                .padding(.top, 56)
                
                Spacer()
            }
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // Title - 37px from brown box top (537px - 500px = 37px)
                        Text(languageManager.current == .arabic
                             ? "اكتشف أفضل الفعاليات من حولك!"
                             : "Explore Upcoming and\nNearby Events")
                            .font(.custom("ExpoArabic-Medium", size: 24))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(width: 297)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(24 * 0.216) // line-height: 1.216
                            .padding(.top, 37)
                        
                        // Description - 102px from title (639px - 537px = 102px)
                        Text(languageManager.current == .arabic
                             ? "اعثر على الحفلات وورش العمل والمهرجانات والتجارب المصممة بحسب اهتماماتك"
                             : "Find concerts, workshops, festivals,\nand experiences tailored to your\ninterests.")
                            .font(.custom("ExpoArabic-Medium", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(width: 285)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(16 * 0.216) // line-height: 1.216
                            .padding(.top, 64)
                        
                        Spacer()
                            .frame(minHeight: 40)
                        
                        // Page indicators - 275px from brown box top (775px - 500px = 275px)
                        HStack(spacing: 29) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 10, height: 10)
                            Circle()
                                .fill(Color.white.opacity(0.24))
                                .frame(width: 10, height: 10)
                            Circle()
                                .fill(Color.white.opacity(0.24))
                                .frame(width: 10, height: 10)
                        }
                        .frame(height: 10)
                        .padding(.bottom, 4) // 271px from brown box top (775px - 4px = 771px for buttons)
                        
                        // Skip/Next buttons - 271px from brown box top (771px - 500px = 271px)
                        HStack(spacing: 0) {
                            Button(action: { onSkip?() }) {
                            Text("Skip")
                                .font(.custom("ExpoArabic-Medium", size: 14))
                                .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(width: 72, alignment: .leading)
                            }
                            
                            Spacer()
                            
                            Button(action: { onNext?() }) {
                            Text("Next")
                                .font(.custom("ExpoArabic-Medium", size: 14))
                                .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(width: 72, alignment: .trailing)
                            }
                        }
                        .padding(.horizontal, 39)
                        .padding(.bottom, 37)
                    }
                    .frame(height: 312)
                    .frame(width: geometry.size.width)
                    .background(
                        Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
                    )
                    .clipShape(RoundedCorner(radius: 50, corners: [.topLeft, .topRight]))
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
