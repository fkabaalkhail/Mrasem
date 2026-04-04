import Foundation
import Observation

/// Fetches and holds restaurant listings from the API.
/// Used by views to display restaurants with loading/error state.
@Observable
class RestaurantStore {
    var restaurants: [Restaurant] = []
    var isLoading = false
    var error: String?

    /// Fetches restaurants from the API, optionally filtered by city.
    /// Skips fetch if data is already loaded (use `refresh` to force reload).
    @MainActor
    func fetch(city: String? = nil) async {
        guard restaurants.isEmpty else { return }
        await loadRestaurants(city: city)
    }

    /// Clears current data and re-fetches from the API.
    @MainActor
    func refresh(city: String? = nil) async {
        restaurants = []
        await loadRestaurants(city: city)
    }

    // MARK: - Private

    @MainActor
    private func loadRestaurants(city: String? = nil) async {
        isLoading = true
        error = nil

        do {
            if APIClient.shared.hasSupabaseListings {
                let rows: [Restaurant] = try await APIClient.shared.supabaseSelect(
                    "restaurants",
                    cityEquals: city
                )
                restaurants = rows
            } else {
                var endpoint = "/public/restaurants"
                if let city, !city.isEmpty {
                    let encoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
                    endpoint += "?city=\(encoded)"
                }
                let response: PaginatedResponse<Restaurant> = try await APIClient.shared.get(
                    endpoint,
                    authenticated: false
                )
                restaurants = response.data
            }
        } catch let apiError as APIError {
            error = apiError.errorDescription
        } catch let otherError {
            error = otherError.localizedDescription
        }

        isLoading = false
    }
}
