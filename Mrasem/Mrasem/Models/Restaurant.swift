import Foundation

/// Restaurant from the API. **`id` is the canonical identifier** — one row per venue.
/// Localized fields (`name` vs `arabicName`, etc.) are display only; bookings, slots, and URLs must always use `id`
/// so the same restaurant is never treated as two entities when the app language changes.
struct Restaurant: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let arabicName: String
    let rating: Double
    let cuisine: String
    let arabicCuisine: String
    let imageName: String
    let hasMichelin: Bool
    let description: String
    let arabicDescription: String
    let city: String
    let arabicCity: String

    init(
        id: Int = 0,
        name: String,
        arabicName: String,
        rating: Double,
        cuisine: String,
        arabicCuisine: String,
        imageName: String,
        hasMichelin: Bool,
        description: String,
        arabicDescription: String,
        city: String = "Jeddah",
        arabicCity: String = "جدة"
    ) {
        self.id = id
        self.name = name
        self.arabicName = arabicName
        self.rating = rating
        self.cuisine = cuisine
        self.arabicCuisine = arabicCuisine
        self.imageName = imageName
        self.hasMichelin = hasMichelin
        self.description = description
        self.arabicDescription = arabicDescription
        self.city = city
        self.arabicCity = arabicCity
    }
}
