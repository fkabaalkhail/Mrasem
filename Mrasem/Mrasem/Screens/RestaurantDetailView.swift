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
                // Top brown header with back arrow, logo, menu icon
                ZStack {
                    brandBrown.ignoresSafeArea(edges: .top)
                    
                    HStack(alignment: .center) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                        }
                        
                        Spacer()
                        
                        // Mrasem logo centered in header
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
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 90)
                
                // Restaurant image with heart button
                ZStack(alignment: .topTrailing) {
                    Image(restaurant.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 185)
                        .clipped()
                    
                    Button(action: { isFavorite.toggle() }) {
                        ZStack {
                            Image("heart-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 32, height: 32)
                            Image("base").resizable().aspectRatio(contentMode: .fit).frame(width: 16, height: 16)
                        }
                    }
                    .padding(.top, 7)
                    .padding(.trailing, 8)
                }
                
                // Carousel dots
                HStack(spacing: 6) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(index == currentImageIndex ? brandBrown : Color(red: 0xD9 / 255.0, green: 0xD9 / 255.0, blue: 0xD9 / 255.0))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 8)
                
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
                                Text("MICHELIN")
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
                            Text("جدة، السعودية")
                                .font(.custom("ExpoArabic-Medium", size: 12))
                                .fontWeight(.medium)
                                .foregroundColor(textGreen.opacity(0.79))
                            Image("location-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 14, height: 18)
                        } else {
                            Image("location-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 14, height: 18)
                            Text("Jeddah, Saudi Arabia")
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
                        Button(action: {}) { Image("nav-icon-home").resizable().renderingMode(.original).aspectRatio(contentMode: .fit).frame(width: 20, height: 22) }
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
    }
}
