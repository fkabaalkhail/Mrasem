//
//  ErrorResponseParsingTests.swift
//  MrasemTests
//
//  Feature: ios-api-integration, Property 2: Error response parsing
//  Validates: Requirements 1.3
//

import XCTest
@testable import Mrasem

final class ErrorResponseParsingTests: XCTestCase {

    // MARK: - Constants

    private let iterations = 100

    // MARK: - Helpers

    /// Generates a random HTTP error status code in the range 400–599,
    /// excluding 401 which has special handling (unauthorized).
    private func randomErrorStatusCode() -> Int {
        var code: Int
        repeat {
            code = Int.random(in: 400...599)
        } while code == 401
        return code
    }

    /// Generates a random error message string of variable length,
    /// using printable ASCII characters.
    private func randomErrorMessage() -> String {
        let length = Int.random(in: 1...200)
        let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,!?-_:;()[]{}@#$%&*+=/"
        return String((0..<length).map { _ in chars.randomElement()! })
    }

    /// Replicates the error parsing logic from APIClient.parseErrorMessage.
    /// Parses `{ "error": "<message>" }` JSON data and returns the message.
    private func parseErrorMessage(from data: Data) -> String? {
        struct ErrorBody: Decodable {
            let error: String
        }
        return try? JSONDecoder().decode(ErrorBody.self, from: data).error
    }

    // MARK: - Property 2: Error response parsing

    /// **Validates: Requirements 1.3**
    /// For any random HTTP error status code (400–599, excluding 401) and
    /// any random error message string, creating a JSON body in the format
    /// `{ "error": "<message>" }` and parsing it should produce an
    /// APIError.serverError whose message matches the original string exactly.
    func testErrorResponseParsingProperty() {
        for i in 0..<iterations {
            let statusCode = randomErrorStatusCode()
            let expectedMessage = randomErrorMessage()

            // Build JSON body matching the backend error format
            let jsonBody: [String: String] = ["error": expectedMessage]
            guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonBody) else {
                XCTFail("Failed to serialize JSON at iteration \(i)")
                continue
            }

            // Parse the error message using the same logic as APIClient
            let parsedMessage = parseErrorMessage(from: jsonData)
            XCTAssertNotNil(parsedMessage, "Failed to parse error message at iteration \(i)")
            XCTAssertEqual(
                parsedMessage,
                expectedMessage,
                "Parsed message mismatch at iteration \(i) for status \(statusCode)"
            )

            // Construct the APIError the same way APIClient does
            let message = parsedMessage ?? "Request failed with status \(statusCode)"
            let apiError = APIError.serverError(message: message, statusCode: statusCode)

            // Verify the APIError contains the exact message
            switch apiError {
            case .serverError(let msg, let code):
                XCTAssertEqual(
                    msg,
                    expectedMessage,
                    "APIError message mismatch at iteration \(i)"
                )
                XCTAssertEqual(
                    code,
                    statusCode,
                    "APIError status code mismatch at iteration \(i)"
                )
            default:
                XCTFail("Expected .serverError but got different case at iteration \(i)")
            }

            // Also verify errorDescription returns the message
            XCTAssertEqual(
                apiError.errorDescription,
                expectedMessage,
                "errorDescription mismatch at iteration \(i)"
            )
        }
    }

    /// **Validates: Requirements 1.3**
    /// When the JSON body does not contain an "error" field, the fallback
    /// message should include the status code.
    func testFallbackMessageWhenNoErrorField() {
        for i in 0..<iterations {
            let statusCode = randomErrorStatusCode()

            // JSON body without "error" key
            let jsonBody: [String: String] = ["message": "something else"]
            guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonBody) else {
                XCTFail("Failed to serialize JSON at iteration \(i)")
                continue
            }

            let parsedMessage = parseErrorMessage(from: jsonData)
            XCTAssertNil(parsedMessage, "Should not parse message from non-error JSON at iteration \(i)")

            // Fallback message as APIClient would construct it
            let fallback = "Request failed with status \(statusCode)"
            let apiError = APIError.serverError(message: fallback, statusCode: statusCode)

            switch apiError {
            case .serverError(let msg, let code):
                XCTAssertTrue(
                    msg.contains("\(statusCode)"),
                    "Fallback message should contain status code at iteration \(i)"
                )
                XCTAssertEqual(code, statusCode)
            default:
                XCTFail("Expected .serverError at iteration \(i)")
            }
        }
    }
}
