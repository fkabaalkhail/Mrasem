import SwiftUI

// MARK: - Data

struct CarListing: Identifiable {
    let id = UUID().uuidString
    let name: String
    let category: String
    let passengers: Int
    let imageName: String
    var passengerLabel: String?
    var about: String = ""
    var detailCategory: String?
    /// Arabic display strings (Figma 1449:9865–9867, 348:3637+).
    var arabicName: String = ""
    var arabicAbout: String = ""
    var arabicPassengerLine: String = ""

    var displayPassengers: String {
        passengerLabel ?? "Up to \(passengers) passengers"
    }

    var displayCategory: String {
        detailCategory ?? category
    }

    func displayName(isArabic: Bool) -> String {
        if isArabic, !arabicName.isEmpty { return arabicName }
        return name
    }

    func displayAbout(isArabic: Bool) -> String {
        if isArabic, !arabicAbout.isEmpty { return arabicAbout }
        return about
    }

    func displayPassengersLine(isArabic: Bool) -> String {
        if isArabic, !arabicPassengerLine.isEmpty { return arabicPassengerLine }
        return displayPassengers
    }

    /// Subtitle under title on cards / detail (تجربة عادية، تجربة فاخرة، عائلي VIP).
    func displayListSubtitle(isArabic: Bool) -> String {
        if !isArabic { return displayCategory }
        if detailCategory == "VIP Family" { return "عائلي VIP" }
        switch category {
        case "Standard": return "تجربة عادية"
        case "Luxury": return "تجربة فاخرة"
        default: return displayCategory
        }
    }
}

// MARK: - Active filter chip labels (internal keys stay English for logic)

enum CarFilterKey {
    static func displayLabel(_ key: String, isArabic: Bool) -> String {
        if !isArabic { return key }
        switch key {
        case "Standard": return "عادية"
        case "Luxury": return "فاخرة"
        case "4 Passengers": return "٤ ركاب"
        case "7 Passengers": return "٧ ركاب"
        case "8-15 Passengers": return "٨–١٥ ركاب"
        default: return key
        }
    }
}

// MARK: - Main View

struct CarBookingView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var showSidePanel = false
    @State private var showCarFilter = false
    @State private var activeFilters: Set<String> = []

    private let allCars: [CarListing] = [
        CarListing(
            name: "Chevrolet Tahoe", category: "Standard", passengers: 7, imageName: "car-tahoe",
            about: "The Chevrolet Tahoe delivers a comfortable and reliable ride with a spacious interior and smooth performance. Ideal for families or groups, it's well suited for city trips, airport transfers, and longer journeys.",
            arabicName: "شفروليه تاهو",
            arabicAbout: "توفر شفروليه تاهو تجربة تنقل مريحة وموثوقة مع مقصورة واسعة وأداء سلس. تُعد خيارًا مناسبًا للعائلات والمجموعات، سواء للتنقل داخل المدينة، رحلات المطار، أو الرحلات الطويلة.",
            arabicPassengerLine: "تتسع لسبعة أشخاص"
        ),
        CarListing(
            name: "Ford Taurus", category: "Standard", passengers: 4, imageName: "car-taurus",
            about: "The Ford Taurus offers a comfortable and practical ride with a spacious interior and smooth handling. Ideal for everyday city travel, airport transfers, or small group trips, it combines reliability with ease of use.",
            arabicName: "فورد تورس",
            arabicAbout: "تقدم فورد تورس تجربة قيادة مريحة وعملية مع مقصورة واسعة وأداء سلس. تُعد خيارًا مثاليًا للتنقل اليومي داخل المدينة، رحلات المطار، أو الرحلات الجماعية الصغيرة، مع موثوقية وسهولة في الاستخدام.",
            arabicPassengerLine: "تتسع لأربعة أشخاص"
        ),
        CarListing(
            name: "GMC Yukon", category: "Standard", passengers: 7, imageName: "car-yukon",
            about: "The GMC Yukon offers a powerful and comfortable ride with a spacious interior and smooth performance. Ideal for families or groups, it's perfect for city travel, longer trips, or reliable everyday transportation.",
            arabicName: "جي إم سي يوكن",
            arabicAbout: "تقدم جي إم سي يوكن تجربة تنقل قوية ومريحة مع مقصورة واسعة وأداء سلس. تُعد خيارًا مثاليًا للعائلات والمجموعات، ومناسبة للتنقل داخل المدينة، الرحلات الطويلة، أو الاستخدام اليومي.",
            arabicPassengerLine: "تتسع لسبعة أشخاص"
        ),
        CarListing(
            name: "BMW 7 Series", category: "Luxury", passengers: 4, imageName: "car-bmw7",
            about: "BMW 7 Series offers a luxury driving experience with refined comfort and advanced technology. Featuring a spacious, premium interior, smooth performance, and elegant design, it's ideal for business trips, special occasions, or a first-class city ride.",
            arabicName: "بي إم دبليو 7 سيريز",
            arabicAbout: "يقدم بي إم دبليو الفئة السابعة تجربة قيادة فاخرة مع راحة متقنة وتقنيات متقدمة. مقصورة واسعة وفخمة وتصميم أنيق، مثالية لرحلات العمل، المناسبات الخاصة، أو التنقل المميز داخل المدينة.",
            arabicPassengerLine: "تتسع لأربعة أشخاص"
        ),
        CarListing(
            name: "Mercedes-Benz S-Class", category: "Luxury", passengers: 4, imageName: "car-sclass",
            about: "The Mercedes-Benz S-Class defines ultimate luxury with exceptional comfort, cutting edge technology, and a refined, spacious interior. Designed for smooth, effortless rides, it's perfect for VIP transfers, business travel, or special occasions where elegance matters.",
            arabicName: "مرسيدس بنز الفئة S",
            arabicAbout: "تمثل مرسيدس بنز الفئة S رمز الفخامة بامتياز مع راحة استثنائية وتقنية متطورة وتجربة قيادة انسيابية راقية. مثالية لنقل كبار الشخصيات ورحلات الأعمال أو المناسبات الخاصة.",
            arabicPassengerLine: "تتسع لأربعة أشخاص"
        ),
        CarListing(
            name: "Lucid Air", category: "Luxury", passengers: 4, imageName: "car-lucid-air",
            about: "Lucid Air delivers a modern luxury experience with a sleek design, ultra smooth performance, and a spacious, high tech interior. Fully electric and whisper quiet, it's ideal for eco conscious travelers seeking comfort, innovation, and a refined city ride.",
            arabicName: "لوسيد إير",
            arabicAbout: "يقدّم لوسيد إير تجربة فاخرة عصرية بتصميم أنيق وأداء فائق السلاسة ومقصورة واسعة بتقنيات متقدمة. كهربائي بالكامل وهادئ للغاية، مثالي لمن يبحثون عن الراحة والابتكار والتنقل الراقي داخل المدينة.",
            arabicPassengerLine: "تتسع لأربعة أشخاص"
        ),
        CarListing(
            name: "Mercedes-Benz V-Class", category: "Luxury", passengers: 8, imageName: "car-vclass", passengerLabel: "Up to 8 passengers",
            about: "The Mercedes-Benz V-Class offers a spacious and comfortable ride, ideal for families and groups. With a refined interior, flexible seating, and smooth performance, it's perfect for city travel, tours, or relaxed group transportation with a touch of elegance.",
            detailCategory: "VIP Family",
            arabicName: "مرسيدس بنز V-Class",
            arabicAbout: "توفر مرسيدس بنز V-Class رحلة واسعة ومريحة، مثالية للعائلات والمجموعات. مع مقصورة فاخرة، مقاعد مرنة، وأداء سلس، فهي الخيار الأمثل للتنقّل داخل المدينة، الجولات، أو النقل الفاخر للمجموعات.",
            arabicPassengerLine: "تتسع لثمانية أشخاص"
        ),
        CarListing(
            name: "VIP Mini Bus", category: "Luxury", passengers: 15, imageName: "car-vip-minibus", passengerLabel: "15-20 passengers",
            about: "The VIP Mini Bus is designed for comfortable group travel, offering spacious seating, premium interiors, and a smooth ride. Ideal for families, corporate groups, events, and tours, it ensures a relaxed and elevated travel experience.",
            detailCategory: "VIP Family",
            arabicName: "حافلة VIP",
            arabicAbout: "توفر حافلة VIP تجربة تنقّل مريحة للمجموعات، مع مقاعد واسعة ومقصورة فاخرة وقيادة سلسة. تُعد خيارًا مثاليًا للعائلات، مجموعات العمل، الفعاليات، والجولات، لتجربة تنقّل راقية ومريحة.",
            arabicPassengerLine: "تتسع لـ 15-20 شخصًا"
        ),
    ]

    private var filteredCars: [CarListing] {
        guard !activeFilters.isEmpty else { return allCars }
        return allCars.filter { car in
            var categoryMatch = true
            var passengerMatch = true

            if activeFilters.contains("Standard") || activeFilters.contains("Luxury") {
                let wantStandard = activeFilters.contains("Standard")
                let wantLuxury = activeFilters.contains("Luxury")
                categoryMatch = (wantStandard && car.category == "Standard") ||
                    (wantLuxury && car.category == "Luxury")
            }

            let passengerFilters = activeFilters.filter { $0.contains("Passengers") }
            if !passengerFilters.isEmpty {
                passengerMatch = passengerFilters.contains(where: { f in
                    switch f {
                    case "4 Passengers": return car.passengers <= 4
                    case "7 Passengers": return car.passengers >= 5 && car.passengers <= 7
                    case "8-15 Passengers": return car.passengers >= 8
                    default: return true
                    }
                })
            }

            return categoryMatch && passengerMatch
        }
    }

    private let brandBrown = Color(red: 0x31 / 255, green: 0x23 / 255, blue: 0x1B / 255)
    private let pageBg = Color(red: 0xF3 / 255, green: 0xF3 / 255, blue: 0xF3 / 255)
    private let searchGray = Color(red: 0xC4 / 255, green: 0xC4 / 255, blue: 0xC4 / 255)
    private let darkGreen = Color(red: 0x21 / 255, green: 0x3C / 255, blue: 0x2E / 255)

    private var isArabic: Bool { languageManager.current == .arabic }

    var body: some View {
        ZStack(alignment: .top) {
            pageBg.ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                carFilterTriggerBar
                carListSection
                Spacer(minLength: 0)
                bottomTabBar
            }

            if showSidePanel {
                SidePanelView(isOpen: $showSidePanel)
                    .transition(.opacity)
                    .zIndex(1)
            }

            if showCarFilter {
                CarFilterPopupView(isPresented: $showCarFilter, activeFilters: $activeFilters)
                    .transition(.move(edge: .bottom))
                    .zIndex(2)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showCarFilter)
        .navigationBarHidden(true)
    }

    // MARK: - Header (Figma 348:4175 / 354:5576 — 228pt brown; Arabic: menu leading, greeting center, profile trailing)

    private var greetingText: String {
        isArabic ? "أهلا \(AuthenticationManager.shared.userName ?? AuthenticationManager.shared.phoneNumber ?? "")!" : "Hi \(AuthenticationManager.shared.userName ?? AuthenticationManager.shared.phoneNumber ?? "")"
    }

    private var searchPlaceholder: String {
        isArabic ? "ابحث" : "Search"
    }

    private var headerSection: some View {
        ZStack(alignment: .top) {
            brandBrown.ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                ZStack {
                    HStack(spacing: 8) {
                        if isArabic {
                            headerMenuButton
                            Spacer(minLength: 0)
                            headerProfileButton
                        } else {
                            headerProfileButton
                            Spacer(minLength: 0)
                            headerMenuButton
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)

                    Text(greetingText)
                        .font(.custom("ExpoArabic-Medium", size: 12))
                        .foregroundColor(.white)
                }

                Group {
                    if isArabic {
                        HStack(spacing: 8) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) { showCarFilter = true }
                            }) {
                                Image("group129")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 26)
                            }
                            Spacer()
                            Text(searchPlaceholder)
                                .font(.custom("ExpoArabic-Medium", size: 12))
                                .foregroundColor(searchGray)
                            Image("group")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 14, height: 14)
                        }
                    } else {
                        HStack(spacing: 8) {
                            Image("group")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 14, height: 14)
                            Text(searchPlaceholder)
                                .font(.custom("ExpoArabic-Medium", size: 12))
                                .foregroundColor(searchGray)
                            Spacer()
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) { showCarFilter = true }
                            }) {
                                Image("group129")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 26)
                            }
                        }
                    }
                }
                .padding(.horizontal, 15)
                .frame(width: 327, height: 43)
                .background(Color.white)
                .cornerRadius(9)
                .padding(.top, 24)

                Spacer(minLength: 0)
            }
        }
        .frame(height: 228)
    }

    private var headerProfileButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.25)) { showSidePanel = true }
        }) {
            ZStack {
                Image("ellipse4").resizable().frame(width: 42, height: 42)
                Image("ellipse5").resizable().frame(width: 38, height: 38)
                Image("layer2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
            }
        }
    }

    private var headerMenuButton: some View {
        Button(action: {}) {
            Image("group2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 20)
        }
    }

    // MARK: - Filter chips (Figma 955:1865+ — white 38×h, 8pt radius, × dismiss, filter icon with badge)

    private var carFilterTriggerBar: some View {
        Group {
            if activeFilters.isEmpty {
                HStack(spacing: 12) {
                    filterIconButton(showBadge: false)
                    Text(isArabic ? "تصفية المركبات" : "Filter vehicles")
                        .font(.custom("ExpoArabic-Medium", size: 12))
                        .foregroundColor(darkGreen.opacity(0.45))
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 21)
                .padding(.vertical, 12)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(activeFilters).sorted(), id: \.self) { key in
                            activeFilterChip(key)
                        }
                        filterIconButton(showBadge: true)
                    }
                    .padding(.horizontal, 21)
                    .padding(.vertical, 10)
                }
                .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            }
        }
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
    }

    private func filterIconButton(showBadge: Bool) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) { showCarFilter = true }
        }) {
            ZStack(alignment: .topTrailing) {
                Image("car-filter-icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 31, height: 31)
                if showBadge {
                    Circle()
                        .fill(Color(red: 0xF7 / 255, green: 0x44 / 255, blue: 0x40 / 255))
                        .frame(width: 7, height: 7)
                        .offset(x: 2, y: -1)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func activeFilterChip(_ key: String) -> some View {
        HStack(spacing: 6) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    _ = activeFilters.remove(key)
                }
            }) {
                Image("car-chip-close")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14, height: 14)
            }
            .buttonStyle(.plain)

            Text(CarFilterKey.displayLabel(key, isArabic: isArabic))
                .font(.custom("ExpoArabic-Medium", size: 16))
                .foregroundColor(darkGreen)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .padding(.horizontal, 10)
        .frame(height: 38)
        .background(Color.white)
        .cornerRadius(8)
    }

    // MARK: - Car List

    private var carListSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(filteredCars) { car in
                    NavigationLink(destination: CarDetailView(car: car)) {
                        CarCard(car: car, darkGreen: darkGreen, isArabic: isArabic)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 21)
            .padding(.top, 6)
        }
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
    }

    // MARK: - Bottom Tab Bar

    private var bottomTabBar: some View {
        ZStack {
            brandBrown.ignoresSafeArea(edges: .bottom)
            HStack(spacing: 0) {
                Spacer()
                NavigationLink(destination: CategorySelectionView()) {
                    Image("nav-icon-home").resizable().renderingMode(.original).aspectRatio(contentMode: .fit).frame(width: 20, height: 22)
                }.buttonStyle(PlainButtonStyle())
                Spacer()
                BookingsCalendarNavigationLink()
                Spacer()
                tabIcon("nav-icon-grid", w: 20, h: 20)
                Spacer()
                TicketsNavigationLink(width: 23, height: 18)
                Spacer()
                InvitationsNavigationLink(width: 20, height: 20)
                Spacer()
            }
            .padding(.top, 8)
        }
        .frame(height: 50)
        .environment(\.layoutDirection, .leftToRight)
    }

    private func tabIcon(_ name: String, w: CGFloat, h: CGFloat) -> some View {
        Button(action: {}) {
            Image(name).resizable().renderingMode(.original).aspectRatio(contentMode: .fit).frame(width: w, height: h)
        }
    }
}

// MARK: - Car Card (258×363, 22pt corners)

struct CarCard: View {
    let car: CarListing
    let darkGreen: Color
    var isArabic: Bool = false

    var body: some View {
        VStack(alignment: isArabic ? .trailing : .leading, spacing: 0) {
            Image(car.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 242, height: 207)
                .clipped()
                .cornerRadius(17)
                .padding(.top, 9)
                .padding(.horizontal, 8)

            Text(car.displayName(isArabic: isArabic))
                .font(.custom("ExpoArabic-Medium", size: 20))
                .foregroundColor(.black)
                .lineLimit(2)
                .multilineTextAlignment(isArabic ? .trailing : .leading)
                .padding(.top, 14)
                .padding(.horizontal, 8)

            Text(car.displayListSubtitle(isArabic: isArabic))
                .font(.custom("ExpoArabic-Medium", size: 12))
                .foregroundColor(darkGreen.opacity(0.58))
                .multilineTextAlignment(isArabic ? .trailing : .leading)
                .padding(.top, 4)
                .padding(.horizontal, 8)

            HStack(spacing: 6) {
                if isArabic {
                    Text(car.displayPassengersLine(isArabic: true))
                        .font(.custom("ExpoArabic-Medium", size: 12))
                        .foregroundColor(darkGreen)
                    Image("car-passenger-icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)
                } else {
                    Image("car-passenger-icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)
                    Text(car.displayPassengersLine(isArabic: false))
                        .font(.custom("ExpoArabic-Medium", size: 12))
                        .foregroundColor(darkGreen)
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 8)
            .padding(.bottom, 14)
        }
        .frame(width: 258)
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.06), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        CarBookingView()
            .environmentObject(LanguageManager())
            .environmentObject(InvitationStore())
    }
}
