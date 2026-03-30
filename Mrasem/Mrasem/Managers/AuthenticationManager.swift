import SwiftUI
import Combine

/// Manages user authentication state throughout the app
@Observable
class AuthenticationManager {
    // Singleton instance
    static let shared = AuthenticationManager()
    
    // MARK: - Authentication State
    var isAuthenticated: Bool = false
    var hasCompletedOnboarding: Bool = false
    var phoneNumber: String?
    var isPhoneVerified: Bool = false
    var hasMembership: Bool = false
    var membershipNumber: String?
    var userToken: String?
    
    // MARK: - User Defaults Keys
    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let phoneNumber = "phoneNumber"
        static let isPhoneVerified = "isPhoneVerified"
        static let hasMembership = "hasMembership"
        static let membershipNumber = "membershipNumber"
        static let userToken = "userToken"
    }
    
    private init() {
        loadPersistedState()
    }
    
    // MARK: - Persistence
    
    /// Load saved state from UserDefaults
    private func loadPersistedState() {
        let defaults = UserDefaults.standard
        hasCompletedOnboarding = defaults.bool(forKey: Keys.hasCompletedOnboarding)
        phoneNumber = defaults.string(forKey: Keys.phoneNumber)
        isPhoneVerified = defaults.bool(forKey: Keys.isPhoneVerified)
        hasMembership = defaults.bool(forKey: Keys.hasMembership)
        membershipNumber = defaults.string(forKey: Keys.membershipNumber)
        userToken = defaults.string(forKey: Keys.userToken)
        
        // User is authenticated if they have a verified phone and token
        isAuthenticated = isPhoneVerified && userToken != nil
    }
    
    /// Save state to UserDefaults
    private func persistState() {
        let defaults = UserDefaults.standard
        defaults.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding)
        defaults.set(phoneNumber, forKey: Keys.phoneNumber)
        defaults.set(isPhoneVerified, forKey: Keys.isPhoneVerified)
        defaults.set(hasMembership, forKey: Keys.hasMembership)
        defaults.set(membershipNumber, forKey: Keys.membershipNumber)
        defaults.set(userToken, forKey: Keys.userToken)
    }
    
    // MARK: - Public Methods
    
    /// Mark onboarding as completed
    func completeOnboarding() {
        hasCompletedOnboarding = true
        persistState()
    }
    
    /// Save phone number (not yet verified)
    func savePhoneNumber(_ number: String) {
        phoneNumber = number
        persistState()
    }
    
    /// Verify phone with OTP
    func verifyPhone(otp: String, completion: @escaping (Bool, String?) -> Void) {
        // TODO: Call your backend API to verify OTP
        // For now, mock verification
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Mock success
            if otp == "123456" { // Replace with real API call
                self.isPhoneVerified = true
                self.userToken = "mock_token_\(UUID().uuidString)"
                self.isAuthenticated = true
                self.persistState()
                completion(true, nil)
            } else {
                completion(false, "Invalid OTP code")
            }
        }
    }
    
    /// Save membership information
    func saveMembership(number: String) {
        hasMembership = true
        membershipNumber = number
        persistState()
    }
    
    /// Complete logout
    func logout() {
        isAuthenticated = false
        isPhoneVerified = false
        userToken = nil
        phoneNumber = nil
        hasMembership = false
        membershipNumber = nil
        persistState()
    }
    
    /// Reset everything (for testing)
    func resetAll() {
        hasCompletedOnboarding = false
        logout()
    }
    
    // MARK: - Navigation Helper
    
    /// Determine which screen to show on app launch
    func getInitialScreen() -> AppScreen {
        if !hasCompletedOnboarding {
            return .splash
        } else if !isAuthenticated {
            return .phoneLogin
        } else {
            return .mainApp
        }
    }
}

/// App screens for navigation
enum AppScreen {
    case splash
    case onboarding
    case phoneLogin
    case otpVerification
    case membershipLogin
    case mainApp
}






