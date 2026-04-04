//
//  ErrorLoadingStateTests.swift
//  MrasemTests
//
//  Unit tests for error and loading state handling.
//  Validates: Requirements 10.1, 10.2
//

import XCTest
@testable import Mrasem

final class ErrorLoadingStateTests: XCTestCase {

    // MARK: - APIError.errorDescription (English messages)

    /// Validates: Requirement 10.1
    /// Verify that networkError produces a "Connection error:" prefixed message.
    func testNetworkErrorDescription() {
        let underlying = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: [
            NSLocalizedDescriptionKey: "The Internet connection appears to be offline."
        ])
        let error = APIError.networkError(underlying: underlying)
        let desc = error.errorDescription
        XCTAssertNotNil(desc)
        XCTAssertTrue(desc!.hasPrefix("Connection error:"), "Expected 'Connection error:' prefix, got: \(desc!)")
    }

    /// Validates: Requirement 10.1
    /// Verify that serverError returns the server message directly.
    func testServerErrorDescription() {
        let error = APIError.serverError(message: "Not Found", statusCode: 404)
        XCTAssertEqual(error.errorDescription, "Not Found")
    }

    /// Validates: Requirement 10.1
    /// Verify that decodingError produces a "Data error:" prefixed message.
    func testDecodingErrorDescription() {
        let underlying = NSError(domain: "DecodingError", code: 0, userInfo: [
            NSLocalizedDescriptionKey: "Key not found"
        ])
        let error = APIError.decodingError(underlying: underlying)
        let desc = error.errorDescription
        XCTAssertNotNil(desc)
        XCTAssertTrue(desc!.hasPrefix("Data error:"), "Expected 'Data error:' prefix, got: \(desc!)")
    }

    /// Validates: Requirement 10.1
    /// Verify that unauthorized returns the session expired message.
    func testUnauthorizedErrorDescription() {
        let error = APIError.unauthorized
        XCTAssertEqual(error.errorDescription, "Session expired. Please log in again.")
    }

    // MARK: - APIError.localizedMessage(for:) — English

    /// Validates: Requirement 10.2
    /// English localized message should match errorDescription.
    func testLocalizedMessageEnglishNetworkError() {
        let underlying = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: [
            NSLocalizedDescriptionKey: "The request timed out."
        ])
        let error = APIError.networkError(underlying: underlying)
        let msg = error.localizedMessage(for: .english)
        XCTAssertEqual(msg, error.errorDescription)
    }

    func testLocalizedMessageEnglishServerError() {
        let error = APIError.serverError(message: "Internal Server Error", statusCode: 500)
        XCTAssertEqual(error.localizedMessage(for: .english), "Internal Server Error")
    }

    func testLocalizedMessageEnglishDecodingError() {
        let underlying = NSError(domain: "Decode", code: 0, userInfo: [NSLocalizedDescriptionKey: "type mismatch"])
        let error = APIError.decodingError(underlying: underlying)
        let msg = error.localizedMessage(for: .english)
        XCTAssertTrue(msg.contains("Data error:"))
    }

    func testLocalizedMessageEnglishUnauthorized() {
        let error = APIError.unauthorized
        XCTAssertEqual(error.localizedMessage(for: .english), "Session expired. Please log in again.")
    }

    // MARK: - APIError.localizedMessage(for:) — Arabic

    /// Validates: Requirement 10.2
    /// Arabic localized message for network error with "offline" keyword.
    func testLocalizedMessageArabicNetworkErrorOffline() {
        let underlying = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: [
            NSLocalizedDescriptionKey: "The device is offline."
        ])
        let error = APIError.networkError(underlying: underlying)
        XCTAssertEqual(error.localizedMessage(for: .arabic), "لا يوجد اتصال بالإنترنت")
    }

    /// Arabic network error without internet/offline keyword falls back to generic connection error.
    func testLocalizedMessageArabicNetworkErrorGeneric() {
        let underlying = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: [
            NSLocalizedDescriptionKey: "The request timed out."
        ])
        let error = APIError.networkError(underlying: underlying)
        XCTAssertEqual(error.localizedMessage(for: .arabic), "خطأ في الاتصال")
    }

    /// Arabic server error passes through the server message as-is.
    func testLocalizedMessageArabicServerError() {
        let error = APIError.serverError(message: "خطأ في الخادم", statusCode: 500)
        XCTAssertEqual(error.localizedMessage(for: .arabic), "خطأ في الخادم")
    }

    /// Arabic decoding error returns the Arabic data error string.
    func testLocalizedMessageArabicDecodingError() {
        let underlying = NSError(domain: "Decode", code: 0, userInfo: [NSLocalizedDescriptionKey: "type mismatch"])
        let error = APIError.decodingError(underlying: underlying)
        XCTAssertEqual(error.localizedMessage(for: .arabic), "خطأ في البيانات")
    }

    /// Arabic unauthorized returns the Arabic session expired string.
    func testLocalizedMessageArabicUnauthorized() {
        let error = APIError.unauthorized
        XCTAssertEqual(error.localizedMessage(for: .arabic), "انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.")
    }

    // MARK: - localizedErrorMessage(_:for:) free function

    /// Validates: Requirement 10.2
    /// English pass-through: the function returns the input string unchanged.
    func testLocalizedErrorMessageEnglishPassthrough() {
        let msg = "Connection error: timed out"
        XCTAssertEqual(localizedErrorMessage(msg, for: .english), msg)
    }

    /// Arabic mapping for "no internet" pattern.
    func testLocalizedErrorMessageArabicNoInternet() {
        XCTAssertEqual(localizedErrorMessage("No internet connection", for: .arabic), "لا يوجد اتصال بالإنترنت")
    }

    /// Arabic mapping for "not connected" pattern.
    func testLocalizedErrorMessageArabicNotConnected() {
        XCTAssertEqual(localizedErrorMessage("Device is not connected to the network", for: .arabic), "لا يوجد اتصال بالإنترنت")
    }

    /// Arabic mapping for "offline" pattern.
    func testLocalizedErrorMessageArabicOffline() {
        XCTAssertEqual(localizedErrorMessage("The device is offline", for: .arabic), "لا يوجد اتصال بالإنترنت")
    }

    /// Arabic mapping for "connection error" pattern.
    func testLocalizedErrorMessageArabicConnectionError() {
        XCTAssertEqual(localizedErrorMessage("Connection error: something failed", for: .arabic), "خطأ في الاتصال")
    }

    /// Arabic mapping for "network" pattern.
    func testLocalizedErrorMessageArabicNetwork() {
        XCTAssertEqual(localizedErrorMessage("A network error occurred", for: .arabic), "خطأ في الاتصال")
    }

    /// Arabic mapping for "timed out" pattern.
    func testLocalizedErrorMessageArabicTimedOut() {
        XCTAssertEqual(localizedErrorMessage("The request timed out", for: .arabic), "خطأ في الاتصال")
    }

    /// Arabic mapping for "could not connect" pattern.
    func testLocalizedErrorMessageArabicCouldNotConnect() {
        XCTAssertEqual(localizedErrorMessage("Could not connect to the server", for: .arabic), "خطأ في الاتصال")
    }

    /// Arabic mapping for "data error" pattern.
    func testLocalizedErrorMessageArabicDataError() {
        XCTAssertEqual(localizedErrorMessage("Data error: key not found", for: .arabic), "خطأ في البيانات")
    }

    /// Arabic mapping for "decod" pattern (covers decoding/decode).
    func testLocalizedErrorMessageArabicDecoding() {
        XCTAssertEqual(localizedErrorMessage("JSON decoding failed", for: .arabic), "خطأ في البيانات")
    }

    /// Arabic mapping for "session expired" pattern.
    func testLocalizedErrorMessageArabicSessionExpired() {
        XCTAssertEqual(localizedErrorMessage("Session expired. Please log in again.", for: .arabic), "انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.")
    }

    /// Arabic mapping for "unauthorized" pattern.
    func testLocalizedErrorMessageArabicUnauthorized() {
        XCTAssertEqual(localizedErrorMessage("Request unauthorized", for: .arabic), "انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.")
    }

    /// Arabic mapping for "log in" pattern.
    func testLocalizedErrorMessageArabicLogIn() {
        XCTAssertEqual(localizedErrorMessage("Please log in to continue", for: .arabic), "انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.")
    }

    /// Arabic: unrecognized error string is returned as-is.
    func testLocalizedErrorMessageArabicUnknownPassthrough() {
        let msg = "حدث خطأ غير معروف"
        XCTAssertEqual(localizedErrorMessage(msg, for: .arabic), msg)
    }

    // MARK: - Store error property behavior

    /// Validates: Requirement 10.1
    /// Verify that APIError cases produce non-nil errorDescription strings
    /// that stores would assign to their `error` property on failure.
    func testAPIErrorProducesStoreErrorStrings() {
        // networkError → stores set error = apiError.errorDescription
        let netErr = APIError.networkError(underlying: URLError(.notConnectedToInternet))
        XCTAssertNotNil(netErr.errorDescription)
        XCTAssertTrue(netErr.errorDescription!.contains("Connection error:"))

        // serverError → stores set error = the server message
        let srvErr = APIError.serverError(message: "Bad Request", statusCode: 400)
        XCTAssertEqual(srvErr.errorDescription, "Bad Request")

        // decodingError → stores set error = "Data error: ..."
        let decErr = APIError.decodingError(underlying: NSError(domain: "D", code: 0, userInfo: [NSLocalizedDescriptionKey: "missing key"]))
        XCTAssertNotNil(decErr.errorDescription)
        XCTAssertTrue(decErr.errorDescription!.hasPrefix("Data error:"))

        // unauthorized → stores set error = session expired message
        let authErr = APIError.unauthorized
        XCTAssertEqual(authErr.errorDescription, "Session expired. Please log in again.")
    }
}
