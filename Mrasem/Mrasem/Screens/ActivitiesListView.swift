import SwiftUI

struct ActivitiesListView: View {
    @State private var isFavorite: Set<String> = []
    
    let activities = [
        Activity(name: "Scuba Diving", rating: 4.5, category: "Free Diving", imageName: "activity-scuba", location: "Jeddah, Saudi Arabia", description: "Explore the Red Sea with a professional 5-hour diving experience from Jeddah. Swim among colorful coral reefs and vibrant marine life, guided by certified instructors at dive sites suited to all levels. Small groups, top-notch gear, and clear waters make this an unforgettable underwater adventure. Your Red Sea journey starts here."),
        Activity(name: "Historic District Tour in Jeddah By a Local Guide", rating: 4.8, category: "Half-Day Tour", imageName: "activity-historic", location: "Jeddah, Saudi Arabia", description: "Discover Al-Balad, Jeddah's historic UNESCO World Heritage district. Explore coral stone architecture, museums, galleries, and hidden gems with a certified local guide. Experience the rich history, vibrant culture, and timeless charm of this iconic district in an unforgettable tour."),
        Activity(name: "Private Desert Safari", rating: 4.7, category: "4WD Tours", imageName: "activity-desert", location: "Jeddah, Saudi Arabia", description: "Experience the thrill of a Desert Safari Quad Bike Tour, racing over golden sand dunes while taking in the stunning desert landscape. Feel the adrenaline, capture the picturesque scenery, and immerse yourself in the raw beauty and serenity of the desert for an unforgettable adventure."),
        Activity(name: "Moon Mountain Hike", rating: 4.6, category: "Car Tour", imageName: "activity-moon-mountain", location: "Jeddah, Saudi Arabia", description: "Hike through the otherworldly Moon Valley and experience Saudi nature like never before. This unique trail offers a serene escape from the city, perfect for those seeking quality time outdoors."),
        Activity(name: "Half Day Trip by Boat", rating: 4.9, category: "On the Water", imageName: "activity-boat", location: "Jeddah, Saudi Arabia", description: "Explore the Red Sea Coast and experience Jeddah's local maritime life. Join families and locals at the Marina, mingle with the community, and learn from passionate captains about the unique underwater treasures. This tour is perfect year round, thanks to Jeddah's mild winters."),
        Activity(name: "Horse Riding Experience", rating: 4.5, category: "Pack Animal Tours", imageName: "activity-horse", location: "Jeddah, Saudi Arabia", description: "Feel the thrill of Jeddah's landscapes on horseback! Ride along the beautiful coastline of Khalij Salman Beach, where the Red Sea's turquoise waters meet soft sandy shores. Enjoy the ocean views, gentle sea breeze, and a peaceful, scenic adventure along this picturesque beach."),
        Activity(name: "Full Day Private Tour", rating: 4.8, category: "Private Sightseeing Tour", imageName: "activity-full-day", location: "Jeddah, Saudi Arabia", description: "Discover the charm of Jeddah on a private day tour with a local guide. Explore trendy districts, coffee shops, shisha lounges, and iconic spots like the Red Sea Corniche, the Floating Mosque, and the tallest flagpole. Experience the city like a local and uncover its hidden gems.")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
            // Light gray background to match restaurant list and Figma
            Color(red: 0.95, green: 0.95, blue: 0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top brown section with profile and search - extends to very top
                ZStack(alignment: .top) {
                    Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
                        .ignoresSafeArea(edges: .top)
                        .frame(height: 250)
                    
                    VStack(spacing: 0) {
                        // Profile section
                        HStack(spacing: 8) {
                            // Profile picture - layered: Ellipse 4 (back), Ellipse 5 (middle), Layer 2 (front)
                            ZStack {
                                Image("profile-icon") // Ellipse 4
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 42, height: 42)
                                
                                Image("nav-profile") // Ellipse 5
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 38, height: 38)
                                
                                Image("layer2") // Layer 2
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 36, height: 36)
                            }
                            
                            // Greeting beside profile
                            Text("Hi Abdullah")
                                .font(.custom("ExpoArabic-Medium", size: 12))
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            // Menu button (3 lines)
                            Button(action: {}) {
                                Image("menu-icon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 20)
                            }
                        }
                        .padding(.horizontal, 24)
                        // Match vertical spacing with restaurant list (slightly higher)
                        .padding(.top, 45)
                        
                        // Search bar
                        HStack {
                            Image("search-icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 14, height: 14)
                            Text("Search")
                                .font(.custom("ExpoArabic-Medium", size: 12))
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 0xC4 / 255.0, green: 0xC4 / 255.0, blue: 0xC4 / 255.0))
                            Spacer()
                        }
                        .padding(.horizontal, 15)
                        .frame(width: 327, height: 43)
                        .background(Color.white)
                        .cornerRadius(9)
                        // Move search up a little for nicer spacing
                        .padding(.top, 14)
                    }
                }
                
                // Horizontal scrolling activities list
                VStack(alignment: .leading, spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 19) {
                            ForEach(activities) { activity in
                                NavigationLink(destination: ActivityDetailView(activity: activity)) {
                                    ActivityCard(
                                        activity: activity,
                                        isFavorite: isFavorite.contains(activity.id),
                                        onToggleFavorite: {
                                            if isFavorite.contains(activity.id) {
                                                isFavorite.remove(activity.id)
                                            } else {
                                                isFavorite.insert(activity.id)
                                            }
                                        }
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 21)
                        .padding(.vertical, 20)
                    }
                    
                    // "Top Picks for You" section
                    Text("Top Picks for You")
                        .font(.custom("ExpoArabic-Medium", size: 20))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .padding(.leading, 21)
                        .padding(.top, 3)
                    
                    // Second horizontal scrolling section (smaller cards)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(activities.prefix(4)) { activity in
                                SmallActivityCard(activity: activity)
                            }
                        }
                        .padding(.horizontal, 21)
                        .padding(.top, 15)
                    }
                }
                // Match vertical overlap with new shorter header height
                .padding(.top, -75)
                
                Spacer()
                
                // Bottom navigation bar
                ZStack {
                    Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)
                        .ignoresSafeArea(edges: .bottom)
                    
                    HStack(spacing: 0) {
                        Spacer()
                        
                        NavigationLink(destination: CategorySelectionView()) {
                            Image("nav-home")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image("nav-calendar")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image("nav-ticket")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image("nav-profile-bottom")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 8)
                }
                .frame(height: 35)
            }
        }
        .navigationBarHidden(true)
        }
    }
}

struct Activity: Identifiable {
    let id = UUID().uuidString
    let name: String
    let rating: Double
    let category: String
    let imageName: String
    let location: String
    let description: String
}

struct ActivityCard: View {
    let activity: Activity
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                // Activity image - identical to RestaurantCard (242x185 with 8pt inset)
                Image(activity.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 242, height: 185)
                    .clipped()
                    .cornerRadius(17)
                    .padding(.top, -12) // pull image further up to reduce top white margin
                    .padding(.horizontal, 8)
                
                // Activity info
                VStack(alignment: .leading, spacing: 0) {
                    Text(activity.name)
                        .font(.custom("ExpoArabic-Medium", size: 20))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .padding(.top, 16)
                    
                    Text(activity.category)
                        .font(.custom("ExpoArabic-Medium", size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0).opacity(0.58))
                        .padding(.top, 7)
                    
                    HStack(spacing: 4) {
                        Image("location-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10, height: 12)
                        
                        Text(activity.location)
                            .font(.custom("ExpoArabic-Medium", size: 12))
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0))
                    }
                    .padding(.top, 7)
                }
                .padding(.leading, 8)
                .padding(.bottom, 16)
            }
            .frame(width: 258, height: 316)
            .background(Color.white)
            .cornerRadius(22)
            
            // Heart button - BG.png (white circle) with Base.png on top
            Button(action: onToggleFavorite) {
                ZStack {
                    Image("heart-icon") // BG.png (white circle)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                    
                    Image("base") // Base.png (heart shape on top)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                }
            }
            .padding(.top, 15)
            .padding(.trailing, 15)
        }
    }
}

struct SmallActivityCard: View {
    let activity: Activity
    
    var body: some View {
        HStack(spacing: 12) {
            // Activity image
            Image(activity.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70)
                .cornerRadius(12)
                .clipped()
            
            // Activity info
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.name)
                    .font(.custom("ExpoArabic-Medium", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Text(activity.category)
                    .font(.custom("ExpoArabic-Medium", size: 12))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0).opacity(0.58))
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .frame(width: 220, height: 86)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ActivitiesListView()
}

