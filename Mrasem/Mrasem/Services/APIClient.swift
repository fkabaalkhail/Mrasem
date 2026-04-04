import Foundation

/// Centralized HTTP client for all API communication.
/// Singleton service that handles authentication, error parsing, and JSON coding.
///
/// **Listings** (restaurants, activities, season events): when `MRASEM_SUPABASE_REST_URL` and
/// `MRASEM_SUPABASE_ANON_KEY` are set in Info.plist, those use **Supabase PostgREST** (works on a real phone).
/// **Vercel** only hosts the admin website; it is not the mobile API.
///
/// **Express** (`/mobile/*`, OTP, etc.): always uses `baseURL` — `MRASEM_API_BASE_URL` or `http://127.0.0.1:3001/api`.
final class APIClient {
    static let shared = APIClient()

    /// Express API base (mobile auth, bookings, invitations). Not used for Supabase listing rows.
    var baseURL: String

    /// When `true`, listing stores read from Supabase instead of Express `/public/*`.
    var hasSupabaseListings: Bool {
        guard let rest = supabaseRESTURL, !rest.isEmpty,
              let key = supabaseAnonKey, !key.isEmpty else { return false }
        return true
    }

    private let supabaseRESTURL: String?
    private let supabaseAnonKey: String?

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        baseURL = Self.resolveExpressBaseURL()
        supabaseRESTURL = Self.readPlistTrimmed("MRASEM_SUPABASE_REST_URL")
        supabaseAnonKey = Self.readPlistTrimmed("MRASEM_SUPABASE_ANON_KEY")

        session = URLSession.shared

        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    private static func readPlistTrimmed(_ key: String) -> String? {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: key) as? String else { return nil }
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }

    /// Prefer Info.plist override; otherwise `http://127.0.0.1:3001/api` (Simulator + Mac server).
    private static func resolveExpressBaseURL() -> String {
        if let raw = Bundle.main.object(forInfoDictionaryKey: "MRASEM_API_BASE_URL") as? String {
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                let u = trimmed.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                if u.hasSuffix("/api") { return u }
                return u + "/api"
            }
        }
        return "http://127.0.0.1:3001/api"
    }

    // MARK: - Supabase PostgREST (public listings)

    /// Fetches rows from a table (e.g. `restaurants`, `season_events`). Requires anon key + RLS `SELECT` for `anon`.
    func supabaseSelect<T: Decodable>(_ table: String, cityEquals: String?) async throws -> [T] {
        guard hasSupabaseListings, let restBase = supabaseRESTURL, let key = supabaseAnonKey else {
            throw APIError.serverError(message: "Supabase listings not configured (REST URL + anon key).", statusCode: 0)
        }

        let root = restBase.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        var components = URLComponents(string: "\(root)/\(table)")
        var items: [URLQueryItem] = [URLQueryItem(name: "order", value: "id.asc")]
        if let city = cityEquals, !city.isEmpty {
            items.append(URLQueryItem(name: "city", value: "eq.\(city)"))
        }
        components?.queryItems = items

        guard let url = components?.url else {
            throw APIError.networkError(underlying: URLError(.badURL))
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue(key, forHTTPHeaderField: "apikey")
        urlRequest.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw APIError.networkError(underlying: error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(underlying: URLError(.badServerResponse))
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = parseSupabaseErrorMessage(from: data)
                ?? parseErrorMessage(from: data)
                ?? "Request failed with status \(httpResponse.statusCode)"
            throw APIError.serverError(message: message, statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode([T].self, from: data)
        } catch {
            throw APIError.decodingError(underlying: error)
        }
    }

    // MARK: - Generic Request

    /// Performs an HTTP request and decodes the response into the specified type.
    /// - Parameters:
    ///   - endpoint: The API endpoint path (e.g. "/public/restaurants").
    ///   - method: HTTP method string (default "GET").
    ///   - body: Optional Encodable body for POST/PATCH requests.
    ///   - authenticated: Whether to attach the Bearer token (default true).
    /// - Returns: Decoded response of type `T`.
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        authenticated: Bool = true
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.networkError(underlying: URLError(.badURL))
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Attach Bearer token from Keychain on authenticated requests
        if authenticated,
           let tokenData = KeychainHelper.shared.read(key: "auth_token"),
           let token = String(data: tokenData, encoding: .utf8) {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Encode request body
        if let body = body {
            urlRequest.httpBody = try encoder.encode(AnyEncodable(body))
        }

        // Perform the network request
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw APIError.networkError(underlying: error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(underlying: URLError(.badServerResponse))
        }

        // Handle 401 — post session expired notification
        if httpResponse.statusCode == 401 {
            await MainActor.run {
                NotificationCenter.default.post(name: Notification.Name("sessionExpired"), object: nil)
            }
            throw APIError.unauthorized
        }

        // Handle non-2xx responses — parse error body
        guard (200...299).contains(httpResponse.statusCode) else {
            let message = parseErrorMessage(from: data) ?? "Request failed with status \(httpResponse.statusCode)"
            throw APIError.serverError(message: message, statusCode: httpResponse.statusCode)
        }

        // Decode the successful response
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(underlying: error)
        }
    }

    // MARK: - Convenience Methods

    /// GET request convenience.
    func get<T: Decodable>(_ endpoint: String, authenticated: Bool = true) async throws -> T {
        try await request(endpoint: endpoint, method: "GET", authenticated: authenticated)
    }

    /// POST request convenience.
    func post<T: Decodable>(_ endpoint: String, body: Encodable, authenticated: Bool = true) async throws -> T {
        try await request(endpoint: endpoint, method: "POST", body: body, authenticated: authenticated)
    }

    /// PATCH request convenience.
    func patch<T: Decodable>(_ endpoint: String, body: Encodable, authenticated: Bool = true) async throws -> T {
        try await request(endpoint: endpoint, method: "PATCH", body: body, authenticated: authenticated)
    }

    // MARK: - Private Helpers

    /// Attempts to parse an error message from a JSON response body.
    /// Expects `{ "error": "..." }` format from the backend.
    private func parseErrorMessage(from data: Data) -> String? {
        struct ErrorBody: Decodable {
            let error: String
        }
        return try? JSONDecoder().decode(ErrorBody.self, from: data).error
    }

    private func parseSupabaseErrorMessage(from data: Data) -> String? {
        struct SupabaseErrorBody: Decodable {
            let message: String?
            let error: String?
            let hint: String?
        }
        guard let body = try? JSONDecoder().decode(SupabaseErrorBody.self, from: data) else { return nil }
        return body.message ?? body.error ?? body.hint
    }
}

// MARK: - Type-Erased Encodable Wrapper

/// Wraps any Encodable value so it can be encoded without knowing the concrete type.
private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init(_ value: Encodable) {
        _encode = { encoder in
            try value.encode(to: encoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
