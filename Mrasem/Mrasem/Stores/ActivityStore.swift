import Foundation
import Observation

/// Fetches and holds activity listings from the API.
/// Used by views to display activities with loading/error state.
@Observable
class ActivityStore {
    var activities: [Activity] = []
    var isLoading = false
    var error: String?

    /// Fetches activities from the API, optionally filtered by city.
    /// Skips fetch if data is already loaded (use `refresh` to force reload).
    @MainActor
    func fetch(city: String? = nil) async {
        guard activities.isEmpty else { return }
        await loadActivities(city: city)
    }

    /// Clears current data and re-fetches from the API.
    @MainActor
    func refresh(city: String? = nil) async {
        activities = []
        await loadActivities(city: city)
    }

    // MARK: - Private

    @MainActor
    private func loadActivities(city: String? = nil) async {
        isLoading = true
        error = nil

        do {
            if APIClient.shared.hasSupabaseListings {
                let rows: [Activity] = try await APIClient.shared.supabaseSelect(
                    "activities",
                    cityEquals: city
                )
                activities = rows
            } else {
                var endpoint = "/public/activities"
                if let city, !city.isEmpty {
                    let encoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
                    endpoint += "?city=\(encoded)"
                }
                let response: PaginatedResponse<Activity> = try await APIClient.shared.get(
                    endpoint,
                    authenticated: false
                )
                activities = response.data
            }
        } catch let apiError as APIError {
            error = apiError.errorDescription
        } catch let otherError {
            error = otherError.localizedDescription
        }

        isLoading = false
    }
}
