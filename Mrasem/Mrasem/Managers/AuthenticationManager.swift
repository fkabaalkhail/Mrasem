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

    // MARK: - Dev Bypass
    // Set to true to allow code "000000" to bypass OTP verification
    // without needing the backend running. Remove before production.
    #if DEBUG
    private let devBypassEnabled = true
    private let devBypassCode = "000000"
    #else
    private let devBypassEnabled = false
    private let devBypassCode = ""
    #endif

    /// Send OTP to the given phone number via the backend.
    func sendOTP(phone: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // In dev mode, skip the API call — just save the phone number
        if devBypassEnabled {
            phoneNumber = phone
            persistState()
            return
        }

        let body = SendOTPRequest(phone: phone)
        let _: SendOTPResponse = try await APIClient.shared.post(
            "/mobile/auth/send-otp",
            body: body,
            authenticated: false
        )
        phoneNumber = phone
        persistState()
    }

    /// Verify phone with OTP code via the backend.
    /// On success, stores the JWT in Keychain and sets authenticated state.
    func verifyPhone(otp: String, completion: @escaping (Bool, String?) -> Void) {
        guard let phone = phoneNumber else {
            completion(false, "Phone number not set")
            return
        }

        // Dev bypass: code "000000" skips the API entirely
        if devBypassEnabled && otp == devBypassCode {
            let fakeToken = "dev-bypass-token-\(phone)"
            if let tokenData = fakeToken.data(using: .utf8) {
                KeychainHelper.shared.save(key: Keys.authToken, data: tokenData)
            }
            userToken = fakeToken
            isPhoneVerified = true
            isAuthenticated = true
            persistState()
            completion(true, nil)
            return
        }

        isLoading = true
        errorMessage = nil

        Task { @MainActor in
            do {
                let body = VerifyOTPRequest(phone: phone, code: otp)
                let response: VerifyOTPResponse = try await APIClient.shared.post(
                    "/mobile/auth/verify-otp",
                    body: body,
                    authenticated: false
                )

                // Store JWT in Keychain
                if let tokenData = response.token.data(using: .utf8) {
                    KeychainHelper.shared.save(key: Keys.authToken, data: tokenData)
                }

                userToken = response.token
                isPhoneVerified = true
                isAuthenticated = true
                isLoading = false
                persistState()
                completion(true, nil)
            } catch let error as APIError {
                isLoading = false
                let message = error.errorDescription ?? "Verification failed"
                errorMessage = message
                completion(false, message)
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

    /// Validate the stored token with the backend on app launch.
    /// If the token is invalid or expired, resets to unauthenticated state.
    /// Skips validation for dev bypass tokens or when backend is unreachable in DEBUG.
    func validateTokenOnLaunch() async {
        guard let token = userToken else { return }

        // Skip validation for dev bypass tokens
        #if DEBUG
        if token.hasPrefix("dev-bypass-token-") { return }
        #endif

        do {
            let response: ValidateResponse = try await APIClient.shared.get(
                "/mobile/auth/validate",
                authenticated: true
            )
            if !response.valid {
                await MainActor.run { forceLogout() }
            }
        } catch {
            // In DEBUG, don't force logout on network errors (server might not be running)
            #if DEBUG
            if case APIError.networkError = error { return }
            #endif
            // Token is invalid or network error — clear auth state
            await MainActor.run { forceLogout() }
        }
    }

    // MARK: - Membership

    /// Save membership information
    func saveMembership(number: String) {
        hasMembership = true
        membershipNumber = number
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
