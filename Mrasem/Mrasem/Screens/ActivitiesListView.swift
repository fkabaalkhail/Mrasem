import SwiftUI

/// Activities & tours — List: same mini `ActivityGridCard` grid + nearby row for **English and Arabic** (no Mecca-only hero). Copy: `Activity` + `PublicListingArabicFallback` (Figma detail strings).
// MARK: - Color helper

private extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
    static let mrasemBrown = Color(hex: 0x31231B)
    static let pageBg      = Color(hex: 0xF3F3F3)
    static let darkGreen   = Color(hex: 0x213C2E)
    static let searchGray  = Color(hex: 0xC4C4C4)
}

// MARK: - Main View

struct ActivitiesListView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var favorites: Set<Int> = []
    @State private var searchText: String = ""
    @State private var showSidePanel = false
    @State private var showFilterPopup = false
    @State private var selectedCity: String = "Jeddah"
    @State private var store = StorePrefetch.activities

    private var activities: [Activity] {
        let all = store.activities
        guard !searchText.isEmpty else { return all }
        let q = searchText.lowercased()
        return all.filter {
            $0.displayTitle(isArabic: false).lowercased().contains(q) ||
            $0.displayTitle(isArabic: true).contains(q) ||
            $0.displayCategory(isArabic: false).lowercased().contains(q) ||
            $0.displayCategory(isArabic: true).contains(q)
        }
    }

    private var gridActivities: [Activity] { activities }

    private var row1: [Activity] {
        Array(gridActivities.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element })
    }

    private var row2: [Activity] {
        Array(gridActivities.enumerated().filter { $0.offset % 2 == 1 }.map { $0.element })
    }

    private var isArabic: Bool { languageManager.current == .arabic }

    private var nearbySectionTitle: String {
        if isArabic && selectedCity == "Mecca" { return "الفعالية القريبة منك" }
        if isArabic { return "الأنشطة القريبة منك" }
        return "Nearby Activities"
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.pageBg.ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection

                // Loading / Error / Content states
                if store.isLoading && activities.isEmpty {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                    Spacer()
                } else if let error = store.error, activities.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Text(languageManager.current == .arabic ? "حدث خطأ" : "Something went wrong")
                            .font(.custom("ExpoArabic-Medium", size: 16))
                            .foregroundColor(.black)
                        Text(localizedErrorMessage(error, for: languageManager.current))
                            .font(.custom("ExpoArabic-Medium", size: 12))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Button(action: {
                            Task { await store.refresh(city: selectedCity) }
                        }) {
                            Text(languageManager.current == .arabic ? "إعادة المحاولة" : "Retry")
                                .font(.custom("ExpoArabic-Medium", size: 14))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .background(Color.mrasemBrown)
                                .cornerRadius(10)
                        }
                    }
                    Spacer()
                } else {
                    bodySection
                        .padding(.top, -84)
                }

                Spacer(minLength: 0)

                bottomTabBar
            }

            if showSidePanel {
                SidePanelView(isOpen: $showSidePanel)
                    .transition(.opacity)
                    .zIndex(1)
            }

            if showFilterPopup {
                FilterPopupView(isPresented: $showFilterPopup, selectedArea: $selectedCity)
                    .transition(.move(edge: .bottom))
                    .zIndex(2)
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(.keyboard)
        .task {
            await store.fetch(city: selectedCity)
        }
        .onChange(of: selectedCity) { _, newCity in
            Task { await store.refresh(city: newCity) }
        }
    }

    // MARK: - Header (Figma 556:1976 — matches RestaurantList / SeasonEvents: greeting beside profile, not centered)

    private var greetingText: String {
        isArabic ? "أهلا عبدالله!" : "Hi Abdullah"
    }

    private var searchPlaceholder: String {
        isArabic ? "ابحث" : "Search"
    }

    private var headerSection: some View {
        ZStack(alignment: .top) {
            Color.mrasemBrown
                .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    if isArabic {
                        headerMenuButton
                        Spacer(minLength: 0)
                        Text(greetingText)
                            .font(.custom("ExpoArabic-Medium", size: 12))
                            .foregroundColor(.white)
                        headerProfileButton
                    } else {
                        headerProfileButton
                        Text(greetingText)
                            .font(.custom("ExpoArabic-Medium", size: 12))
                            .foregroundColor(.white)
                        Spacer(minLength: 0)
                        headerMenuButton
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)

                Group {
                    if isArabic {
                        HStack(spacing: 8) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) { showFilterPopup = true }
                            }) {
                                Image("group129")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 26)
                            }
                            Spacer()
                            TextField(searchPlaceholder, text: $searchText)
                                .font(.custom("ExpoArabic-Medium", size: 12))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.trailing)
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
                            TextField(searchPlaceholder, text: $searchText)
                                .font(.custom("ExpoArabic-Medium", size: 12))
                                .foregroundColor(.black)
                            Spacer()
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) { showFilterPopup = true }
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
        .frame(height: 285)
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

    // MARK: - Body (scrollable)

    private var bodySection: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                activityGrid

                Text(nearbySectionTitle)
                    .font(.custom("ExpoArabic-Medium", size: 20))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                    .padding(.horizontal, 21)
                    .padding(.top, 24)

                nearbyActivityRow
                    .padding(.top, 14)
            }
            .padding(.bottom, 16)
        }
        .refreshable {
            await store.refresh(city: selectedCity)
        }
    }

    // MARK: - Activity grid
    // Figma: 151×170 cards, 16pt corners, 16pt h-gap, 14pt v-gap

    private var activityGrid: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: isArabic ? .trailing : .leading, spacing: 14) {
                HStack(spacing: 16) {
                    ForEach(row1) { a in
                        NavigationLink(destination: ActivityDetailView(activity: a)) {
                            ActivityGridCard(
                                activity: a,
                                isFavorite: favorites.contains(a.id),
                                onToggleFavorite: { toggle(a.id) },
                                isArabic: isArabic
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                HStack(spacing: 16) {
                    ForEach(row2) { a in
                        NavigationLink(destination: ActivityDetailView(activity: a)) {
                            ActivityGridCard(
                                activity: a,
                                isFavorite: favorites.contains(a.id),
                                onToggleFavorite: { toggle(a.id) },
                                isArabic: isArabic
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 21)
            .padding(.vertical, 16)
        }
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
    }

    private var nearbyActivitiesSource: [Activity] {
        Array(activities.prefix(4))
    }

    // MARK: - Nearby activities (mini cards — matches NearbyRestaurantCard / NearbyEventCard)

    private var nearbyActivityRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(nearbyActivitiesSource) { activity in
                    NavigationLink(destination: ActivityDetailView(activity: activity)) {
                        NearbyActivityCard(activity: activity, isArabic: isArabic)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 21)
            .padding(.top, 12)
        }
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
    }

    // MARK: - Bottom tab bar — Figma: y=762, h=50, #31231b

    private var bottomTabBar: some View {
        ZStack {
            Color.mrasemBrown.ignoresSafeArea(edges: .bottom)
            HStack(spacing: 0) {
                Spacer()
                homeTabLink(width: 20, height: 22)
                Spacer()
                BookingsCalendarNavigationLink()
                Spacer()
                tabButton(image: "nav-icon-grid", width: 20, height: 20)
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

    private func tabButton(image: String, width: CGFloat, height: CGFloat) -> some View {
        Button(action: {}) {
            Image(image)
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
                .frame(width: width, height: height)
        }
    }

    private func homeTabLink(width: CGFloat, height: CGFloat) -> some View {
        NavigationLink(destination: CategorySelectionView()) {
            Image("nav-icon-home")
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
                .frame(width: width, height: height)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func toggle(_ id: Int) {
        if favorites.contains(id) { favorites.remove(id) } else { favorites.insert(id) }
    }
}

// MARK: - Activity Grid Card
// Figma: 151×170, white bg, 16pt corners
// Image: 141.6×99.5 (≈142×100), 17pt corners, ~4.5pt inset all around
// Title: 14px (13px for long names), ExpoArabic Medium, black
// Category: 8px ExpoArabic Medium, rgba(33,60,46,0.58) (same family as title; Light not bundled)
// Location: pin icon + 8px ExpoArabic Medium, #213c2e
// Heart: 15×15 at 8pt from top-right

struct ActivityGridCard: View {
    let activity: Activity
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    var isArabic: Bool = false

    private let layoutWidth: CGFloat = 151
    private var scale: CGFloat { layoutWidth / 151 }

    var body: some View {
        VStack(alignment: isArabic ? .trailing : .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                RemoteImage(imageName: activity.imageName)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 142 * scale, height: 100 * scale)
                    .clipped()
                    .cornerRadius(max(8, 11 * scale))
                    .padding(.top, 4.3 * scale)
                    .padding(.horizontal, 4.7 * scale)

                Button(action: onToggleFavorite) {
                    ZStack {
                        Image("heart-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 22, height: 22)
                        Image("base").resizable().aspectRatio(contentMode: .fit).frame(width: 11, height: 11)
                    }
                }
                .padding(.top, 8 * scale)
                .padding(.trailing, 8 * scale)
            }

            VStack(alignment: isArabic ? .trailing : .leading, spacing: 0) {
                Text(activity.displayTitle(isArabic: isArabic))
                    .font(.custom("ExpoArabic-Medium", size: max(11, 14 * scale)))
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .multilineTextAlignment(isArabic ? .trailing : .leading)
                    .padding(.top, 6)

                Text(activity.displayCategory(isArabic: isArabic))
                    .font(.custom("ExpoArabic-Medium", size: max(7, 8 * scale)))
                    .foregroundColor(Color.darkGreen.opacity(0.58))
                    .lineLimit(1)
                    .multilineTextAlignment(isArabic ? .trailing : .leading)
                    .padding(.top, 2)

                HStack(spacing: 3) {
                    if !isArabic {
                        Image("location-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 8 * scale, height: 10 * scale)
                    }
                    Text(activity.displayLocation(isArabic: isArabic))
                        .font(.custom("ExpoArabic-Medium", size: max(7, 8 * scale)))
                        .fontWeight(.medium)
                        .foregroundColor(.darkGreen)
                        .lineLimit(1)
                    if isArabic {
                        Image("location-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 8 * scale, height: 10 * scale)
                    }
                }
                .padding(.top, 2)
            }
            .padding(.horizontal, 8 * scale)
            .padding(.bottom, 8 * scale)
        }
        .frame(width: layoutWidth, height: 170 * scale)
        .background(Color.white)
        .cornerRadius(max(10, 16 * scale))
        .shadow(color: Color.black.opacity(0.07), radius: 6, x: 0, y: 3)
        .contentShape(Rectangle())
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
    }
}

// MARK: - Nearby Activity Card (258×72) — matches NearbyRestaurantCard / NearbyEventCard

struct NearbyActivityCard: View {
    let activity: Activity
    var isArabic: Bool = false

    private let textGreen = Color(hex: 0x213C2E)

    var body: some View {
        HStack(spacing: 9) {
            RemoteImage(imageName: activity.imageName)
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 55)
                .cornerRadius(12)
                .clipped()
                .padding(isArabic ? .trailing : .leading, 7)

            VStack(alignment: isArabic ? .trailing : .leading, spacing: 0) {
                Text(activity.displayTitle(isArabic: isArabic))
                    .font(.custom("ExpoArabic-Medium", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .lineLimit(1)

                Text(activity.displayCategory(isArabic: isArabic))
                    .font(.custom("ExpoArabic-Medium", size: 10))
                    .fontWeight(.medium)
                    .foregroundColor(textGreen.opacity(0.53))
                    .lineLimit(1)
                    .padding(.top, 2)

                HStack(spacing: 3) {
                    if !isArabic {
                        Image("location-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 8, height: 10)
                    }
                    Text(activity.displayLocation(isArabic: isArabic))
                        .font(.custom("ExpoArabic-Medium", size: 10))
                        .fontWeight(.medium)
                        .foregroundColor(textGreen)
                        .lineLimit(1)
                    if isArabic {
                        Image("location-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 8, height: 10)
                    }
                }
                .padding(.top, 2)
            }

            Spacer()
        }
        .frame(width: 258, height: 72)
        .background(Color.white)
        .cornerRadius(19)
        .shadow(color: Color.black.opacity(0.07), radius: 6, x: 0, y: 3)
        .contentShape(Rectangle())
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
    }
}

#Preview {
    NavigationStack {
        ActivitiesListView()
            .environmentObject(LanguageManager())
            .environmentObject(InvitationStore())
    }
}
