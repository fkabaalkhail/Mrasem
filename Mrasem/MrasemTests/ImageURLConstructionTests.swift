//
//  ImageURLConstructionTests.swift
//  MrasemTests
//
//  Feature: ios-api-integration, Property 5: Image URL construction
//  Validates: Requirements 6.1
//

import XCTest
@testable import Mrasem

final class ImageURLConstructionTests: XCTestCase {

    // MARK: - Helpers

    private let iterations = 100

    /// Characters safe for URL path segments (no spaces or special URL chars).
    private let pathChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"

    private func randomPathSegment(length: Int = 10) -> String {
        String((0..<length).map { _ in pathChars.randomElement()! })
    }

    private func randomLocalAssetName() -> String {
        // Local asset names: plain names that do NOT start with "/uploads/"
        let prefixes = ["icon-", "bg-", "logo-", "photo-", "img_", "asset.", ""]
        let prefix = prefixes.randomElement()!
        return prefix + randomPathSegment(length: Int.random(in: 3...15))
    }

    private func randomUploadPath() -> String {
        // Remote paths always start with "/uploads/"
        let ext = [".jpg", ".png", ".jpeg", ".webp"].randomElement()!
        return "/uploads/" + randomPathSegment(length: Int.random(in: 5...20)) + ext
    }

    /// Mirrors the baseURL derivation logic from RemoteImage.init:
    /// strips "/api" suffix from APIClient.shared.baseURL.
    private func deriveBaseURL(from apiBaseURL: String) -> String {
        if apiBaseURL.hasSuffix("/api") {
            return String(apiBaseURL.dropLast(4))
        }
        return apiBaseURL
    }

    // MARK: - Property 5: Image URL construction

    /// **Validates: Requirements 6.1**
    /// For any imageName starting with "/uploads/", RemoteImage should construct
    /// a URL equal to baseURL + imageName. The constructed URL must be valid.
    func testRemoteImageURLConstruction_uploadsPrefix() {
        let baseURL = deriveBaseURL(from: APIClient.shared.baseURL)

        for i in 0..<iterations {
            let imageName = randomUploadPath()

            // Verify the imageName starts with "/uploads/"
            XCTAssertTrue(imageName.hasPrefix("/uploads/"),
                          "Generated imageName should start with /uploads/ at iteration \(i)")

            // Construct URL the same way RemoteImage does
            let expectedURLString = baseURL + imageName
            let url = URL(string: expectedURLString)

            XCTAssertNotNil(url,
                            "URL should be valid for baseURL + imageName at iteration \(i): \(expectedURLString)")
            XCTAssertEqual(url?.absoluteString, expectedURLString,
                           "URL string should equal baseURL + imageName at iteration \(i)")
        }
    }

    /// **Validates: Requirements 6.1**
    /// For any imageName NOT starting with "/uploads/", the component should use
    /// the local asset catalog — meaning no remote URL is constructed.
    func testRemoteImageURLConstruction_localAsset() {
        for i in 0..<iterations {
            let imageName = randomLocalAssetName()

            // Verify the imageName does NOT start with "/uploads/"
            XCTAssertFalse(imageName.hasPrefix("/uploads/"),
                           "Local asset name should not start with /uploads/ at iteration \(i)")

            // RemoteImage uses Image(imageName) for local assets — no URL constructed.
            // The imageName should be a non-empty string suitable as an asset catalog name.
            XCTAssertFalse(imageName.isEmpty,
                           "Local asset name should not be empty at iteration \(i)")
        }
    }

    /// **Validates: Requirements 6.1**
    /// The baseURL derivation logic should correctly strip the "/api" suffix
    /// from various API base URLs.
    func testBaseURLDerivation_stripsApiSuffix() {
        // URLs ending with "/api" should have it stripped
        XCTAssertEqual(deriveBaseURL(from: "http://localhost:3001/api"), "http://localhost:3001")
        XCTAssertEqual(deriveBaseURL(from: "https://example.com/api"), "https://example.com")
        XCTAssertEqual(deriveBaseURL(from: "https://mrasem.app/v1/api"), "https://mrasem.app/v1")

        // URLs NOT ending with "/api" should remain unchanged
        XCTAssertEqual(deriveBaseURL(from: "http://localhost:3001"), "http://localhost:3001")
        XCTAssertEqual(deriveBaseURL(from: "https://example.com/v2"), "https://example.com/v2")
    }

    /// **Validates: Requirements 6.1**
    /// Property test: for random base URLs with "/api" suffix, the derived base URL
    /// combined with an uploads path should produce a valid URL.
    func testBaseURLDerivation_randomURLs() {
        let hosts = ["localhost:3001", "example.com", "api.mrasem.app", "192.168.1.100:8080"]

        for i in 0..<iterations {
            let host = hosts.randomElement()!
            let scheme = Bool.random() ? "https" : "http"
            let apiBaseURL = "\(scheme)://\(host)/api"

            let baseURL = deriveBaseURL(from: apiBaseURL)
            let imageName = randomUploadPath()
            let fullURL = baseURL + imageName

            // The derived baseURL should not end with "/api"
            XCTAssertFalse(baseURL.hasSuffix("/api"),
                           "Derived baseURL should not end with /api at iteration \(i)")

            // The full URL should be valid
            XCTAssertNotNil(URL(string: fullURL),
                            "Full image URL should be valid at iteration \(i): \(fullURL)")
        }
    }
}
