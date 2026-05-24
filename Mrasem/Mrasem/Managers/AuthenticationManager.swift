import SwiftUI
import Combine

/// Manages user authentication state throughout the app.
/// Uses real API calls for OTP flow and stores JWT in Keychain.
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
    var userName: String?
    var userToken: String?

    /// Indicates an OTP send/verify request is in progress
    var isLoading: Bool = false
    /// Holds the latest error message from an auth operation
    var errorMessage: String?

    // MARK: - Keys
    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let phoneNumber = "phoneNumber"
        static let isPhoneVerified = "isPhoneVerified"
        static let hasMembership = "hasMembership"
        static let membershipNumber = "membershipNumber"
        static let userName = "userName"
        /// Keychain key for the JWT token
        static let authToken = "auth_token"
    }

    private var sessionExpiredObserver: Any?

    private init() {
        loadPersistedState()
        listenForSessionExpired()
    }

    deinit {
        if let observer = sessionExpiredObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Session Expired Listener

    /// Listens for `sessionExpired` notification posted by APIClient on 401 responses.
    private func listenForSessionExpired() {
        sessionExpiredObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name("sessionExpired"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.forceLogout()
        }
    }

    /// Force logout triggered by session expiry notification.
    private func forceLogout() {
        isAuthenticated = false
        isPhoneVerified = false
        userToken = nil
        KeychainHelper.shared.delete(key: Keys.authToken)
        persistState()
    }

    // MARK: - Persistence

    /// Load saved state from UserDefaults and Keychain.
    private func loadPersistedState() {
        let defaults = UserDefaults.standard
        hasCompletedOnboarding = defaults.bool(forKey: Keys.hasCompletedOnboarding)
        phoneNumber = defaults.string(forKey: Keys.phoneNumber)
        isPhoneVerified = defaults.bool(forKey: Keys.isPhoneVerified)
        hasMembership = defaults.bool(forKey: Keys.hasMembership)
        membershipNumber = defaults.string(forKey: Keys.membershipNumber)
        userName = defaults.string(forKey: Keys.userName)

        // Read token from Keychain instead of UserDefaults
        if let tokenData = KeychainHelper.shared.read(key: Keys.authToken),
           let token = String(data: tokenData, encoding: .utf8) {
            userToken = token
        } else {
            userToken = nil
        }

        // User is authenticated if they have a verified phone and token
        isAuthenticated = isPhoneVerified && userToken != nil
    }

    /// Save non-token state to UserDefaults. Token is stored in Keychain separately.
    private func persistState() {
        let defaults = UserDefaults.standard
        defaults.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding)
        defaults.set(phoneNumber, forKey: Keys.phoneNumber)
        defaults.set(isPhoneVerified, forKey: Keys.isPhoneVerified)
        defaults.set(hasMembership, forKey: Keys.hasMembership)
        defaults.set(membershipNumber, forKey: Keys.membershipNumber)
        defaults.set(userName, forKey: Keys.userName)
        // Token is NOT stored in UserDefaults — it lives in Keychain
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

    // MARK: - OTP Flow (Real API)

    /// Request body for sending OTP
    private struct SendOTPRequest: Encodable {
        let phone: String
    }

    /// Request body for verifying OTP
    private struct VerifyOTPRequest: Encodable {
        let phone: String
        let code: String
    }

    /// Response from send-otp endpoint
    private struct SendOTPResponse: Decodable {
        let message: String
    }

    /// Response from verify-otp endpoint
    private struct VerifyOTPResponse: Decodable {
        let token: String
        let user: UserInfo?
    }

    /// Minimal user info returned on verify
    private struct UserInfo: Decodable {
        let id: Int
        let phone: String
    }

    /// Response from validate endpoint
    private struct ValidateResponse: Decodable {
        let valid: Bool
        let user: UserInfo?
    }

    // MARK: - Demo / dev bypass
    /// DEBUG builds always allow bypass. Release: set `MRASEM_DEMO_MODE` = YES in Info.plist for TestFlight/public demos only; turn off for App Store.
    private var allowsDemoBypass: Bool {
        #if DEBUG
        true
        #else
        Bundle.main.object(forInfoDictionaryKey: "MRASEM_DEMO_MODE") as? Bool == true
        #endif
    }

    private let demoBypassCode = "000000"
    private static let demoGuestPhone = "+966000000000"

    /// One-shot guest sign-in for demos (no SMS). No-op if demo mode is disabled.
    @MainActor
    func enterDemoGuestMode() {
        guard allowsDemoBypass else { return }
        let phone = Self.demoGuestPhone
        phoneNumber = phone
        let fakeToken = "dev-bypass-token-\(phone)"
        if let tokenData = fakeToken.data(using: .utf8) {
            KeychainHelper.shared.save(key: Keys.authToken, data: tokenData)
        }
        userToken = fakeToken
        isPhoneVerified = true
        isAuthenticated = true
        membershipNumber = "0000000000"
        hasMembership = true
        if userName == nil || userName?.isEmpty == true {
            userName = "Demo"
        }
        hasCompletedOnboarding = true
        persistState()
    }

    /// Whether to show demo UI (guest entry, OTP shortcut).
    var isDemoModeEnabled: Bool { allowsDemoBypass }

    /// Send OTP to the given phone number via Supabase Auth.
    func sendOTP(phone: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // Demo / DEBUG: skip SMS — just save the phone number
        if allowsDemoBypass {
            phoneNumber = phone
            persistState()
            return
        }

        try await SupabaseAuth.shared.sendOTP(phone: phone)
        phoneNumber = phone
        persistState()
    }

    /// Verify phone with OTP code via Supabase Auth.
    /// On success, stores the JWT in Keychain, fetches membership ID, and sets authenticated state.
    func verifyPhone(otp: String, completion: @escaping (Bool, String?) -> Void) {
        guard let phone = phoneNumber else {
            completion(false, "Phone number not set")
            return
        }

        // Demo: code "000000" skips Supabase verify
        if allowsDemoBypass && otp == demoBypassCode {
            let fakeToken = "dev-bypass-token-\(phone)"
            if let tokenData = fakeToken.data(using: .utf8) {
                KeychainHelper.shared.save(key: Keys.authToken, data: tokenData)
            }
            userToken = fakeToken
            isPhoneVerified = true
            isAuthenticated = true
            membershipNumber = "0000000000"
            hasMembership = true
            persistState()
            completion(true, nil)
            return
        }

        isLoading = true
        errorMessage = nil

        Task { @MainActor in
            do {
                let session = try await SupabaseAuth.shared.verifyOTP(phone: phone, code: otp)

                // Store JWT in Keychain
                if let tokenData = session.accessToken.data(using: .utf8) {
                    KeychainHelper.shared.save(key: Keys.authToken, data: tokenData)
                }

                userToken = session.accessToken
                isPhoneVerified = true
                isAuthenticated = true

                // Fetch membership ID
                if let mid = try? await SupabaseAuth.shared.fetchMembershipId(accessToken: session.accessToken) {
                    membershipNumber = mid
                    hasMembership = true
                }

                isLoading = false
                persistState()
                completion(true, nil)
            } catch {
                isLoading = false
                let message = error.localizedDescription
                errorMessage = message
                completion(false, message)
            }
        }
    }

    /// Async version of verifyPhone for modern callers.
    func verifyPhone(otp: String) async -> (success: Bool, error: String?) {
        await withCheckedContinuation { continuation in
            verifyPhone(otp: otp) { success, error in
                continuation.resume(returning: (success, error))
            }
        }
    }

    // MARK: - Token Validation

    /// Validate the stored token on app launch and fetch membership ID.
    /// If the token is invalid or expired, resets to unauthenticated state.
    func validateTokenOnLaunch() async {
        guard let token = userToken else { return }

        // Local demo tokens are not valid on Supabase
        if token.hasPrefix("dev-bypass-token-") {
            if allowsDemoBypass { return }
            await MainActor.run { forceLogout() }
            return
        }

        // Try to fetch membership ID — if it works, token is valid
        do {
            if let mid = try await SupabaseAuth.shared.fetchMembershipId(accessToken: token) {
                await MainActor.run {
                    membershipNumber = mid
                    hasMembership = true
                    persistState()
                }
            }
        } catch {
            // Token is invalid — clear auth state
            #if DEBUG
            // In DEBUG, don't force logout on network errors
            return
            #else
            await MainActor.run { forceLogout() }
            #endif
        }
    }

    // MARK: - Membership

    /// Save membership information
    func saveMembership(number: String) {
        hasMembership = true
        membershipNumber = number
        persistState()
    }

    /// Save display name
    func saveName(_ name: String?) {
        userName = name
        persistState()
    }

    // MARK: - Logout

    /// Complete logout — clears token from Keychain and resets state.
    func logout() {
        isAuthenticated = false
        isPhoneVerified = false
        userToken = nil
        phoneNumber = nil
        hasMembership = false
        membershipNumber = nil
        userName = nil
        KeychainHelper.shared.delete(key: Keys.authToken)
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
