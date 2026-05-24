import SwiftUI

struct RestaurantListView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var isFavorite: Set<String> = []
    @State private var searchText: String = ""
    @State private var showSidePanel = false
    @State private var showFilterPopup = false
    @State private var selectedCity: String = "Jeddah"
    @State private var store = StorePrefetch.restaurants
    
    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    private let pageBg = Color(red: 0xF3 / 255.0, green: 0xF3 / 255.0, blue: 0xF3 / 255.0)
    private let searchGray = Color(red: 0xC4 / 255.0, green: 0xC4 / 255.0, blue: 0xC4 / 255.0)

    private var restaurants: [Restaurant] {
        let all = store.restaurants
        guard !searchText.isEmpty else { return all }
        let q = searchText.lowercased()
        return all.filter {
            $0.name.lowercased().contains(q) ||
            $0.arabicName.contains(q) ||
            $0.cuisine.lowercased().contains(q) ||
            $0.arabicCuisine.contains(q)
        }
    }

    private var topRow: [Restaurant] {
        Array(restaurants.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element })
    }
    
    private var bottomRow: [Restaurant] {
        Array(restaurants.enumerated().filter { $0.offset % 2 == 1 }.map { $0.element })
    }

    private func toggleFavorite(_ name: String) {
        if isFavorite.contains(name) { isFavorite.remove(name) } else { isFavorite.insert(name) }
    }
    
    var body: some View {
        // No nested NavigationStack — Category → this list is already inside PhoneLoginView's stack; nesting breaks dismiss() on detail.
        ZStack {
                pageBg.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Figma 1331:22216 (Southern / AR restaurants) — same chrome as Activities 556 / Season 1202.
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
                                    Text("أهلا \(AuthenticationManager.shared.userName ?? AuthenticationManager.shared.phoneNumber ?? "")!")
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
                                    Text("Hi \(AuthenticationManager.shared.userName ?? AuthenticationManager.shared.phoneNumber ?? "")")
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
                    if store.isLoading && restaurants.isEmpty {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.2)
                            .padding(.top, -50)
                        Spacer()
                    } else if let error = store.error, restaurants.isEmpty {
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
                            if isLikelyConnectionFailureMessage(error) {
                                Text(connectionTroubleshootingHint(for: languageManager.current))
                                    .font(.custom("ExpoArabic-Medium", size: 11))
                                    .foregroundColor(.gray.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            }
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
                    Group {
                    // 2-row restaurant grid (horizontal scroll)
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(alignment: languageManager.current == .arabic ? .trailing : .leading, spacing: 14) {
                            HStack(spacing: 16) {
                                ForEach(topRow) { restaurant in
                                    NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                                        GridRestaurantCard(restaurant: restaurant, isArabic: languageManager.current == .arabic, isFavorite: isFavorite.contains(restaurant.name), onToggleFavorite: { toggleFavorite(restaurant.name) })
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            HStack(spacing: 16) {
                                ForEach(bottomRow) { restaurant in
                                    NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                                        GridRestaurantCard(restaurant: restaurant, isArabic: languageManager.current == .arabic, isFavorite: isFavorite.contains(restaurant.name), onToggleFavorite: { toggleFavorite(restaurant.name) })
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

                    // Figma 1331:22277
                    Text(languageManager.current == .arabic ? "المطاعم القريبة منك" : "Nearby Restaurants")
                        .font(.custom("ExpoArabic-Medium", size: 20))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: languageManager.current == .arabic ? .trailing : .leading)
                        .padding(.horizontal, 21)
                        .padding(.top, 3)
                    
                    // Nearby restaurants horizontal scroll
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(restaurants.prefix(4)) { restaurant in
                                NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                                    NearbyRestaurantCard(
                                        restaurant: restaurant,
                                        isArabic: languageManager.current == .arabic
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 21)
                        .padding(.top, 12)
                    }
                    .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
                    .environment(\.layoutDirection, languageManager.current == .arabic ? .rightToLeft : .leftToRight)
                    }

                    } // end of else (content state)
                    
                    Spacer()
                    
                    // Bottom navigation bar — brown #31231B, 5 icons per Figma
                    ZStack {
                        brandBrown
                            .ignoresSafeArea(edges: .bottom)
                        
                        HStack(spacing: 0) {
                            Spacer()
                            
                            NavigationLink(destination: CategorySelectionView()) {
                                Image("nav-icon-home")
                                    .resizable()
                                    .renderingMode(.original)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 22)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                            
                            BookingsCalendarNavigationLink()

                            Spacer()

                            Button(action: {}) {
                                Image("nav-icon-grid")
                                    .resizable()
                                    .renderingMode(.original)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            }
                            
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

// MARK: - Grid Card (151x170, Figma 2-row layout)

struct GridRestaurantCard: View {
    let restaurant: Restaurant
    let isArabic: Bool
    var isFavorite: Bool = false
    var onToggleFavorite: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: isArabic ? .trailing : .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                RemoteImage(imageName: restaurant.imageName)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 142, height: 100)
                    .clipped()
                    .cornerRadius(11)
                    .padding(.top, 4.3)
                    .padding(.horizontal, 4.7)
                
                if restaurant.hasMichelin {
                    Text(isArabic ? "ميشلان" : "MICHELIN")
                        .font(.custom("ExpoArabic-Medium", size: 6))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 0xA7 / 255.0, green: 0x1E / 255.0, blue: 0x1E / 255.0))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color(red: 0xD9 / 255.0, green: 0xD9 / 255.0, blue: 0xD9 / 255.0))
                        .cornerRadius(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 11)
                        .padding(.leading, 9)
                }

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
                Text(isArabic ? restaurant.arabicName : restaurant.name)
                    .font(.custom("ExpoArabic-Medium", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .padding(.top, 6)
                
                HStack(spacing: 3) {
                    if !isArabic {
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(.custom("ExpoArabic-Medium", size: 12))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                        Image("star-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10, height: 10)
                    } else {
                        Image("star-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10, height: 10)
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(.custom("ExpoArabic-Medium", size: 12))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                    }
                }
                .padding(.top, 2)
                
                HStack(spacing: 3) {
                    if !isArabic {
                        Image("fork-knife-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10, height: 10)
                        Text(isArabic ? restaurant.arabicCuisine : restaurant.cuisine)
                            .font(.custom("ExpoArabic-Medium", size: 8))
                            .fontWeight(.light)
                            .foregroundColor(.black)
                            .lineLimit(1)
                    } else {
                        Text(isArabic ? restaurant.arabicCuisine : restaurant.cuisine)
                            .font(.custom("ExpoArabic-Medium", size: 8))
                            .fontWeight(.light)
                            .foregroundColor(.black)
                            .lineLimit(1)
                        Image("fork-knife-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10, height: 10)
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

// MARK: - Nearby Restaurant Card (258x72, Figma bottom section)

struct NearbyRestaurantCard: View {
    let restaurant: Restaurant
    let isArabic: Bool
    
    var body: some View {
        HStack(spacing: 9) {
            RemoteImage(imageName: restaurant.imageName)
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 55)
                .cornerRadius(12)
                .clipped()
                .padding(isArabic ? .trailing : .leading, 7)
            
            VStack(alignment: isArabic ? .trailing : .leading, spacing: 0) {
                HStack(spacing: 4) {
                    if isArabic {
                        if restaurant.hasMichelin {
                            Text("ميشلان")
                                .font(.custom("ExpoArabic-Medium", size: 8))
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 0xA7 / 255.0, green: 0x1E / 255.0, blue: 0x1E / 255.0))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color(red: 0xD9 / 255.0, green: 0xD9 / 255.0, blue: 0xD9 / 255.0))
                                .cornerRadius(4)
                        }
                        Text(isArabic ? restaurant.arabicName : restaurant.name)
                            .font(.custom("ExpoArabic-Medium", size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .lineLimit(1)
                    } else {
                        Text(isArabic ? restaurant.arabicName : restaurant.name)
                            .font(.custom("ExpoArabic-Medium", size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .lineLimit(1)
                        if restaurant.hasMichelin {
                            Text("MICHELIN")
                                .font(.custom("ExpoArabic-Medium", size: 8))
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 0xA7 / 255.0, green: 0x1E / 255.0, blue: 0x1E / 255.0))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color(red: 0xD9 / 255.0, green: 0xD9 / 255.0, blue: 0xD9 / 255.0))
                                .cornerRadius(4)
                        }
                    }
                }
                
                HStack(spacing: 3) {
                    if isArabic {
                        Image("star-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10, height: 10)
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(.custom("ExpoArabic-Medium", size: 12))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                    } else {
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(.custom("ExpoArabic-Medium", size: 12))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                        Image("star-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.top, 2)
                
                HStack(spacing: 3) {
                    if isArabic {
                        Text(isArabic ? restaurant.arabicCuisine : restaurant.cuisine)
                            .font(.custom("ExpoArabic-Medium", size: 10))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .lineLimit(1)
                        Image("fork-knife-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10, height: 10)
                    } else {
                        Image("fork-knife-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10, height: 10)
                        Text(isArabic ? restaurant.arabicCuisine : restaurant.cuisine)
                            .font(.custom("ExpoArabic-Medium", size: 10))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .lineLimit(1)
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

// Keep old cards for detail navigation compatibility
struct RestaurantCard: View {
    let restaurant: Restaurant
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    let isArabic: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                RemoteImage(imageName: restaurant.imageName)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 242, height: 185)
                    .clipped()
                    .cornerRadius(17)
                    .padding(.top, 8)
                    .padding(.horizontal, 8)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 4) {
                        if isArabic {
                            Spacer()
                            if restaurant.hasMichelin {
                                Text("ميشلان")
                                    .font(.custom("ExpoArabic-Medium", size: 10))
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(red: 0xA7 / 255.0, green: 0x1E / 255.0, blue: 0x1E / 255.0))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color(red: 0xD9 / 255.0, green: 0xD9 / 255.0, blue: 0xD9 / 255.0))
                                    .cornerRadius(5)
                            }
                            Text(restaurant.arabicName)
                                .font(.custom("ExpoArabic-Medium", size: 20))
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                                .lineLimit(1)
                        } else {
                            Text(restaurant.name)
                                .font(.custom("ExpoArabic-Medium", size: 20))
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                                .lineLimit(1)
                            if restaurant.hasMichelin {
                                Text("MICHELIN")
                                    .font(.custom("ExpoArabic-Medium", size: 10))
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(red: 0xA7 / 255.0, green: 0x1E / 255.0, blue: 0x1E / 255.0))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color(red: 0xD9 / 255.0, green: 0xD9 / 255.0, blue: 0xD9 / 255.0))
                                    .cornerRadius(5)
                            }
                        }
                    }
                    .padding(.top, 16)
                    
                    HStack(spacing: 4) {
                        if isArabic {
                            Text(String(format: "%.1f", restaurant.rating))
                                .font(.custom("ExpoArabic-Medium", size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                            Image("star-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 12, height: 12)
                        } else {
                            Image("star-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 12, height: 12)
                            Text(String(format: "%.1f", restaurant.rating))
                                .font(.custom("ExpoArabic-Medium", size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                    
                    HStack(spacing: 4) {
                        Image("fork-knife-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 12, height: 12)
                        Text(isArabic ? restaurant.arabicCuisine : restaurant.cuisine)
                            .font(.custom("ExpoArabic-Medium", size: 12))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                    }
                    .padding(.top, 7)
                    .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                    
                    HStack(spacing: 4) {
                        Image("location-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 10, height: 12)
                        Text(isArabic ? restaurant.arabicCity : restaurant.city)
                            .font(.custom("ExpoArabic-Medium", size: 10))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                    }
                    .padding(.top, 4)
                    .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 16)
            }
            .frame(width: 258, height: 316)
            .background(Color.white)
            .cornerRadius(22)
            
            Button(action: onToggleFavorite) {
                ZStack {
                    Image("heart-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 25, height: 25)
                    Image("base").resizable().aspectRatio(contentMode: .fit).frame(width: 16, height: 16)
                }
            }
            .padding(.top, 15)
            .padding(.trailing, 15)
        }
        .environment(\.layoutDirection, .leftToRight)
    }
}

struct SmallRestaurantCard: View {
    let restaurant: Restaurant
    let isArabic: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            RemoteImage(imageName: restaurant.imageName)
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70)
                .cornerRadius(12)
                .clipped()
            
            VStack(alignment: isArabic ? .trailing : .leading, spacing: 4) {
                HStack(spacing: 4) {
                    if isArabic {
                        if restaurant.hasMichelin {
                            Text("ميشلان")
                                .font(.custom("ExpoArabic-Medium", size: 8))
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 0xA7 / 255.0, green: 0x1E / 255.0, blue: 0x1E / 255.0))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color(red: 0xD9 / 255.0, green: 0xD9 / 255.0, blue: 0xD9 / 255.0))
                                .cornerRadius(4)
                        }
                        Text(restaurant.arabicName)
                            .font(.custom("ExpoArabic-Medium", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .lineLimit(1)
                    } else {
                        Text(restaurant.name)
                            .font(.custom("ExpoArabic-Medium", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .lineLimit(1)
                        if restaurant.hasMichelin {
                            Text("MICHELIN")
                                .font(.custom("ExpoArabic-Medium", size: 8))
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 0xA7 / 255.0, green: 0x1E / 255.0, blue: 0x1E / 255.0))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color(red: 0xD9 / 255.0, green: 0xD9 / 255.0, blue: 0xD9 / 255.0))
                                .cornerRadius(4)
                        }
                    }
                }
                HStack(spacing: 4) {
                    if isArabic {
                        Image("star-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 10, height: 10)
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(.custom("ExpoArabic-Medium", size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                    } else {
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(.custom("ExpoArabic-Medium", size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                        Image("star-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 10, height: 10)
                    }
                }
                HStack(spacing: 4) {
                    if isArabic {
                        Text(restaurant.arabicCuisine)
                            .font(.custom("ExpoArabic-Medium", size: 12))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .lineLimit(1)
                        Image("fork-knife-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 10, height: 10)
                    } else {
                        Image("fork-knife-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 10, height: 10)
                        Text(restaurant.cuisine)
                            .font(.custom("ExpoArabic-Medium", size: 12))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .lineLimit(1)
                    }
                }
            }
            Spacer()
        }
        .frame(width: 220, height: 86)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
    }
}

#Preview {
    NavigationStack {
        RestaurantListView()
            .environmentObject(LanguageManager())
            .environmentObject(InvitationStore())
    }
}
