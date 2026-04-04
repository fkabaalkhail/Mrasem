//
//  InvalidJSONDecodingTests.swift
//  MrasemTests
//
//  Feature: ios-api-integration, Property 10: Invalid JSON produces decoding error
//  Validates: Requirements 12.5
//

import XCTest
@testable import Mrasem

final class InvalidJSONDecodingTests: XCTestCase {

    // MARK: - Helpers

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

    private func randomId() -> Int {
        Int.random(in: 1...100_000)
    }

    // MARK: - Valid JSON Dictionaries

    private func validRestaurantJSON() -> [String: Any] {
        [
            "id": randomId(),
            "name": randomString(),
            "arabic_name": randomString(),
            "rating": randomDouble(),
            "cuisine": randomString(),
            "arabic_cuisine": randomString(),
            "image_name": randomString(),
            "has_michelin": Bool.random(),
            "description": randomString(length: 30),
            "arabic_description": randomString(length: 30),
            "city": randomString(),
            "arabic_city": randomString()
        ]
    }

    private func validActivityJSON() -> [String: Any] {
        [
            "id": randomId(),
            "name": randomString(),
            "rating": randomDouble(),
            "category": randomString(),
            "image_name": randomString(),
            "location": randomString(),
            "description": randomString(length: 30),
            "city": randomString()
        ]
    }

    private func validSeasonEventJSON() -> [String: Any] {
        [
            "id": randomId(),
            "name": randomString(),
            "category": randomString(),
            "image_name": randomString(),
            "location": randomString(),
            "description": randomString(length: 30),
            "city": randomString()
        ]
    }

    // MARK: - Mutation Strategies

    /// Represents how we corrupt a JSON dictionary to make it invalid.
    private enum Mutation {
        case removeField
        case wrongType
    }

    /// Randomly removes a required field or replaces it with a wrong type.
    /// Returns the mutated dictionary and a description of what was changed.
    private func mutateJSON(_ json: [String: Any], requiredFields: [String: Any]) -> ([String: Any], String) {
        let fieldKeys = Array(requiredFields.keys)
        let targetKey = fieldKeys.randomElement()!
        let mutation: Mutation = Bool.random() ? .removeField : .wrongType

        var mutated = json

        switch mutation {
        case .removeField:
            mutated.removeValue(forKey: targetKey)
            return (mutated, "removed field '\(targetKey)'")

        case .wrongType:
            let originalValue = requiredFields[targetKey]!
            // Replace with a value of a different type
            if originalValue is Int {
                mutated[targetKey] = "not_an_int"
            } else if originalValue is Double {
                mutated[targetKey] = "not_a_double"
            } else if originalValue is String {
                mutated[targetKey] = 99999
            } else if originalValue is Bool {
                mutated[targetKey] = "not_a_bool"
            }
            return (mutated, "wrong type for field '\(targetKey)'")
        }
    }

    /// Maps required fields to their expected types for mutation targeting.
    private var restaurantRequiredFields: [String: Any] {
        [
            "id": 1 as Int,
            "name": "" as String,
            "arabic_name": "" as String,
            "rating": 0.0 as Double,
            "cuisine": "" as String,
            "arabic_cuisine": "" as String,
            "image_name": "" as String,
            "has_michelin": true as Bool,
            "description": "" as String,
            "arabic_description": "" as String,
            "city": "" as String,
            "arabic_city": "" as String
        ]
    }

    private var activityRequiredFields: [String: Any] {
        [
            "id": 1 as Int,
            "name": "" as String,
            "rating": 0.0 as Double,
            "category": "" as String,
            "image_name": "" as String,
            "location": "" as String,
            "description": "" as String,
            "city": "" as String
        ]
    }

    private var seasonEventRequiredFields: [String: Any] {
        [
            "id": 1 as Int,
            "name": "" as String,
            "category": "" as String,
            "image_name": "" as String,
            "location": "" as String,
            "description": "" as String,
            "city": "" as String
        ]
    }

    // MARK: - Property 10: Invalid JSON produces decoding error

    /// **Validates: Requirements 12.5**
    /// For any JSON payload missing a required Restaurant field or with a wrong type,
    /// decoding into Restaurant should throw a DecodingError.
    func testInvalidRestaurantJSONProducesDecodingError() throws {
        for i in 0..<iterations {
            let validJSON = validRestaurantJSON()
            let (mutatedJSON, desc) = mutateJSON(validJSON, requiredFields: restaurantRequiredFields)
            let data = try JSONSerialization.data(withJSONObject: mutatedJSON)

            XCTAssertThrowsError(
                try decoder.decode(Restaurant.self, from: data),
                "Restaurant decoding should fail at iteration \(i) (\(desc))"
            ) { error in
                XCTAssertTrue(
                    error is DecodingError,
                    "Expected DecodingError at iteration \(i) (\(desc)), got \(type(of: error))"
                )
                XCTAssertFalse(
                    error.localizedDescription.isEmpty,
                    "Error description should not be empty at iteration \(i) (\(desc))"
                )
            }
        }
    }

    /// **Validates: Requirements 12.5**
    /// For any JSON payload missing a required Activity field or with a wrong type,
    /// decoding into Activity should throw a DecodingError.
    func testInvalidActivityJSONProducesDecodingError() throws {
        for i in 0..<iterations {
            let validJSON = validActivityJSON()
            let (mutatedJSON, desc) = mutateJSON(validJSON, requiredFields: activityRequiredFields)
            let data = try JSONSerialization.data(withJSONObject: mutatedJSON)

            XCTAssertThrowsError(
                try decoder.decode(Activity.self, from: data),
                "Activity decoding should fail at iteration \(i) (\(desc))"
            ) { error in
                XCTAssertTrue(
                    error is DecodingError,
                    "Expected DecodingError at iteration \(i) (\(desc)), got \(type(of: error))"
                )
                XCTAssertFalse(
                    error.localizedDescription.isEmpty,
                    "Error description should not be empty at iteration \(i) (\(desc))"
                )
            }
        }
    }

    /// **Validates: Requirements 12.5**
    /// For any JSON payload missing a required SeasonEvent field or with a wrong type,
    /// decoding into SeasonEvent should throw a DecodingError.
    func testInvalidSeasonEventJSONProducesDecodingError() throws {
        for i in 0..<iterations {
            let validJSON = validSeasonEventJSON()
            let (mutatedJSON, desc) = mutateJSON(validJSON, requiredFields: seasonEventRequiredFields)
            let data = try JSONSerialization.data(withJSONObject: mutatedJSON)

            XCTAssertThrowsError(
                try decoder.decode(SeasonEvent.self, from: data),
                "SeasonEvent decoding should fail at iteration \(i) (\(desc))"
            ) { error in
                XCTAssertTrue(
                    error is DecodingError,
                    "Expected DecodingError at iteration \(i) (\(desc)), got \(type(of: error))"
                )
                XCTAssertFalse(
                    error.localizedDescription.isEmpty,
                    "Error description should not be empty at iteration \(i) (\(desc))"
                )
            }
        }
    }
}
