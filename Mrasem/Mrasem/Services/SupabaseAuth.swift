import Foundation

/// Lightweight Supabase Auth client using the REST API.
/// No SDK dependency — just two HTTP calls for phone OTP.
final class SupabaseAuth {
    static let shared = SupabaseAuth()

    private let baseURL: String   // e.g. https://fltfmcqfoftzjhxxpsss.supabase.co
    private let anonKey: String
    private let session = URLSession.shared
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    private init() {
        // Derive auth URL from the REST URL in Info.plist
        // REST URL: https://xxx.supabase.co/rest/v1  →  base: https://xxx.supabase.co
        let rest = Bundle.main.infoDictionary?["MRASEM_SUPABASE_REST_URL"] as? String ?? ""
        baseURL = rest.replacingOccurrences(of: "/rest/v1", with: "")
        anonKey = Bundle.main.infoDictionary?["MRASEM_SUPABASE_ANON_KEY"] as? String ?? ""
    }

    // MARK: - Send OTP

    /// Sends an OTP to the given phone number (E.164 format, e.g. "+966500000000").
    func sendOTP(phone: String) async throws {
        let url = URL(string: "\(baseURL)/auth/v1/otp")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(anonKey, forHTTPHeaderField: "apikey")
        req.httpBody = try JSONEncoder().encode(["phone": phone])

        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw SupabaseAuthError.sendFailed(body)
        }
    }

    // MARK: - Verify OTP

    struct AuthSession: Decodable {
        let accessToken: String
        let refreshToken: String
        let user: AuthUser
    }

    struct AuthUser: Decodable {
        let id: String
        let phone: String?
    }

    /// Verifies the OTP and returns a session with access token.
    func verifyOTP(phone: String, code: String) async throws -> AuthSession {
        let url = URL(string: "\(baseURL)/auth/v1/verify")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(anonKey, forHTTPHeaderField: "apikey")

        let body: [String: String] = [
            "phone": phone,
            "token": code,
            "type": "sms"
        ]
        req.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw SupabaseAuthError.verifyFailed(body)
        }
        return try decoder.decode(AuthSession.self, from: data)
    }

    // MARK: - Fetch membership ID

    /// Fetches the user's membership_id from public.users using the access token.
    func fetchMembershipId(accessToken: String) async throws -> String? {
        let url = URL(string: "\(baseURL)/rest/v1/users?select=membership_id&limit=1")!
        var req = URLRequest(url: url)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(anonKey, forHTTPHeaderField: "apikey")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await session.data(for: req)

        struct Row: Decodable { let membership_id: String? }
        let rows = try JSONDecoder().decode([Row].self, from: data)
        return rows.first?.membership_id
    }
}

enum SupabaseAuthError: LocalizedError {
    case sendFailed(String)
    case verifyFailed(String)

    var errorDescription: String? {
        switch self {
        case .sendFailed(let msg): return "Failed to send OTP: \(msg)"
        case .verifyFailed(let msg): return "Verification failed: \(msg)"
        }
    }
}
