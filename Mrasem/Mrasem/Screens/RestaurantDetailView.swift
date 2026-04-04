import SwiftUI

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss
    @State private var isFavorite: Bool = false
    @State private var currentImageIndex: Int = 0
    
    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 0xF3 / 255.0, green: 0xF3 / 255.0, blue: 0xF3 / 255.0)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Brown bar only — back/logo/menu live in overlay so RTL / nested layout never steals taps.
                brandBrown
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 90)
                
                // Hero image — fixed height so the placeholder Color + ZStack cannot expand and leave a huge gap below the photo.
                ZStack(alignment: .topTrailing) {
                    Color(red: 0xF3 / 255.0, green: 0xF3 / 255.0, blue: 0xF3 / 255.0)
                    GeometryReader { geo in
                        RemoteImage(imageName: restaurant.imageName)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    }

                    Button(action: { isFavorite.toggle() }) {
                        ZStack {
                            Image("heart-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 32, height: 32)
                            Image("base").resizable().aspectRatio(contentMode: .fit).frame(width: 16, height: 16)
                        }
                    }
                    .padding(.top, 7)
                    .padding(.trailing, 8)

                    VStack {
                        Spacer(minLength: 0)
                        HStack(spacing: 6) {
                            ForEach(0..<4, id: \.self) { index in
                                Circle()
                                    .fill(index == currentImageIndex ? brandBrown : Color(red: 0xD9 / 255.0, green: 0xD9 / 255.0, blue: 0xD9 / 255.0))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 10)
                    }
                    .allowsHitTesting(false)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 185)
                .clipped()
                
                // Content section
                VStack(alignment: .leading, spacing: 0) {
                    // Restaurant name + rating
                    HStack {
                        if languageManager.current == .arabic {
                            HStack(spacing: 4) {
                                Text(String(format: "%.1f", restaurant.rating))
                                    .font(.custom("ExpoArabic-Medium", size: 16))
                                    .fontWeight(.medium)
                                    .foregroundColor(textGreen)
                                Image("star-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 13, height: 13)
                            }
                            Spacer()
                            if restaurant.hasMichelin {
                                Text("ميشلان")
                                    .font(.custom("ExpoArabic-Medium", size: 10))
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(red: 0xA7 / 255.0, green: 0x1E / 255.0, blue: 0x1E / 255.0))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color(red: 0xD9 / 255.0, green: 0xD9 / 255.0, blue: 0xD9 / 255.0))
                                    .cornerRadius(5)
                            }
                            Text(restaurant.arabicName)
                                .font(.custom("ExpoArabic-Medium", size: 20))
                                .fontWeight(.medium)
                                .foregroundColor(textGreen)
                        } else {
                            Text(restaurant.name)
                                .font(.custom("ExpoArabic-Medium", size: 20))
                                .fontWeight(.medium)
                                .foregroundColor(textGreen)
                            if restaurant.hasMichelin {
                                Text("MICHELIN")
                                    .font(.custom("ExpoArabic-Medium", size: 10))
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(red: 0xA7 / 255.0, green: 0x1E / 255.0, blue: 0x1E / 255.0))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color(red: 0xD9 / 255.0, green: 0xD9 / 255.0, blue: 0xD9 / 255.0))
                                    .cornerRadius(5)
                            }
                            Spacer()
                            HStack(spacing: 4) {
                                Text(String(format: "%.1f", restaurant.rating))
                                    .font(.custom("ExpoArabic-Medium", size: 16))
                                    .fontWeight(.medium)
                                    .foregroundColor(textGreen)
                                Image("star-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 13, height: 13)
                            }
                        }
                    }
                    .padding(.horizontal, 21)
                    .padding(.top, 14)
                    
                    // Cuisine with fork icon
                    HStack(spacing: 6) {
                        Image("fork-knife-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 14, height: 14)
                        Text(languageManager.current == .arabic ? restaurant.arabicCuisine : restaurant.cuisine)
                            .font(.custom("ExpoArabic-Medium", size: 12))
                            .fontWeight(.medium)
                            .foregroundColor(textGreen.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: languageManager.current == .arabic ? .trailing : .leading)
                    .padding(.horizontal, 21)
                    .padding(.top, 5)
                    
                    // About section
                    Text(languageManager.current == .arabic ? "عن المطعم" : "About")
                        .font(.custom("ExpoArabic-Medium", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(textGreen)
                        .frame(maxWidth: .infinity, alignment: languageManager.current == .arabic ? .trailing : .leading)
                        .padding(.horizontal, 21)
                        .padding(.top, 20)
                    
                    // Description
                    Text(languageManager.current == .arabic ? restaurant.arabicDescription : restaurant.description)
                        .font(.custom("ExpoArabic-Medium", size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(textGreen.opacity(0.81))
                        .lineSpacing(4)
                        .multilineTextAlignment(languageManager.current == .arabic ? .trailing : .leading)
                        .padding(.horizontal, 21)
                        .padding(.top, 12)
                    
                    // Location
                    HStack(spacing: 6) {
                        if languageManager.current == .arabic {
                            Text("\(restaurant.arabicCity)، السعودية")
                                .font(.custom("ExpoArabic-Medium", size: 12))
                                .fontWeight(.medium)
                                .foregroundColor(textGreen.opacity(0.79))
                            Image("location-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 14, height: 18)
                        } else {
                            Image("location-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 14, height: 18)
                            Text("\(restaurant.city), Saudi Arabia")
                                .font(.custom("ExpoArabic-Medium", size: 12))
                                .fontWeight(.medium)
                                .foregroundColor(textGreen.opacity(0.79))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: languageManager.current == .arabic ? .trailing : .leading)
                    .padding(.horizontal, 21)
                    .padding(.top, 25)
                    
                    Spacer()
                    
                    // Full-width Book button (centered, 323px wide per Figma)
                    NavigationLink(destination: BookingView(restaurant: restaurant, activity: nil)) {
                        Text(languageManager.current == .arabic ? "احجز" : "Book")
                            .font(.custom("ExpoArabic-Medium", size: 22))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(brandBrown)
                            .cornerRadius(13)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 26)
                    .padding(.bottom, 20)
                }
                
                // Bottom nav bar — brown, 5 icons
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

            // Header chrome above all content (same idea as ActivityDetailView / SeasonEventDetailView).
            VStack {
                HStack(alignment: .center) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                            .flipsForRightToLeftLayoutDirection(false)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Image("mrasem-logo")
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFit()
                        .frame(height: 50)

                    Spacer()

                    Button(action: {}) {
                        Image("menu-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 20)
                    }
                    .frame(width: 44, height: 44)
                    .buttonStyle(.plain)
                }
                .environment(\.layoutDirection, .leftToRight)
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()
            }
            .allowsHitTesting(true)
            .zIndex(100)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        RestaurantDetailView(
            restaurant: Restaurant(
                name: "Le Vesuvio",
                arabicName: "لي فيزوفيو",
                rating: 4.5,
                cuisine: "Italian, Pizza",
                arabicCuisine: "إيطالي، بيتزا",
                imageName: "restaurant-le-vesuvio",
                hasMichelin: false,
                description: "Le Vesuvio offers authentic Italian dining by the waterfront at Jeddah Yacht Club & Marina. Enjoy wood fired pizzas, handmade pastas, and fresh seafood in a modern, elegant setting with stunning marina views. A perfect spot for date nights, gatherings, or a refined evening by the sea.",
                arabicDescription: "يقدّم لي فيزوفيو تجربة طعام إيطالية أصيلة على الواجهة البحرية."
            )
        )
        .environmentObject(LanguageManager())
        .environmentObject(InvitationStore())
    }
}
