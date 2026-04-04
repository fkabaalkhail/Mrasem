import SwiftUI

struct SeasonEventsListView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var favorites: Set<String> = []
    @State private var searchText: String = ""
    @State private var showSidePanel = false
    @State private var showFilterPopup = false
    @State private var selectedCity: String = "Jeddah"
    @State private var store = StorePrefetch.seasonEvents

    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)

    private var seasonEvents: [SeasonEvent] {
        let all = store.seasonEvents
        guard !searchText.isEmpty else { return all }
        let q = searchText.lowercased()
        return all.filter {
            $0.displayTitle(isArabic: false).lowercased().contains(q) ||
            $0.displayTitle(isArabic: true).contains(q) ||
            $0.displayCategory(isArabic: false).lowercased().contains(q) ||
            $0.displayCategory(isArabic: true).contains(q)
        }
    }

    private var topRow: [SeasonEvent] {
        Array(seasonEvents.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element })
    }

    private var bottomRow: [SeasonEvent] {
        Array(seasonEvents.enumerated().filter { $0.offset % 2 == 1 }.map { $0.element })
    }

    private func toggleFavorite(_ name: String) {
        if favorites.contains(name) { favorites.remove(name) } else { favorites.insert(name) }
    }

    private let pageBg = Color(red: 0xF3 / 255.0, green: 0xF3 / 255.0, blue: 0xF3 / 255.0)
    private let searchGray = Color(red: 0xC4 / 255.0, green: 0xC4 / 255.0, blue: 0xC4 / 255.0)

    var body: some View {
        // Single NavigationStack from login — avoid nesting so Restaurant/Season detail dismiss() pops correctly.
        ZStack {
                pageBg.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Figma 1202:18358 / 1266:43126 — 285pt header; AR: group2 menu, greeting, ellipse profile; search matches Activities 556:2006.
                    ZStack(alignment: .top) {
                        brandBrown
                            .ignoresSafeArea(edges: .top)
                            .frame(height: 285)

                        VStack(spacing: 0) {
                            HStack(spacing: 8) {
                                if languageManager.current == .arabic {
                                    Button(action: {}) {
                                        Image("group2")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 28, height: 20)
                                    }
                                    Spacer(minLength: 0)
                                    Text("أهلا عبدالله!")
                                        .font(.custom("ExpoArabic-Medium", size: 12))
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
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
                                } else {
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
                                    Text("Hi Abdullah")
                                        .font(.custom("ExpoArabic-Medium", size: 12))
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                    Spacer(minLength: 0)
                                    Button(action: {}) {
                                        Image("group2")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 28, height: 20)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 10)

                            Group {
                                if languageManager.current == .arabic {
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
                                        TextField("ابحث", text: $searchText)
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
                                        TextField("Search", text: $searchText)
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

                    // Loading / Error / Content states
                    if store.isLoading && seasonEvents.isEmpty {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.2)
                            .padding(.top, -50)
                        Spacer()
                    } else if let error = store.error, seasonEvents.isEmpty {
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
                                    .background(brandBrown)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.top, -50)
                        Spacer()
                    } else {
                    // 2-row event grid
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 16) {
                                ForEach(topRow) { event in
                                    NavigationLink(destination: SeasonEventDetailView(event: event)) {
                                        GridEventCard(event: event, isArabic: languageManager.current == .arabic, isFavorite: favorites.contains(event.name), onToggleFavorite: { toggleFavorite(event.name) })
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            HStack(spacing: 16) {
                                ForEach(bottomRow) { event in
                                    NavigationLink(destination: SeasonEventDetailView(event: event)) {
                                        GridEventCard(event: event, isArabic: languageManager.current == .arabic, isFavorite: favorites.contains(event.name), onToggleFavorite: { toggleFavorite(event.name) })
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.horizontal, 21)
                        .padding(.vertical, 16)
                    }
                    .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
                    .environment(\.layoutDirection, languageManager.current == .arabic ? .rightToLeft : .leftToRight)
                    .padding(.top, -84)

                    // Figma 1202:18419 / 1266:43187 — Arabic: الفعالية القريبة منك
                    Text(languageManager.current == .arabic ? "الفعالية القريبة منك" : "Nearby Events")
                        .font(.custom("ExpoArabic-Medium", size: 20))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: languageManager.current == .arabic ? .trailing : .leading)
                        .padding(.horizontal, 21)
                        .padding(.top, 3)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(seasonEvents.prefix(3)) { event in
                                NavigationLink(destination: SeasonEventDetailView(event: event)) {
                                    NearbyEventCard(event: event, isArabic: languageManager.current == .arabic)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 21)
                        .padding(.top, 12)
                    }
                    .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
                    .environment(\.layoutDirection, languageManager.current == .arabic ? .rightToLeft : .leftToRight)

                    } // end of else (content state)

                    Spacer()

                    // Brown bottom nav — 5 icons
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
                            Button(action: {}) { Image("nav-icon-grid").resizable().renderingMode(.original).aspectRatio(contentMode: .fit).frame(width: 20, height: 20) }
                            Spacer()
                            TicketsNavigationLink()
                            Spacer()
                            InvitationsNavigationLink(width: 20, height: 20)
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                    .frame(height: 50)
                    .environment(\.layoutDirection, .leftToRight)
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
        .refreshable {
            await store.refresh(city: selectedCity)
        }
        .task {
            await store.fetch(city: selectedCity)
        }
        .onChange(of: selectedCity) { _, newCity in
            Task { await store.refresh(city: newCity) }
        }
    }
}

// MARK: - Grid Event Card (151×170) — Figma 640:3477+

struct GridEventCard: View {
    let event: SeasonEvent
    var isArabic: Bool = false
    var isFavorite: Bool = false
    var onToggleFavorite: (() -> Void)? = nil

    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)

    var body: some View {
        VStack(alignment: isArabic ? .trailing : .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                RemoteImage(imageName: event.imageName)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 142, height: 100)
                    .clipped()
                    .cornerRadius(11)
                    .padding(.top, 4.3)
                    .padding(.horizontal, 4.7)

                Button(action: { onToggleFavorite?() }) {
                    ZStack {
                        Image("heart-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 22, height: 22)
                        Image("base").resizable().aspectRatio(contentMode: .fit).frame(width: 11, height: 11)
                    }
                }
                .padding(.top, 8)
                .padding(.trailing, 8)
            }

            VStack(alignment: isArabic ? .trailing : .leading, spacing: 0) {
                Text(event.displayTitle(isArabic: isArabic))
                    .font(.custom("ExpoArabic-Medium", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .multilineTextAlignment(isArabic ? .trailing : .leading)
                    .padding(.top, 6)

                Text(event.displayCategory(isArabic: isArabic))
                    .font(.custom("ExpoArabic-Medium", size: 8))
                    .foregroundColor(textGreen.opacity(0.58))
                    .lineLimit(1)
                    .multilineTextAlignment(isArabic ? .trailing : .leading)
                    .padding(.top, 2)

                HStack(spacing: 3) {
                    if !isArabic {
                        Image("location-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 8, height: 10)
                    }
                    Text(event.displayLocation(isArabic: isArabic))
                        .font(.custom("ExpoArabic-Medium", size: 8))
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
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .frame(width: 151, height: 170)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.07), radius: 6, x: 0, y: 3)
        .contentShape(Rectangle())
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
    }
}

// MARK: - Nearby Event Card (258×72) — Figma 640:3572+

struct NearbyEventCard: View {
    let event: SeasonEvent
    var isArabic: Bool = false

    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)

    var body: some View {
        Group {
            if isArabic {
                HStack(spacing: 9) {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(event.displayTitle(isArabic: true))
                            .font(.custom("ExpoArabic-Medium", size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)

                        Text(event.displayCategory(isArabic: true))
                            .font(.custom("ExpoArabic-Medium", size: 10))
                            .fontWeight(.medium)
                            .foregroundColor(textGreen.opacity(0.53))
                            .lineLimit(1)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, 2)

                        HStack(spacing: 3) {
                            Text(event.displayLocation(isArabic: true))
                                .font(.custom("ExpoArabic-Medium", size: 10))
                                .fontWeight(.medium)
                                .foregroundColor(textGreen)
                                .lineLimit(1)
                            Image("location-icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 8, height: 10)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.top, 2)
                    }

                    RemoteImage(imageName: event.imageName)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 55)
                        .cornerRadius(11)
                        .clipped()
                        .padding(.trailing, 7)
                }
            } else {
                HStack(spacing: 9) {
                    RemoteImage(imageName: event.imageName)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 55)
                        .cornerRadius(12)
                        .clipped()
                        .padding(.leading, 7)

                    VStack(alignment: .leading, spacing: 0) {
                        Text(event.displayTitle(isArabic: false))
                            .font(.custom("ExpoArabic-Medium", size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .lineLimit(1)

                        Text(event.displayCategory(isArabic: false))
                            .font(.custom("ExpoArabic-Medium", size: 10))
                            .fontWeight(.medium)
                            .foregroundColor(textGreen.opacity(0.53))
                            .padding(.top, 2)

                        HStack(spacing: 3) {
                            Image("location-icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 8, height: 10)

                            Text(event.displayLocation(isArabic: false))
                                .font(.custom("ExpoArabic-Medium", size: 10))
                                .fontWeight(.medium)
                                .foregroundColor(textGreen)
                                .lineLimit(1)
                        }
                        .padding(.top, 2)
                    }

                    Spacer()
                }
            }
        }
        .frame(width: 258, height: 72)
        .background(Color.white)
        .cornerRadius(19)
        .shadow(color: Color.black.opacity(0.07), radius: 6, x: 0, y: 3)
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        SeasonEventsListView()
            .environmentObject(LanguageManager())
            .environmentObject(InvitationStore())
    }
}
