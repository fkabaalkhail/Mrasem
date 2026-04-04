import Foundation

/// Activity from the API. **`id` is the canonical identifier** — one row per activity.
/// Use `id` for bookings and favorites; do not key by `name`/`category`, which may be localized per language.
struct Activity: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let rating: Double
    let category: String
    let imageName: String
    let location: String
    let description: String
    let city: String
    let arabicName: String?
    let arabicCategory: String?
    let arabicDescription: String?
    let arabicLocation: String?
    /// Optional safety copy (Figma activity detail — e.g. 1449:9860). Omitted in JSON → `nil`.
    let safetyGuidelines: String?
    let arabicSafetyGuidelines: String?

    init(
        id: Int = 0,
        name: String,
        rating: Double,
        category: String,
        imageName: String,
        location: String,
        description: String,
        city: String = "Jeddah",
        arabicName: String? = nil,
        arabicCategory: String? = nil,
        arabicDescription: String? = nil,
        arabicLocation: String? = nil,
        safetyGuidelines: String? = nil,
        arabicSafetyGuidelines: String? = nil
    ) {
        self.id = id
        self.name = name
        self.rating = rating
        self.category = category
        self.imageName = imageName
        self.location = location
        self.description = description
        self.city = city
        self.arabicName = arabicName
        self.arabicCategory = arabicCategory
        self.arabicDescription = arabicDescription
        self.arabicLocation = arabicLocation
        self.safetyGuidelines = safetyGuidelines
        self.arabicSafetyGuidelines = arabicSafetyGuidelines
    }
}

extension Activity {
    /// Arabic: prefer bundled Figma/context strings (`PublicListingArabicFallback`) so copy matches design; then API fields; then English.
    func displayTitle(isArabic: Bool) -> String {
        if isArabic {
            if let f = PublicListingArabicFallback.activityStrings(name: name, city: city) { return f.title }
            if let a = arabicName?.trimmingCharacters(in: .whitespacesAndNewlines), !a.isEmpty { return a }
        }
        return name
    }

    func displayCategory(isArabic: Bool) -> String {
        if isArabic {
            if let f = PublicListingArabicFallback.activityStrings(name: name, city: city) { return f.category }
            if let a = arabicCategory?.trimmingCharacters(in: .whitespacesAndNewlines), !a.isEmpty { return a }
        }
        return category
    }

    func displayDescription(isArabic: Bool) -> String {
        if isArabic {
            if let f = PublicListingArabicFallback.activityStrings(name: name, city: city) { return f.description }
            if let a = arabicDescription?.trimmingCharacters(in: .whitespacesAndNewlines), !a.isEmpty { return a }
        }
        return description
    }

    func displayLocation(isArabic: Bool) -> String {
        if isArabic {
            if let f = PublicListingArabicFallback.activityStrings(name: name, city: city) { return f.location }
            if let a = arabicLocation?.trimmingCharacters(in: .whitespacesAndNewlines), !a.isEmpty { return a }
        }
        return location
    }

    /// Safety / liability copy when present (API, then bundled fallbacks for Jeddah catalog — Figma 1449:9860).
    func displaySafetyGuidelines(isArabic: Bool) -> String? {
        let fromModel: String? = {
            let raw = isArabic ? arabicSafetyGuidelines : safetyGuidelines
            let t = raw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return t.isEmpty ? nil : t
        }()
        if let fromModel { return fromModel }
        return PublicListingArabicFallback.activitySafetyGuidelines(name: name, city: city, isArabic: isArabic)
    }
}
