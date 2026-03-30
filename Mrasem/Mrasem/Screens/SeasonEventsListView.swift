import SwiftUI

struct SeasonEvent: Identifiable {
    let id = UUID().uuidString
    let name: String
    let category: String
    let imageName: String
    let location: String
    let description: String
}

struct SeasonEventsListView: View {
    @EnvironmentObject private var languageManager: LanguageManager

    let events = [
        SeasonEvent(name: "Winter Wonderland", category: "Seasonal Attraction", imageName: "season-winter-wonderland", location: "Jeddah, Saudi Arabia", description: "Step into a magical winter experience in the heart of Jeddah. Winter Wonderland brings snow, festive lights, rides, and live entertainment for the whole family. A seasonal must-visit with food stalls, games, and unforgettable holiday vibes."),
        SeasonEvent(name: "Balad Beast", category: "Live music", imageName: "season-balad-beast", location: "Jeddah, Saudi Arabia", description: "Experience the ultimate music festival in Jeddah's historic Al-Balad district. Balad Beast features international and regional artists, electrifying performances, and an unforgettable atmosphere under the stars."),
        SeasonEvent(name: "The Snow Dome", category: "Seasonal Attraction", imageName: "season-snow-dome", location: "Jeddah, Saudi Arabia", description: "Escape the heat and enjoy real snow in Jeddah! The Snow Dome offers snow tubing, ice slides, snowball fights, and a winter wonderland atmosphere perfect for families and friends."),
        SeasonEvent(name: "Ice Rink", category: "Seasonal Attraction", imageName: "season-ice-rink", location: "Jeddah, Saudi Arabia", description: "Glide across the ice at Jeddah's premier seasonal ice rink. Perfect for beginners and experienced skaters alike, with professional instructors, music, and a festive atmosphere."),
        SeasonEvent(name: "Tropical Land", category: "Adventure", imageName: "season-tropical-land", location: "Jeddah, Saudi Arabia", description: "Dive into a tropical adventure with water rides, jungle-themed attractions, and exotic experiences. Tropical Land is the ultimate destination for thrill-seekers and families looking for fun."),
        SeasonEvent(name: "Notat Watar", category: "Karaoke", imageName: "season-notat-watar", location: "Jeddah, Saudi Arabia", description: "Sing your heart out at Notat Watar, Jeddah's premier karaoke and live music venue. Enjoy an evening of Arabic and international hits in a vibrant, social atmosphere.")
    ]

    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)

    private var topRow: [SeasonEvent] {
        Array(events.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element })
    }

    private var bottomRow: [SeasonEvent] {
        Array(events.enumerated().filter { $0.offset % 2 == 1 }.map { $0.element })
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.95).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Brown header with profile + search
                    ZStack(alignment: .top) {
                        brandBrown
                            .ignoresSafeArea(edges: .top)
                            .frame(height: 250)

                        VStack(spacing: 0) {
                            HStack(spacing: 8) {
                                if languageManager.current == .arabic {
                                    Button(action: {}) {
                                        Image("menu-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 24, height: 20)
                                    }
                                    Spacer()
                                    Text("أهلا عبدالله!")
                                        .font(.custom("ExpoArabic-Medium", size: 12))
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                    ZStack {
                                        Image("profile-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 42, height: 42)
                                        Image("nav-profile").resizable().aspectRatio(contentMode: .fit).frame(width: 38, height: 38)
                                        Image("layer2").resizable().aspectRatio(contentMode: .fit).frame(width: 36, height: 36)
                                    }
                                } else {
                                    ZStack {
                                        Image("profile-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 42, height: 42)
                                        Image("nav-profile").resizable().aspectRatio(contentMode: .fit).frame(width: 38, height: 38)
                                        Image("layer2").resizable().aspectRatio(contentMode: .fit).frame(width: 36, height: 36)
                                    }
                                    Text("Hi Abdullah")
                                        .font(.custom("ExpoArabic-Medium", size: 12))
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Button(action: {}) {
                                        Image("menu-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 24, height: 20)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 45)

                            HStack {
                                if languageManager.current == .arabic {
                                    Text("ابحث")
                                        .font(.custom("ExpoArabic-Medium", size: 12))
                                        .fontWeight(.medium)
                                        .foregroundColor(Color(red: 0xC4 / 255.0, green: 0xC4 / 255.0, blue: 0xC4 / 255.0))
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                    Image("search-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 14, height: 14)
                                } else {
                                    Image("search-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 14, height: 14)
                                    Text("Search")
                                        .font(.custom("ExpoArabic-Medium", size: 12))
                                        .fontWeight(.medium)
                                        .foregroundColor(Color(red: 0xC4 / 255.0, green: 0xC4 / 255.0, blue: 0xC4 / 255.0))
                                    Spacer()
                                }
                            }
                            .padding(.horizontal, 15)
                            .frame(width: 327, height: 43)
                            .background(Color.white)
                            .cornerRadius(9)
                            .padding(.top, 14)
                        }
                    }

                    // 2-row event grid
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 16) {
                                ForEach(topRow) { event in
                                    NavigationLink(destination: SeasonEventDetailView(event: event)) {
                                        GridEventCard(event: event)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            HStack(spacing: 16) {
                                ForEach(bottomRow) { event in
                                    NavigationLink(destination: SeasonEventDetailView(event: event)) {
                                        GridEventCard(event: event)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.horizontal, 21)
                        .padding(.vertical, 16)
                    }
                    .environment(\.layoutDirection, languageManager.current == .arabic ? .rightToLeft : .leftToRight)
                    .padding(.top, -75)

                    // "Nearby Restaurants" section (matches Figma text)
                    Text(languageManager.current == .arabic ? "مطاعم قريبة" : "Nearby Restaurants")
                        .font(.custom("ExpoArabic-Medium", size: 20))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: languageManager.current == .arabic ? .trailing : .leading)
                        .padding(.horizontal, 21)
                        .padding(.top, 3)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(events.prefix(3)) { event in
                                NearbyEventCard(event: event)
                            }
                        }
                        .padding(.horizontal, 21)
                        .padding(.top, 12)
                    }
                    .environment(\.layoutDirection, languageManager.current == .arabic ? .rightToLeft : .leftToRight)

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
                            Button(action: {}) { Image("nav-icon-calendar").resizable().renderingMode(.original).aspectRatio(contentMode: .fit).frame(width: 21, height: 21) }
                            Spacer()
                            Button(action: {}) { Image("nav-icon-grid").resizable().renderingMode(.original).aspectRatio(contentMode: .fit).frame(width: 20, height: 20) }
                            Spacer()
                            Button(action: {}) { Image("nav-icon-ticket").resizable().renderingMode(.original).aspectRatio(contentMode: .fit).frame(width: 23, height: 18) }
                            Spacer()
                            Button(action: {}) { Image("nav-icon-profile").resizable().renderingMode(.original).aspectRatio(contentMode: .fit).frame(width: 20, height: 20) }
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                    .frame(height: 50)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Grid Event Card (151x170)

struct GridEventCard: View {
    let event: SeasonEvent

    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(event.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 142, height: 100)
                .clipped()
                .cornerRadius(11)
                .padding(.top, 4.3)
                .padding(.horizontal, 4.7)

            VStack(alignment: .leading, spacing: 0) {
                Text(event.name)
                    .font(.custom("ExpoArabic-Medium", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .padding(.top, 4)

                Text(event.category)
                    .font(.custom("ExpoArabic-Medium", size: 8))
                    .fontWeight(.light)
                    .foregroundColor(textGreen.opacity(0.58))
                    .lineLimit(1)
                    .padding(.top, 2)

                HStack(spacing: 3) {
                    Image("location-icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 8, height: 10)

                    Text(event.location)
                        .font(.custom("ExpoArabic-Medium", size: 8))
                        .fontWeight(.medium)
                        .foregroundColor(textGreen)
                        .lineLimit(1)
                }
                .padding(.top, 2)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .frame(width: 151, height: 170)
        .background(Color.white)
        .cornerRadius(16)
        .environment(\.layoutDirection, .leftToRight)
    }
}

// MARK: - Nearby Event Card (258x72)

struct NearbyEventCard: View {
    let event: SeasonEvent

    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)

    var body: some View {
        HStack(spacing: 9) {
            Image(event.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 55)
                .cornerRadius(11)
                .clipped()
                .padding(.leading, 7)

            VStack(alignment: .leading, spacing: 0) {
                Text(event.name)
                    .font(.custom("ExpoArabic-Medium", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .lineLimit(1)

                Text(event.category)
                    .font(.custom("ExpoArabic-Medium", size: 10))
                    .fontWeight(.medium)
                    .foregroundColor(textGreen.opacity(0.53))
                    .padding(.top, 2)

                HStack(spacing: 3) {
                    Image("location-icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 8, height: 10)

                    Text(event.location)
                        .font(.custom("ExpoArabic-Medium", size: 10))
                        .fontWeight(.medium)
                        .foregroundColor(textGreen)
                        .lineLimit(1)
                }
                .padding(.top, 2)
            }

            Spacer()
        }
        .frame(width: 258, height: 72)
        .background(Color.white)
        .cornerRadius(19)
        .environment(\.layoutDirection, .leftToRight)
    }
}

#Preview {
    SeasonEventsListView()
        .environmentObject(LanguageManager())
}
