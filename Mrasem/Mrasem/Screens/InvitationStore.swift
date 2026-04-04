import Combine
import Foundation
import SwiftUI

// MARK: - Models

enum SentInvitationOutcome: String, Codable {
    case pending
    case accepted
    case declined
}

struct SentInvitation: Codable, Identifiable, Equatable {
    let id: String
    var outcome: SentInvitationOutcome
    let placeTitle: String
    let subtitle: String
    let imageName: String
    let dateDisplay: String
    let timeDisplay: String
    let branch: String
    let recipientPhone: String
}

enum ReceivedInvitationResponse: String, Codable {
    case awaiting
    case accepted
    case declined
}

struct ReceivedInvitation: Codable, Identifiable, Equatable, Hashable {
    let id: String
    var userResponse: ReceivedInvitationResponse
    let placeTitle: String
    let subtitle: String
    let imageName: String
    let dateDisplay: String
    let timeDisplay: String
    let branch: String
    let inviterPhone: String
    /// When set, accepting/declining updates the matching sent invitation (demo sync).
    var linkedSentId: String?
}

// MARK: - Pending Invitation (offline fallback)

/// Invitation payload saved to UserDefaults when the POST fails. Queued for retry.
struct PendingInvitation: Codable, Equatable {
    let recipientPhone: String
    let placeTitle: String
    let subtitle: String
    let imageName: String
    let dateDisplay: String
    let timeDisplay: String
    let branch: String
}

// MARK: - Server response types (private)

/// Request body for POST /api/mobile/invitations.
private struct CreateInvitationBody: Encodable {
    let recipientPhone: String
    let placeTitle: String
    let subtitle: String
    let imageName: String
    let dateDisplay: String
    let timeDisplay: String
    let branch: String
}

/// Request body for PATCH /api/mobile/invitations/:id/respond.
private struct RespondInvitationBody: Encodable {
    let response: String
}

/// Server response shape for a sent invitation (POST response).
private struct ServerSentInvitation: Decodable {
    let id: String
    let outcome: String
    let placeTitle: String
    let subtitle: String
    let imageName: String
    let dateDisplay: String
    let timeDisplay: String
    let branch: String
    let recipientPhone: String
}

/// Server response shape for a received invitation (PATCH response).
private struct ServerReceivedInvitation: Decodable {
    let id: String
    let userResponse: String
    let placeTitle: String
    let subtitle: String
    let imageName: String
    let dateDisplay: String
    let timeDisplay: String
    let branch: String
    let inviterPhone: String
}

// MARK: - Store

final class InvitationStore: ObservableObject {
    @Published private(set) var sentInvitations: [SentInvitation] = []
    @Published private(set) var receivedInvitations: [ReceivedInvitation] = []
    @Published var isLoading = false
    @Published var error: String?

    private let sentKey = "mrasem.invitations.sent.v1"
    private let receivedKey = "mrasem.invitations.received.v1"
    private let membersKey = "mrasem.invitations.mrasemMembers.v1"
    private let pendingSyncKey = "mrasem.pendingInvitations.v1"

    init(previewSent: [SentInvitation]? = nil, previewReceived: [ReceivedInvitation]? = nil) {
        if let previewSent, let previewReceived {
            sentInvitations = previewSent
            receivedInvitations = previewReceived
            return
        }
        load()
        seedMrasemMembersIfNeeded()
    }

    /// E.164-style normalization for comparisons and storage.
    static func normalizePhone(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let digits = trimmed.filter { $0.isNumber }
        if digits.isEmpty { return trimmed }
        if trimmed.hasPrefix("+") { return "+\(digits)" }
        if digits.hasPrefix("966") { return "+\(digits)" }
        if digits.hasPrefix("0") { return "+966\(digits.dropFirst())" }
        return "+\(digits)"
    }

    /// Public web URL to invite someone who is not yet on Mrasem (SMS / share sheet).
    static func appInviteURL(forPhone normalized: String) -> URL {
        let enc = normalized.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://mrasem.com/join?phone=\(enc)")!
    }

    /// Phones treated as existing Mrasem users (no green "Invite" in contact list). Replace with API results later.
    func isMrasemMember(phone: String) -> Bool {
        let n = Self.normalizePhone(phone)
        return mrasemMemberPhones.contains(n)
    }

    private var mrasemMemberPhones: Set<String> {
        guard let arr = UserDefaults.standard.array(forKey: membersKey) as? [String] else {
            return []
        }
        return Set(arr.map { Self.normalizePhone($0) })
    }

    private func seedMrasemMembersIfNeeded() {
        guard UserDefaults.standard.object(forKey: membersKey) == nil else { return }
        let seed = ["+966555010301", "+966555010302"]
        UserDefaults.standard.set(seed, forKey: membersKey)
    }

    // MARK: - Server sync: Fetch

    /// Fetches the authenticated user's sent invitations from GET /api/mobile/invitations/sent.
    /// Falls back to the local UserDefaults cache on failure.
    @MainActor
    func fetchSent() async {
        isLoading = true
        error = nil
        do {
            let response: PaginatedResponse<SentInvitation> = try await APIClient.shared.get("/mobile/invitations/sent")
            sentInvitations = response.data
            save()
        } catch {
            self.error = error.localizedDescription
            // Keep whatever was loaded from UserDefaults
        }
        isLoading = false
    }

    /// Fetches the authenticated user's received invitations from GET /api/mobile/invitations/received.
    /// Falls back to the local UserDefaults cache on failure.
    @MainActor
    func fetchReceived() async {
        isLoading = true
        error = nil
        do {
            let response: PaginatedResponse<ReceivedInvitation> = try await APIClient.shared.get("/mobile/invitations/received")
            receivedInvitations = response.data
            save()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Send invite (server sync with offline fallback)

    func sendInvite(recipientPhone: String) {
        sendInvite(
            recipientPhone: recipientPhone,
            placeTitle: "Myazu Restaurant",
            subtitle: "Japanese, Sushi",
            imageName: "restaurant-myazu",
            branch: "Albasateen Mall, Alrawdha",
            eventDate: Calendar.current.startOfDay(for: Date()),
            timeDisplay: "8:00PM"
        )
    }

    func sendInvite(
        recipientPhone: String,
        placeTitle: String,
        subtitle: String,
        imageName: String,
        branch: String,
        eventDate: Date,
        timeDisplay: String
    ) {
        let phone = Self.normalizePhone(recipientPhone)
        guard phone.count >= 10 else { return }
        let df = DateFormatter()
        df.dateFormat = "MMM d"
        let dateDisplay = df.string(from: eventDate)

        // Fire-and-forget async POST; the method signature stays synchronous for view compatibility
        Task { @MainActor in
            await sendInviteToServer(
                recipientPhone: phone,
                placeTitle: placeTitle,
                subtitle: subtitle,
                imageName: imageName,
                dateDisplay: dateDisplay,
                timeDisplay: timeDisplay,
                branch: branch
            )
        }
    }

    /// Attempts POST /api/mobile/invitations. On failure, falls back to local storage.
    @MainActor
    private func sendInviteToServer(
        recipientPhone: String,
        placeTitle: String,
        subtitle: String,
        imageName: String,
        dateDisplay: String,
        timeDisplay: String,
        branch: String
    ) async {
        let body = CreateInvitationBody(
            recipientPhone: recipientPhone,
            placeTitle: placeTitle,
            subtitle: subtitle,
            imageName: imageName,
            dateDisplay: dateDisplay,
            timeDisplay: timeDisplay,
            branch: branch
        )

        do {
            let created: ServerSentInvitation = try await APIClient.shared.post(
                "/mobile/invitations",
                body: body
            )
            let item = SentInvitation(
                id: created.id,
                outcome: SentInvitationOutcome(rawValue: created.outcome) ?? .pending,
                placeTitle: created.placeTitle,
                subtitle: created.subtitle,
                imageName: created.imageName,
                dateDisplay: created.dateDisplay,
                timeDisplay: created.timeDisplay,
                branch: created.branch,
                recipientPhone: created.recipientPhone
            )
            sentInvitations.append(item)
            save()
        } catch {
            self.error = error.localizedDescription

            // Offline fallback — save locally and queue for retry
            let pending = PendingInvitation(
                recipientPhone: recipientPhone,
                placeTitle: placeTitle,
                subtitle: subtitle,
                imageName: imageName,
                dateDisplay: dateDisplay,
                timeDisplay: timeDisplay,
                branch: branch
            )
            appendPendingInvitation(pending)

            // Also add a local-only sent invitation so the user sees it immediately
            let sentId = UUID().uuidString
            let localItem = SentInvitation(
                id: sentId,
                outcome: .pending,
                placeTitle: placeTitle,
                subtitle: subtitle,
                imageName: imageName,
                dateDisplay: dateDisplay,
                timeDisplay: timeDisplay,
                branch: branch,
                recipientPhone: recipientPhone
            )
            sentInvitations.append(localItem)

            // Demo: same device also gets a "received" copy so you can open Respond flow
            let received = ReceivedInvitation(
                id: UUID().uuidString,
                userResponse: .awaiting,
                placeTitle: placeTitle,
                subtitle: subtitle,
                imageName: imageName,
                dateDisplay: dateDisplay,
                timeDisplay: timeDisplay,
                branch: branch,
                inviterPhone: "+966559035417",
                linkedSentId: sentId
            )
            receivedInvitations.append(received)
            save()
        }
    }

    /// Retries all locally-stored pending invitations that failed to POST.
    /// Call on app launch or when connectivity is restored.
    @MainActor
    func retryPendingSync() async {
        var pending = loadPendingInvitations()
        guard !pending.isEmpty else { return }

        var remaining: [PendingInvitation] = []
        for invitation in pending {
            let body = CreateInvitationBody(
                recipientPhone: invitation.recipientPhone,
                placeTitle: invitation.placeTitle,
                subtitle: invitation.subtitle,
                imageName: invitation.imageName,
                dateDisplay: invitation.dateDisplay,
                timeDisplay: invitation.timeDisplay,
                branch: invitation.branch
            )
            do {
                let _: ServerSentInvitation = try await APIClient.shared.post(
                    "/mobile/invitations",
                    body: body
                )
            } catch {
                remaining.append(invitation)
            }
        }
        savePendingInvitations(remaining)
    }

    // MARK: - Respond to invitation (server sync)

    func applyReceivedResponse(invitationId: String, accept: Bool) {
        guard let idx = receivedInvitations.firstIndex(where: { $0.id == invitationId }) else { return }

        // Optimistic local update
        var recv = receivedInvitations
        recv[idx].userResponse = accept ? .accepted : .declined
        var sent = sentInvitations
        if let link = recv[idx].linkedSentId,
           let sIdx = sent.firstIndex(where: { $0.id == link }) {
            sent[sIdx].outcome = accept ? .accepted : .declined
        }
        receivedInvitations = recv
        sentInvitations = sent
        save()

        // Fire-and-forget PATCH to server
        Task { @MainActor in
            await respondOnServer(invitationId: invitationId, accept: accept)
        }
    }

    /// Sends PATCH /api/mobile/invitations/:id/respond to the server.
    @MainActor
    private func respondOnServer(invitationId: String, accept: Bool) async {
        let body = RespondInvitationBody(response: accept ? "accepted" : "declined")
        do {
            let _: ServerReceivedInvitation = try await APIClient.shared.patch(
                "/mobile/invitations/\(invitationId)/respond",
                body: body
            )
        } catch {
            self.error = error.localizedDescription
            // Local state already updated optimistically; server will sync on next fetch
        }
    }

    // MARK: - Demo data

    /// Triple-tap the Invitations title to load sample **Sent** (pending / accepted / declined) + **Received** (awaiting).
    func loadDemoDataset() {
        let pendingId = UUID().uuidString
        let acceptedId = UUID().uuidString
        let declinedId = UUID().uuidString
        let receivedAwaitingId = UUID().uuidString

        sentInvitations = [
            SentInvitation(
                id: pendingId,
                outcome: .pending,
                placeTitle: "Myazu Restaurant",
                subtitle: "Japanese, Sushi",
                imageName: "restaurant-myazu",
                dateDisplay: "Jan 3",
                timeDisplay: "8:00PM",
                branch: "Albasateen Mall, Alrawdha",
                recipientPhone: "+966588762140"
            ),
            SentInvitation(
                id: acceptedId,
                outcome: .accepted,
                placeTitle: "Myazu Restaurant",
                subtitle: "Japanese, Sushi",
                imageName: "restaurant-myazu",
                dateDisplay: "Jan 3",
                timeDisplay: "8:00PM",
                branch: "Albasateen Mall, Alrawdha",
                recipientPhone: "+966500111222"
            ),
            SentInvitation(
                id: declinedId,
                outcome: .declined,
                placeTitle: "Myazu Restaurant",
                subtitle: "Japanese, Sushi",
                imageName: "restaurant-myazu",
                dateDisplay: "Jan 3",
                timeDisplay: "8:00PM",
                branch: "Albasateen Mall, Alrawdha",
                recipientPhone: "+966500333444"
            ),
        ]

        receivedInvitations = [
            ReceivedInvitation(
                id: receivedAwaitingId,
                userResponse: .awaiting,
                placeTitle: "Khemah The Groves",
                subtitle: "Outdoor dining",
                imageName: "riyadh-khemah-groves",
                dateDisplay: "Feb 12",
                timeDisplay: "7:00PM",
                branch: "Riyadh Park",
                inviterPhone: "+966555010203",
                linkedSentId: nil
            ),
        ]
        save()
    }

    // MARK: - UserDefaults persistence (offline fallback)

    private func load() {
        if let d = UserDefaults.standard.data(forKey: sentKey),
           let s = try? JSONDecoder().decode([SentInvitation].self, from: d) {
            sentInvitations = s
        }
        if let d = UserDefaults.standard.data(forKey: receivedKey),
           let r = try? JSONDecoder().decode([ReceivedInvitation].self, from: d) {
            receivedInvitations = r
        }
    }

    private func save() {
        if let d = try? JSONEncoder().encode(sentInvitations) {
            UserDefaults.standard.set(d, forKey: sentKey)
        }
        if let d = try? JSONEncoder().encode(receivedInvitations) {
            UserDefaults.standard.set(d, forKey: receivedKey)
        }
    }

    // MARK: - Pending invitations queue (UserDefaults)

    private func loadPendingInvitations() -> [PendingInvitation] {
        guard let data = UserDefaults.standard.data(forKey: pendingSyncKey) else { return [] }
        return (try? JSONDecoder().decode([PendingInvitation].self, from: data)) ?? []
    }

    private func savePendingInvitations(_ invitations: [PendingInvitation]) {
        if invitations.isEmpty {
            UserDefaults.standard.removeObject(forKey: pendingSyncKey)
        } else if let data = try? JSONEncoder().encode(invitations) {
            UserDefaults.standard.set(data, forKey: pendingSyncKey)
        }
    }

    private func appendPendingInvitation(_ invitation: PendingInvitation) {
        var pending = loadPendingInvitations()
        pending.append(invitation)
        savePendingInvitations(pending)
    }
}
