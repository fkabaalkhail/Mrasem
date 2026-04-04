//
//  ModelSerializationRoundTripTests.swift
//  MrasemTests
//
//  Feature: ios-api-integration, Property 9: Model serialization round-trip
//  Validates: Requirements 12.3
//

import XCTest
@testable import Mrasem

final class ModelSerializationRoundTripTests: XCTestCase {

    // MARK: - Helpers

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        return e
    }()

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    private let iterations = 100

    private func randomString(length: Int = 10) -> String {
        let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "
        return String((0..<length).map { _ in chars.randomElement()! })
    }

    private func randomDouble() -> Double {
        Double(Int.random(in: 0...50)) / 10.0
    }

    private func randomBool() -> Bool {
        Bool.random()
    }

    private func randomId() -> Int {
        Int.random(in: 1...100_000)
    }

    // MARK: - Random Instance Generators

    private func randomRestaurant() -> Restaurant {
        Restaurant(
            id: randomId(),
            name: randomString(),
            arabicName: randomString(),
            rating: randomDouble(),
            cuisine: randomString(),
            arabicCuisine: randomString(),
            imageName: randomString(),
            hasMichelin: randomBool(),
            description: randomString(length: 30),
            arabicDescription: randomString(length: 30),
            city: randomString(),
            arabicCity: randomString()
        )
    }

    private func randomActivity() -> Activity {
        Activity(
            id: randomId(),
            name: randomString(),
            rating: randomDouble(),
            category: randomString(),
            imageName: randomString(),
            location: randomString(),
            description: randomString(length: 30),
            city: randomString(),
            arabicName: randomString(),
            arabicCategory: randomString(),
            arabicDescription: randomString(length: 30),
            arabicLocation: randomString(),
            safetyGuidelines: randomString(length: 20),
            arabicSafetyGuidelines: randomString(length: 20)
        )
    }

    private func randomSeasonEvent() -> SeasonEvent {
        SeasonEvent(
            id: randomId(),
            name: randomString(),
            category: randomString(),
            imageName: randomString(),
            location: randomString(),
            description: randomString(length: 30),
            city: randomString(),
            arabicName: randomString(),
            arabicCategory: randomString(),
            arabicDescription: randomString(length: 30),
            arabicLocation: randomString()
        )
    }

    // MARK: - Property 9: Model serialization round-trip

    /// **Validates: Requirements 12.3**
    /// For any valid Restaurant, encoding to JSON with .convertToSnakeCase then
    /// decoding back with .convertFromSnakeCase produces an equal object.
    func testRestaurantSerializationRoundTrip() throws {
        for i in 0..<iterations {
            let original = randomRestaurant()
            let data = try encoder.encode(original)
            let decoded = try decoder.decode(Restaurant.self, from: data)
            XCTAssertEqual(decoded, original, "Restaurant round-trip failed at iteration \(i)")
        }
    }

    /// **Validates: Requirements 12.3**
    /// For any valid Activity, encoding to JSON with .convertToSnakeCase then
    /// decoding back with .convertFromSnakeCase produces an equal object.
    func testActivitySerializationRoundTrip() throws {
        for i in 0..<iterations {
            let original = randomActivity()
            let data = try encoder.encode(original)
            let decoded = try decoder.decode(Activity.self, from: data)
            XCTAssertEqual(decoded, original, "Activity round-trip failed at iteration \(i)")
        }
    }

    /// **Validates: Requirements 12.3**
    /// For any valid SeasonEvent, encoding to JSON with .convertToSnakeCase then
    /// decoding back with .convertFromSnakeCase produces an equal object.
    func testSeasonEventSerializationRoundTrip() throws {
        for i in 0..<iterations {
            let original = randomSeasonEvent()
            let data = try encoder.encode(original)
            let decoded = try decoder.decode(SeasonEvent.self, from: data)
            XCTAssertEqual(decoded, original, "SeasonEvent round-trip failed at iteration \(i)")
        }
    }
}
