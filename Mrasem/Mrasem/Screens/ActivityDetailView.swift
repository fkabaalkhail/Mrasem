import SwiftUI

struct ActivityDetailView: View {
    let activity: Activity
    @Environment(\.dismiss) private var dismiss
    @State private var isFavorite: Bool = false
    @State private var quantity: Int = 1
    @State private var currentImageIndex: Int = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            // Light gray background
            Color(red: 0xF3 / 255.0, green: 0xF3 / 255.0, blue: 0xF3 / 255.0)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top brown section
                Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 60)
                
                // Main activity image with carousel
                ZStack(alignment: .topTrailing) {
                    Image(activity.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width, height: 185)
                        .clipped()
                    
                    // Heart button
                    Button(action: {
                        isFavorite.toggle()
                    }) {
                        ZStack {
                            Image("heart-icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                            
                            Image("base")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                        }
                    }
                    .padding(.top, 7)
                    .padding(.trailing, 18)
                }
                .offset(y: -10)
                
                // Carousel dots
                HStack(spacing: 6) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(index == currentImageIndex ? Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0) : Color(red: 0xD9 / 255.0, green: 0xD9 / 255.0, blue: 0xD9 / 255.0))
                            .frame(width: 8, height: 8)
                    }
                }
                .offset(y: -20)
                
                // Content section
                VStack(alignment: .leading, spacing: 0) {
                    // Activity name
                    Text(activity.name)
                        .font(.custom("ExpoArabic-Medium", size: 20))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0))
                        .padding(.horizontal, 21)
                        .padding(.top, 10)
                    
                    // Category type
                    Text(activity.category)
                        .font(.custom("ExpoArabic-Medium", size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0).opacity(0.58))
                        .padding(.leading, 21)
                        .padding(.top, 5)
                    
                    // About section
                    Text("About")
                        .font(.custom("ExpoArabic-Medium", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0))
                        .padding(.leading, 21)
                        .padding(.top, 20)
                    
                    // Description
                    Text(activity.description)
                        .font(.custom("ExpoArabic-Medium", size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0).opacity(0.81))
                        .lineSpacing(4)
                        .padding(.horizontal, 21)
                        .padding(.top, 12)
                    
                    // Location
                    HStack(spacing: 6) {
                        Image("location-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 14, height: 18)
                        
                        Text(activity.location)
                            .font(.custom("ExpoArabic-Medium", size: 12))
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0).opacity(0.79))
                    }
                    .padding(.leading, 21)
                    .padding(.top, 25)
                    
                    Spacer()
                    
                    // Book button and quantity controls
                    HStack(spacing: 20) {
                        // Book button
                        NavigationLink(destination: BookingView(activity: activity)) {
                            Text("Book")
                                .font(.custom("ExpoArabic-Medium", size: 22))
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(width: 197, height: 56)
                                .background(Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0))
                                .cornerRadius(13)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        // Quantity controls
                        HStack(spacing: 12) {
                            // Plus button
                            Button(action: {
                                quantity += 1
                            }) {
                                Circle()
                                    .fill(Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0))
                                    .frame(width: 27, height: 27)
                                    .overlay(
                                        Image(systemName: "plus")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                            }
                            
                            // Quantity
                            Text("\(quantity)")
                                .font(.custom("ExpoArabic-Medium", size: 24))
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0))
                                .frame(width: 18)
                            
                            // Minus button
                            Button(action: {
                                if quantity > 1 {
                                    quantity -= 1
                                }
                            }) {
                                Circle()
                                    .fill(Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0))
                                    .frame(width: 27, height: 27)
                                    .overlay(
                                        Image(systemName: "minus")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 21)
                    .padding(.bottom, 20)
                }
                
                // Bottom navigation bar
                ZStack(alignment: .center) {
                    Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)
                        .ignoresSafeArea(edges: .bottom)
                    
                    HStack(spacing: 0) {
                        Spacer()
                        
                        Button(action: {}) {
                            VStack {
                                Spacer()
                                Image("nav-home")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                Spacer()
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            VStack {
                                Spacer()
                                Image("nav-calendar")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                Spacer()
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            VStack {
                                Spacer()
                                Image("nav-ticket")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                Spacer()
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            VStack {
                                Spacer()
                                Image("nav-profile-bottom")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                Spacer()
                            }
                        }
                        
                        Spacer()
                    }
                }
                .frame(height: 35)
            }
            
            // Header overlay with back and menu buttons - on top of everything
            VStack {
                HStack(alignment: .center) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 14, height: 25)
                    }
                    .frame(width: 44, height: 44)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image("menu-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 20)
                    }
                    .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 24)
                .padding(.top, 5)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        ActivityDetailView(activity: Activity(name: "Scuba Diving", rating: 4.5, category: "Free Diving", imageName: "activity-scuba", location: "Jeddah, Saudi Arabia", description: "Explore the Red Sea with a professional 5-hour diving experience from Jeddah. Swim among colorful coral reefs and vibrant marine life, guided by certified instructors at dive sites suited to all levels. Small groups, top-notch gear, and clear waters make this an unforgettable underwater adventure. Your Red Sea journey starts here."))
    }
}

