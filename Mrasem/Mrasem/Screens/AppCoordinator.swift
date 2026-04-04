import SwiftUI

/// Main app coordinator handling screen navigation and transitions
struct AppCoordinator: View {
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var reservationStore = ReservationStore()
    @StateObject private var invitationStore = InvitationStore()
    @State private var currentScreen: AppScreen = .splash
    @State private var nextScreen: AppScreen? = nil
    @State private var slideOffset: CGFloat = 0
    
    enum AppScreen: Int {
        case splash = 0
        case onboarding = 1
        case onboarding2 = 2
        case onboarding3 = 3
        case phoneLogin = 4
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Current Screen
                screenView(for: currentScreen, geometry: geometry)
                    .offset(x: slideOffset)
                    .zIndex(1)
                
                // Next Screen (for slide transitions)
                if let next = nextScreen {
                    screenView(for: next, geometry: geometry)
                        .offset(x: slideOffset + geometry.size.width)
                        .zIndex(2)
                }
            }
        }
        .ignoresSafeArea()
        .environmentObject(languageManager)
        .environmentObject(reservationStore)
        .environmentObject(invitationStore)
    }
    
    @ViewBuilder
    private func screenView(for screen: AppScreen, geometry: GeometryProxy) -> some View {
        Group {
            switch screen {
            case .splash:
                SplashScreenView()
                    .onAppear {
                        StorePrefetch.warmAll()
                        if currentScreen == .splash {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                transitionToScreen(.onboarding, screenWidth: geometry.size.width)
                            }
                        }
                    }

            case .onboarding:
                OnboardingView(
                    onSkip: {
                        transitionToScreen(.phoneLogin, screenWidth: geometry.size.width, useSlide: false)
                    },
                    onNext: {
                        transitionToScreen(.onboarding2, screenWidth: geometry.size.width, useSlide: true)
                    }
                )

            case .onboarding2:
                OnboardingView2(
                    onSkip: {
                        transitionToScreen(.phoneLogin, screenWidth: geometry.size.width, useSlide: false)
                    },
                    onNext: {
                        transitionToScreen(.onboarding3, screenWidth: geometry.size.width, useSlide: true)
                    }
                )

            case .onboarding3:
                OnboardingView3(
                    onGetStarted: {
                        transitionToScreen(.phoneLogin, screenWidth: geometry.size.width, useSlide: false)
                    }
                )

            case .phoneLogin:
                NavigationStack {
                    PhoneLoginView()
                        .navigationBarHidden(true)
                }
            }
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
    }
    
    /// Smoothly transition to a new screen
    private func transitionToScreen(_ newScreen: AppScreen, screenWidth: CGFloat, useSlide: Bool = true) {
        if useSlide {
            // Set up next screen for sliding
            nextScreen = newScreen
            
            // Slide both screens together with interpolating spring for buttery smooth 60fps
            withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 1.0, blendDuration: 0)) {
                slideOffset = -screenWidth
            }
            
            // After animation completes, update current screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                currentScreen = newScreen
                nextScreen = nil
                slideOffset = 0
            }
        } else {
            // Instant transition for skip
            currentScreen = newScreen
            nextScreen = nil
            slideOffset = 0
        }
    }
}

#Preview {
    AppCoordinator()
}
