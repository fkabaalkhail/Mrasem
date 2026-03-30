import SwiftUI

struct OnboardingView3: View {
    var onGetStarted: (() -> Void)? = nil
    @EnvironmentObject private var languageManager: LanguageManager
    
    var body: some View {
        ZStack {
            Image("onboarding3-background")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
            
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
                    .padding(.trailing, 30)
                }
                .padding(.top, 56)
                
                Spacer()
            }
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        Text(languageManager.current == .arabic
                             ? "ابقَ على اطلاع بكل ما يهمك"
                             : "Stay Updated with Every Event You Love")
                            .font(.custom("ExpoArabic-Medium", size: 24))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(width: 297)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(24 * 0.216)
                            .padding(.top, 37)
                        
                        Text(languageManager.current == .arabic
                             ? "احصل على تذكيرات وتحديثات للفعاليات وعروض حصرية في الوقت المناسب"
                             : "Get reminders, event updates, and exclusive offers right when you need them.")
                            .font(.custom("ExpoArabic-Medium", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(width: 285)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(16 * 0.216)
                            .padding(.top, 64)
                        
                        Spacer()
                            .frame(minHeight: 40)
                        
                        Button(action: { onGetStarted?() }) {
                            Text(languageManager.current == .arabic ? "ابدأ الآن" : "Get Started")
                                .font(.custom("ExpoArabic-Medium", size: 20))
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                                .frame(width: 287, height: 56)
                                .background(Color.white)
                                .cornerRadius(13)
                        }
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
    OnboardingView3()
}
