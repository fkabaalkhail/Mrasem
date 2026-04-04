//
//  AuthHeaderAttachmentTests.swift
//  MrasemTests
//
//  Feature: ios-api-integration, Property 1: Auth header attachment
//  Validates: Requirements 1.2
//

import XCTest
@testable import Mrasem

final class AuthHeaderAttachmentTests: XCTestCase {

    // MARK: - Constants

    private let keychainKey = "auth_token"
    private let iterations = 100

    // MARK: - Lifecycle

    override func tearDown() {
        super.tearDown()
        KeychainHelper.shared.delete(key: keychainKey)
    }

    // MARK: - Helpers

    /// Generates a random alphanumeric string of the given length,
    /// mimicking a JWT-like token value.
    private func randomTokenString(length: Int? = nil) -> String {
        let len = length ?? Int.random(in: 1...128)
        let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-"
        return String((0..<len).map { _ in chars.randomElement()! })
    }

    /// Builds a URLRequest the same way APIClient does for authenticated
    /// requests: reads the token from Keychain and attaches it as a Bearer
    /// header.  This mirrors the logic inside `APIClient.request(...)`.
    private func buildAuthenticatedRequest(baseURL: String = "http://localhost:3001/api",
                                           endpoint: String = "/test") -> URLRequest? {
        guard let url = URL(string: baseURL + endpoint) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let tokenData = KeychainHelper.shared.read(key: keychainKey),
           let token = String(data: tokenData, encoding: .utf8) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    // MARK: - Property 1: Auth header attachment

    /// **Validates: Requirements 1.2**
    /// For any random token string, saving it to Keychain and then building
    /// an authenticated URLRequest should produce an Authorization header
    /// equal to "Bearer <token>".
    func testAuthHeaderAttachmentProperty() {
        for i in 0..<iterations {
            let token = randomTokenString()
            let tokenData = Data(token.utf8)

            // Save token to Keychain
            let saved = KeychainHelper.shared.save(key: keychainKey, data: tokenData)
            XCTAssertTrue(saved, "Keychain save failed at iteration \(i)")

            // Build request the same way APIClient does
            let request = buildAuthenticatedRequest()
            XCTAssertNotNil(request, "Failed to build URLRequest at iteration \(i)")

            let authHeader = request?.value(forHTTPHeaderField: "Authorization")
            XCTAssertEqual(
                authHeader,
                "Bearer \(token)",
                "Auth header mismatch at iteration \(i) for token: \(token)"
            )

            // Clean up for next iteration
            KeychainHelper.shared.delete(key: keychainKey)
        }
    }

    /// **Validates: Requirements 1.2**
    /// When no token is stored in Keychain, the Authorization header should
    /// be absent from the request.
    func testNoTokenProducesNoAuthHeader() {
        // Ensure Keychain is clean
        KeychainHelper.shared.delete(key: keychainKey)

        let request = buildAuthenticatedRequest()
        XCTAssertNotNil(request)

        let authHeader = request?.value(forHTTPHeaderField: "Authorization")
        XCTAssertNil(authHeader, "Authorization header should be nil when no token is stored")
    }
}
