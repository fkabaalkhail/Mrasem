import Foundation

struct SeasonEvent: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let category: String
    let imageName: String
    let location: String
    let description: String
    let city: String
    let arabicName: String?
    let arabicCategory: String?
    let arabicDescription: String?
    let arabicLocation: String?

    init(
        id: Int = 0,
        name: String,
        category: String,
        imageName: String,
        location: String,
        description: String,
        city: String = "Jeddah",
        arabicName: String? = nil,
        arabicCategory: String? = nil,
        arabicDescription: String? = nil,
        arabicLocation: String? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.imageName = imageName
        self.location = location
        self.description = description
        self.city = city
        self.arabicName = arabicName
        self.arabicCategory = arabicCategory
        self.arabicDescription = arabicDescription
        self.arabicLocation = arabicLocation
    }
}

extension SeasonEvent {
    func displayTitle(isArabic: Bool) -> String {
        if isArabic {
            if let a = arabicName?.trimmingCharacters(in: .whitespacesAndNewlines), !a.isEmpty { return a }
            if let f = PublicListingArabicFallback.seasonEventStrings(name: name) { return f.title }
        }
        return name
    }

    func displayCategory(isArabic: Bool) -> String {
        if isArabic {
            if let a = arabicCategory?.trimmingCharacters(in: .whitespacesAndNewlines), !a.isEmpty { return a }
            if let f = PublicListingArabicFallback.seasonEventStrings(name: name) { return f.category }
        }
        return category
    }

    func displayDescription(isArabic: Bool) -> String {
        if isArabic, let a = arabicDescription?.trimmingCharacters(in: .whitespacesAndNewlines), !a.isEmpty { return a }
        return description
    }

    func displayLocation(isArabic: Bool) -> String {
        if isArabic {
            if let a = arabicLocation?.trimmingCharacters(in: .whitespacesAndNewlines), !a.isEmpty { return a }
            if let f = PublicListingArabicFallback.seasonEventStrings(name: name) { return f.location }
        }
        return location
    }
}
