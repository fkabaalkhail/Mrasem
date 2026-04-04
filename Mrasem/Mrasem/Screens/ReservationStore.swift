import Combine
import Foundation
import SwiftUI

/// Persisted reservation shown under **My Reservations** (Figma 1306:51428 / 1202:9355).
struct StoredReservation: Codable, Identifiable, Equatable {
    let id: String
    let serverId: Int?
    let placeTitle: String
    let subtitle: String
    let imageName: String
    let dateDisplay: String
    let timeDisplay: String
    let branch: String
    let qrPayload: String
    let eventDate: Date
    /// Booking status: "pending", "approved", or "rejected".
    let status: String
    let usesForkSubtitleIcon: Bool

    var isPastBooking: Bool {
        Calendar.current.startOfDay(for: eventDate) < Calendar.current.startOfDay(for: Date())
    }

    /// Memberwise initializer with defaults for backward compatibility.
    init(
        id: String,
        serverId: Int? = nil,
        placeTitle: String,
        subtitle: String,
        imageName: String,
        dateDisplay: String,
        timeDisplay: String,
        branch: String,
        qrPayload: String,
        eventDate: Date,
        status: String = "pending",
        usesForkSubtitleIcon: Bool
    ) {
        self.id = id
        self.serverId = serverId
        self.placeTitle = placeTitle
        self.subtitle = subtitle
        self.imageName = imageName
        self.dateDisplay = dateDisplay
        self.timeDisplay = timeDisplay
        self.branch = branch
        self.qrPayload = qrPayload
        self.eventDate = eventDate
        self.status = status
        self.usesForkSubtitleIcon = usesForkSubtitleIcon
    }

    /// Decodes with backward compatibility — missing `serverId` and `status` get defaults.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        serverId = try container.decodeIfPresent(Int.self, forKey: .serverId)
        placeTitle = try container.decode(String.self, forKey: .placeTitle)
        subtitle = try container.decode(String.self, forKey: .subtitle)
        imageName = try container.decode(String.self, forKey: .imageName)
        dateDisplay = try container.decode(String.self, forKey: .dateDisplay)
        timeDisplay = try container.decode(String.self, forKey: .timeDisplay)
        branch = try container.decode(String.self, forKey: .branch)
        qrPayload = try container.decode(String.self, forKey: .qrPayload)
        eventDate = try container.decode(Date.self, forKey: .eventDate)
        status = try container.decodeIfPresent(String.self, forKey: .status) ?? "pending"
        usesForkSubtitleIcon = try container.decode(Bool.self, forKey: .usesForkSubtitleIcon)
    }
}

/// Booking payload sent to POST /api/mobile/bookings and also saved to
/// UserDefaults when the POST fails. Queued for retry via `retryPendingSync()`.
struct PendingBooking: Codable, Equatable {
    let placeTitle: String
    let subtitle: String
    let imageName: String
    let dateDisplay: String
    let timeDisplay: String
    let branch: String
    let eventDate: String          // ISO-8601 string for the server
    let usesForkSubtitleIcon: Bool
}

/// Request body for POST /api/mobile/bookings.
/// Separate from `PendingBooking` only because the API encoder uses
/// `.convertToSnakeCase` — the fields are identical.
private struct CreateBookingBody: Encodable {
    let placeTitle: String
    let subtitle: String
    let imageName: String
    let dateDisplay: String
    let timeDisplay: String
    let branch: String
    let eventDate: String
    let usesForkSubtitleIcon: Bool
}

/// Server response for a single created booking (POST /api/mobile/bookings).
private struct ServerBooking: Decodable {
    let id: Int
    let ticketCode: String
    let placeTitle: String
    let subtitle: String
    let imageName: String
    let dateDisplay: String
    let timeDisplay: String
    let branch: String
    let qrPayload: String
    let eventDate: String
    let status: String
    let usesForkSubtitleIcon: Bool
}

final class ReservationStore: ObservableObject {
    @Published private(set) var reservations: [StoredReservation] = []
    @Published var isLoading = false
    @Published var error: String?

    private let storageKey = "mrasem.storedReservations.v1"
    private let pendingSyncKey = "mrasem.pendingBookings.v1"

    init(previewReservations: [StoredReservation]? = nil) {
        if let previewReservations {
            reservations = previewReservations
            return
        }
        load()
    }

    // MARK: - Computed helpers

    var upcoming: [StoredReservation] {
        reservations.filter { !$0.isPastBooking }.sorted { $0.eventDate < $1.eventDate }
    }

    var history: [StoredReservation] {
        reservations.filter(\.isPastBooking).sorted { $0.eventDate > $1.eventDate }
    }

    // MARK: - Server sync

    /// Fetches the authenticated user's bookings from GET /api/mobile/bookings.
    /// Falls back to the local UserDefaults cache on failure.
    @MainActor
    func fetchFromServer() async {
        isLoading = true
        error = nil
        do {
            let response: PaginatedResponse<ServerBooking> = try await APIClient.shared.get("/mobile/bookings")
            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let isoBasic = ISO8601DateFormatter()
            isoBasic.formatOptions = [.withInternetDateTime]

            reservations = response.data.map { b in
                let date = iso.date(from: b.eventDate)
                    ?? isoBasic.date(from: b.eventDate)
                    ?? Date()
                return StoredReservation(
                    id: b.ticketCode,
                    serverId: b.id,
                    placeTitle: b.placeTitle,
                    subtitle: b.subtitle,
                    imageName: b.imageName,
                    dateDisplay: b.dateDisplay,
                    timeDisplay: b.timeDisplay,
                    branch: b.branch,
                    qrPayload: b.qrPayload,
                    eventDate: date,
                    status: b.status,
                    usesForkSubtitleIcon: b.usesForkSubtitleIcon
                )
            }
            save() // cache locally for offline access
        } catch {
            self.error = error.localizedDescription
            // Keep whatever was loaded from UserDefaults
        }
        isLoading = false
    }

    /// Creates a booking on the server via POST /api/mobile/bookings.
    /// On failure the booking is saved to UserDefaults with a pendingSync flag
    /// so it can be retried later via `retryPendingSync()`.
    @MainActor
    func createBooking(
        placeTitle: String,
        subtitle: String,
        imageName: String,
        dateDisplay: String,
        timeDisplay: String,
        branch: String,
        eventDate: Date,
        usesForkSubtitleIcon: Bool
    ) async {
        let isoFormatter = ISO8601DateFormatter()
        let eventDateString = isoFormatter.string(from: eventDate)

        let body = CreateBookingBody(
            placeTitle: placeTitle,
            subtitle: subtitle,
            imageName: imageName,
            dateDisplay: dateDisplay,
            timeDisplay: timeDisplay,
            branch: branch,
            eventDate: eventDateString,
            usesForkSubtitleIcon: usesForkSubtitleIcon
        )

        do {
            let created: ServerBooking = try await APIClient.shared.post(
                "/mobile/bookings",
                body: body
            )
            let date = ISO8601DateFormatter().date(from: created.eventDate) ?? eventDate
            let entry = StoredReservation(
                id: created.ticketCode,
                serverId: created.id,
                placeTitle: created.placeTitle,
                subtitle: created.subtitle,
                imageName: created.imageName,
                dateDisplay: created.dateDisplay,
                timeDisplay: created.timeDisplay,
                branch: created.branch,
                qrPayload: created.qrPayload,
                eventDate: date,
                status: created.status,
                usesForkSubtitleIcon: created.usesForkSubtitleIcon
            )
            reservations.append(entry)
            save()
        } catch {
            self.error = error.localizedDescription

            // Offline fallback — save locally and queue for retry
            let pending = PendingBooking(
                placeTitle: placeTitle,
                subtitle: subtitle,
                imageName: imageName,
                dateDisplay: dateDisplay,
                timeDisplay: timeDisplay,
                branch: branch,
                eventDate: eventDateString,
                usesForkSubtitleIcon: usesForkSubtitleIcon
            )
            appendPendingBooking(pending)

            // Also add a local-only reservation so the user sees it immediately
            let qrPayload = BookingTicketCode.qrPayload(ticketCode: "LOCAL-\(UUID().uuidString.prefix(8))", place: placeTitle)
            let localEntry = StoredReservation(
                id: UUID().uuidString,
                placeTitle: placeTitle,
                subtitle: subtitle,
                imageName: imageName,
                dateDisplay: dateDisplay,
                timeDisplay: timeDisplay,
                branch: branch,
                qrPayload: qrPayload,
                eventDate: eventDate,
                status: "pending",
                usesForkSubtitleIcon: usesForkSubtitleIcon
            )
            reservations.append(localEntry)
            save()
        }
    }

    /// Retries all locally-stored pending bookings that failed to POST.
    /// Call on app launch or when connectivity is restored.
    @MainActor
    func retryPendingSync() async {
        var pending = loadPendingBookings()
        guard !pending.isEmpty else { return }

        var remaining: [PendingBooking] = []
        for booking in pending {
            let body = CreateBookingBody(
                placeTitle: booking.placeTitle,
                subtitle: booking.subtitle,
                imageName: booking.imageName,
                dateDisplay: booking.dateDisplay,
                timeDisplay: booking.timeDisplay,
                branch: booking.branch,
                eventDate: booking.eventDate,
                usesForkSubtitleIcon: booking.usesForkSubtitleIcon
            )
            do {
                let created: ServerBooking = try await APIClient.shared.post(
                    "/mobile/bookings",
                    body: body
                )
                let date = ISO8601DateFormatter().date(from: created.eventDate) ?? Date()
                let entry = StoredReservation(
                    id: created.ticketCode,
                    serverId: created.id,
                    placeTitle: created.placeTitle,
                    subtitle: created.subtitle,
                    imageName: created.imageName,
                    dateDisplay: created.dateDisplay,
                    timeDisplay: created.timeDisplay,
                    branch: created.branch,
                    qrPayload: created.qrPayload,
                    eventDate: date,
                    status: created.status,
                    usesForkSubtitleIcon: created.usesForkSubtitleIcon
                )
                // Replace the local-only entry if one exists for this place/date combo
                if let idx = reservations.firstIndex(where: {
                    $0.serverId == nil
                    && $0.placeTitle == booking.placeTitle
                    && $0.dateDisplay == booking.dateDisplay
                    && $0.timeDisplay == booking.timeDisplay
                }) {
                    reservations[idx] = entry
                } else {
                    reservations.append(entry)
                }
            } catch {
                remaining.append(booking)
            }
        }
        savePendingBookings(remaining)
        save()
    }

    // MARK: - Existing local booking registration (dev bypass / offline)

    func registerCompletedBookingIfNeeded(
        ticketCode: String,
        restaurant: Restaurant?,
        activity: Activity?,
        seasonEvent: SeasonEvent?,
        selectedDate: Date?,
        selectedTime: String,
        branch: String
    ) {
        let eventDate = selectedDate ?? Calendar.current.startOfDay(for: Date())
        guard !reservations.contains(where: { $0.id == ticketCode }) else { return }

        let placeTitle: String
        let subtitle: String
        let imageName: String
        let usesFork: Bool

        if let r = restaurant {
            placeTitle = r.name + " Restaurant"
            subtitle = r.cuisine
            imageName = r.imageName
            usesFork = true
        } else if let a = activity {
            placeTitle = a.name
            subtitle = a.category
            imageName = a.imageName
            usesFork = false
        } else if let e = seasonEvent {
            placeTitle = e.name
            subtitle = e.category
            imageName = e.imageName
            usesFork = false
        } else {
            placeTitle = "Booking"
            subtitle = ""
            imageName = "mrasem-logo"
            usesFork = false
        }

        let df = DateFormatter()
        df.dateFormat = "MMM d"
        let dateDisplay = df.string(from: eventDate)
        let qrPayload = BookingTicketCode.qrPayload(ticketCode: ticketCode, place: placeTitle)

        let entry = StoredReservation(
            id: ticketCode,
            placeTitle: placeTitle,
            subtitle: subtitle,
            imageName: imageName,
            dateDisplay: dateDisplay,
            timeDisplay: selectedTime,
            branch: branch,
            qrPayload: qrPayload,
            eventDate: eventDate,
            usesForkSubtitleIcon: usesFork
        )
        reservations.append(entry)
        save()
    }

    // MARK: - UserDefaults persistence (offline fallback)

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        if let decoded = try? JSONDecoder().decode([StoredReservation].self, from: data) {
            reservations = decoded
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(reservations) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    /// Clears persisted reservations (UserDefaults). Use from My Reservations menu when testing or resetting.
    func removeAllReservations() {
        reservations = []
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    func removeReservation(id: String) {
        reservations.removeAll { $0.id == id }
        save()
    }

    // MARK: - Pending bookings queue (UserDefaults)

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
}
