import Foundation

enum BookingTicketCode {
    /// 14-digit numeric id shown under the QR (matches Figma-style ticket numbers).
    static func new() -> String {
        (0..<14).map { _ in String(Int.random(in: 0...9)) }.joined()
    }

    static func qrPayload(ticketCode: String, place: String) -> String {
        "MRASEM|\(ticketCode)|\(place)"
    }
}
