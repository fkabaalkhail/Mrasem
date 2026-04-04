import Foundation

/// Shared pre-fetched stores so data is ready before the user taps a category.
@MainActor
enum StorePrefetch {
    static let restaurants = RestaurantStore()
    static let activities = ActivityStore()
    static let seasonEvents = SeasonEventStore()

    static func warmAll() {
        Task { await restaurants.fetch() }
        Task { await activities.fetch() }
        Task { await seasonEvents.fetch() }
    }
}
