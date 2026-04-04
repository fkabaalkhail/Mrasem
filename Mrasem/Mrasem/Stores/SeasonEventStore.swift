import Foundation
import Observation

/// Fetches and holds season event listings from the API.
/// Used by views to display season events with loading/error state.
@Observable
class SeasonEventStore {
    var seasonEvents: [SeasonEvent] = []
    var isLoading = false
    var error: String?

    /// Fetches season events from the API, optionally filtered by city.
    /// Skips fetch if data is already loaded (use `refresh` to force reload).
    @MainActor
    func fetch(city: String? = nil) async {
        guard seasonEvents.isEmpty else { return }
        await loadSeasonEvents(city: city)
    }

    /// Clears current data and re-fetches from the API.
    @MainActor
    func refresh(city: String? = nil) async {
        seasonEvents = []
        await loadSeasonEvents(city: city)
    }

    // MARK: - Private

    @MainActor
    private func loadSeasonEvents(city: String? = nil) async {
        isLoading = true
        error = nil

        do {
            if APIClient.shared.hasSupabaseListings {
                let rows: [SeasonEvent] = try await APIClient.shared.supabaseSelect(
                    "season_events",
                    cityEquals: city
                )
                seasonEvents = rows
            } else {
                var endpoint = "/public/season-events"
                if let city, !city.isEmpty {
                    let encoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
                    endpoint += "?city=\(encoded)"
                }
                let response: PaginatedResponse<SeasonEvent> = try await APIClient.shared.get(
                    endpoint,
                    authenticated: false
                )
                seasonEvents = response.data
            }
        } catch let apiError as APIError {
            error = apiError.errorDescription
        } catch let otherError {
            error = otherError.localizedDescription
        }

        isLoading = false
    }
}
