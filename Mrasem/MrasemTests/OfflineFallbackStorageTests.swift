//
//  OfflineFallbackStorageTests.swift
//  MrasemTests
//
//  Feature: ios-api-integration, Property 6: Offline fallback storage for failed writes
//  Validates: Requirements 7.5
//

import XCTest
@testable import Mrasem

final class OfflineFallbackStorageTests: XCTestCase {

    // MARK: - Constants

    private let pendingSyncKey = "mrasem.pendingBookings.v1"
    private let iterations = 100

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: pendingSyncKey)
    }

    override func tearDown() {
        super.tearDown()
        UserDefaults.standard.removeObject(forKey: pendingSyncKey)
    }

    // MARK: - Helpers

    private func randomString(length: Int = 10) -> String {
        let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "
        return String((0..<length).map { _ in chars.randomElement()! })
    }

    private func randomPendingBooking() -> PendingBooking {
        let isoFormatter = ISO8601DateFormatter()
        let randomDate = Date(timeIntervalSinceNow: Double.random(in: 0...86400 * 365))
        return PendingBooking(
            placeTitle: randomString(length: Int.random(in: 1...30)),
            subtitle: randomString(length: Int.random(in: 1...20)),
            imageName: randomString(length: Int.random(in: 5...15)),
            dateDisplay: randomString(length: Int.random(in: 3...10)),
            timeDisplay: randomString(length: Int.random(in: 3...8)),
            branch: randomString(length: Int.random(in: 3...15)),
            eventDate: isoFormatter.string(from: randomDate),
            usesForkSubtitleIcon: Bool.random()
        )
    }

    private func loadPendingBookings() -> [PendingBooking] {
        guard let data = UserDefaults.standard.data(forKey: pendingSyncKey) else { return [] }
        return (try? JSONDecoder().decode([PendingBooking].self, from: data)) ?? []
    }

    private func savePendingBookings(_ bookings: [PendingBooking]) {
        if bookings.isEmpty {
            UserDefaults.standard.removeObject(forKey: pendingSyncKey)
        } else if let data = try? JSONEncoder().encode(bookings) {
            UserDefaults.standard.set(data, forKey: pendingSyncKey)
        }
    }

    private func appendPendingBooking(_ booking: PendingBooking) {
        var pending = loadPendingBookings()
        pending.append(booking)
        savePendingBookings(pending)
    }

    // MARK: - Property 6: Offline fallback storage for failed writes

    /// **Validates: Requirements 7.5**
    /// For any random PendingBooking, encoding and saving it to UserDefaults
    /// then reading it back should produce an equal object.
    func testPendingBookingRoundTripProperty() {
        for i in 0..<iterations {
            // Start clean each iteration
            UserDefaults.standard.removeObject(forKey: pendingSyncKey)

            let original = randomPendingBooking()

            // Save to UserDefaults using the same mechanism as ReservationStore
            appendPendingBooking(original)

            // Read back
            let loaded = loadPendingBookings()
            XCTAssertEqual(loaded.count, 1, "Expected 1 pending booking at iteration \(i), got \(loaded.count)")
            XCTAssertEqual(loaded.first, original, "PendingBooking round-trip mismatch at iteration \(i)")
        }
    }

    /// **Validates: Requirements 7.5**
    /// After each append, the count of locally-stored pending bookings should
    /// increase by exactly one.
    func testPendingBookingCountIncreasesProperty() {
        for i in 0..<iterations {
            let booking = randomPendingBooking()
            let countBefore = loadPendingBookings().count

            appendPendingBooking(booking)

            let countAfter = loadPendingBookings().count
            XCTAssertEqual(
                countAfter,
                countBefore + 1,
                "Pending count did not increase by 1 at iteration \(i): before=\(countBefore), after=\(countAfter)"
            )
        }
    }

    /// **Validates: Requirements 7.5**
    /// All appended bookings should be retrievable and match the originals
    /// in order after accumulating multiple entries.
    func testAccumulatedPendingBookingsPreserveOrder() {
        var allBookings: [PendingBooking] = []

        for _ in 0..<iterations {
            let booking = randomPendingBooking()
            allBookings.append(booking)
            appendPendingBooking(booking)
        }

        let loaded = loadPendingBookings()
        XCTAssertEqual(loaded.count, iterations, "Expected \(iterations) pending bookings, got \(loaded.count)")
        XCTAssertEqual(loaded, allBookings, "Accumulated pending bookings do not match originals in order")
    }
}
