//
//  AuthTokenStorageRoundTripTests.swift
//  MrasemTests
//
//  Feature: ios-api-integration, Property 3: Auth token storage round-trip
//  Validates: Requirements 2.3, 2.5
//

import XCTest
@testable import Mrasem

final class AuthTokenStorageRoundTripTests: XCTestCase {

    // MARK: - Constants

    private let keychainKey = "auth_token"
    private let iterations = 100

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        // Ensure a clean Keychain state before each test
        KeychainHelper.shared.delete(key: keychainKey)
    }

    override func tearDown() {
        super.tearDown()
        KeychainHelper.shared.delete(key: keychainKey)
    }

    // MARK: - Helpers

    /// Generates a random alphanumeric string mimicking a JWT-like token.
    private func randomTokenString(length: Int? = nil) -> String {
        let len = length ?? Int.random(in: 1...256)
        let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-"
        return String((0..<len).map { _ in chars.randomElement()! })
    }

    // MARK: - Property 3: Auth token storage round-trip

    /// **Validates: Requirements 2.3, 2.5**
    ///
    /// For any random token string:
    /// 1. Saving it to Keychain (simulating successful OTP verification) makes it retrievable.
    /// 2. Deleting it from Keychain (simulating logout) makes it no longer retrievable.
    func testAuthTokenStorageRoundTripProperty() {
        for i in 0..<iterations {
            let token = randomTokenString()
            let tokenData = Data(token.utf8)

            // --- Store phase (simulates what happens after successful OTP verify) ---
            let saved = KeychainHelper.shared.save(key: keychainKey, data: tokenData)
            XCTAssertTrue(saved, "Keychain save failed at iteration \(i)")

            // Verify the token is retrievable
            let readData = KeychainHelper.shared.read(key: keychainKey)
            XCTAssertNotNil(readData, "Token should be readable after save at iteration \(i)")

            let readToken = readData.flatMap { String(data: $0, encoding: .utf8) }
            XCTAssertEqual(
                readToken,
                token,
                "Retrieved token should match stored token at iteration \(i)"
            )

            // --- Logout phase (simulates AuthenticationManager.logout()) ---
            let deleted = KeychainHelper.shared.delete(key: keychainKey)
            XCTAssertTrue(deleted, "Keychain delete failed at iteration \(i)")

            // Verify the token is no longer retrievable
            let afterDelete = KeychainHelper.shared.read(key: keychainKey)
            XCTAssertNil(
                afterDelete,
                "Token should be nil after deletion at iteration \(i)"
            )
        }
    }

    /// **Validates: Requirements 2.3**
    ///
    /// Overwriting a stored token with a new one should always return the latest value.
    func testTokenOverwriteReturnsLatestValue() {
        for i in 0..<iterations {
            let firstToken = randomTokenString()
            let secondToken = randomTokenString()

            // Save first token
            KeychainHelper.shared.save(key: keychainKey, data: Data(firstToken.utf8))

            // Overwrite with second token
            KeychainHelper.shared.save(key: keychainKey, data: Data(secondToken.utf8))

            // Read should return the second token
            let readData = KeychainHelper.shared.read(key: keychainKey)
            let readToken = readData.flatMap { String(data: $0, encoding: .utf8) }
            XCTAssertEqual(
                readToken,
                secondToken,
                "Overwritten token should return latest value at iteration \(i)"
            )

            // Clean up for next iteration
            KeychainHelper.shared.delete(key: keychainKey)
        }
    }

    /// **Validates: Requirements 2.5**
    ///
    /// Deleting a non-existent token should succeed (not crash or return false).
    func testDeleteNonExistentTokenSucceeds() {
        // Ensure nothing is stored
        KeychainHelper.shared.delete(key: keychainKey)

        // Deleting again should still succeed
        let result = KeychainHelper.shared.delete(key: keychainKey)
        XCTAssertTrue(result, "Deleting a non-existent Keychain item should succeed")
    }
}
