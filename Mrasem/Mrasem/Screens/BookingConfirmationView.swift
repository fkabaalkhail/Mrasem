import SwiftUI

struct BookingConfirmationView: View {
    let restaurant: Restaurant?
    let activity: Activity?
    let selectedDate: Date?
    let selectedTime: String
    let selectedBranch: String
    let quantity: Int
    
    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)
    
    private var dateString: String {
        guard let date = selectedDate else { return "—" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    private var displayName: String {
        if let r = restaurant { return r.name + " Restaurant" }
        if let a = activity { return a.name }
        return ""
    }
    
    private var displayImage: String {
        restaurant?.imageName ?? activity?.imageName ?? ""
    }
    
    private var displayCuisine: String {
        restaurant?.cuisine ?? ""
    }
    
    var body: some View {
        ZStack {
            Color(red: 0xF3 / 255.0, green: 0xF3 / 255.0, blue: 0xF3 / 255.0)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top brown header — no back arrow, just logo + menu
                ZStack {
                    brandBrown.ignoresSafeArea(edges: .top)
                    
                    HStack(alignment: .center) {
                        Color.clear.frame(width: 44, height: 44)
                        
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
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 90)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Checkmark + confirmation title
                        HStack(spacing: 12) {
                            Image("booking-checkmark")
                                .resizable()
                                .renderingMode(.original)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                            
                            Text("Your Booking is Confirmed!")
                                .font(.custom("ExpoArabic-Medium", size: 20))
                                .fontWeight(.medium)
                                .foregroundColor(textGreen)
                        }
                        .padding(.top, 30)
                        .padding(.horizontal, 21)
                        
                        // Confirmation message
                        Text("Your booking has been successfully confirmed! A confirmation message will be sent to your phone number +966 559035417.")
                            .font(.custom("ExpoArabic-Medium", size: 12))
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                            .frame(width: 307, alignment: .topLeading)
                            .lineSpacing(4)
                            .padding(.top, 16)
                            .padding(.horizontal, 21)
                        
                        // Booking Details title
                        Text("Booking Details")
                            .font(.custom("ExpoArabic-Medium", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(brandBrown)
                            .padding(.top, 30)
                            .padding(.horizontal, 21)
                        
                        // Restaurant name + image row
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(displayName)
                                    .font(.custom("ExpoArabic-Medium", size: 20))
                                    .fontWeight(.bold)
                                    .foregroundColor(brandBrown)
                                
                                if !displayCuisine.isEmpty {
                                    HStack(spacing: 6) {
                                        Image("booking-location")
                                            .resizable()
                                            .renderingMode(.original)
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 16, height: 16)
                                        Text(displayCuisine)
                                            .font(.custom("ExpoArabic-Medium", size: 12))
                                            .fontWeight(.medium)
                                            .foregroundColor(brandBrown.opacity(0.7))
                                    }
                                    .padding(.top, 6)
                                }
                            }
                            
                            Spacer()
                            
                            Image(displayImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 90, height: 60)
                                .clipped()
                                .cornerRadius(7)
                        }
                        .padding(.top, 14)
                        .padding(.horizontal, 21)
                        
                        Divider().padding(.top, 16).padding(.horizontal, 21)
                        
                        // Date
                        HStack(spacing: 10) {
                            Image("booking-calendar")
                                .resizable()
                                .renderingMode(.original)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 18, height: 18)
                            Text(dateString)
                                .font(.custom("ExpoArabic-Medium", size: 12))
                                .fontWeight(.medium)
                                .foregroundColor(brandBrown)
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 21)
                        
                        // Time — clock (Group-2.png)
                        HStack(spacing: 10) {
                            Image("booking-passengers")
                                .resizable()
                                .renderingMode(.original)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 18, height: 18)
                            Text(selectedTime)
                                .font(.custom("ExpoArabic-Medium", size: 12))
                                .fontWeight(.medium)
                                .foregroundColor(brandBrown)
                        }
                        .padding(.top, 14)
                        .padding(.horizontal, 21)
                        
                        // Branch / Location — pin (Group.png)
                        HStack(spacing: 10) {
                            Image("booking-clock")
                                .resizable()
                                .renderingMode(.original)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 18, height: 18)
                            Text(selectedBranch)
                                .font(.custom("ExpoArabic-Medium", size: 12))
                                .fontWeight(.medium)
                                .foregroundColor(brandBrown)
                                .underline()
                        }
                        .padding(.top, 14)
                        .padding(.horizontal, 21)
                        
                        // Passengers — person (Group-3.png)
                        HStack(spacing: 10) {
                            Image("booking-fork")
                                .resizable()
                                .renderingMode(.original)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 18, height: 18)
                            Text("Up to \(quantity) passengers")
                                .font(.custom("ExpoArabic-Medium", size: 12))
                                .fontWeight(.medium)
                                .foregroundColor(brandBrown)
                        }
                        .padding(.top, 14)
                        .padding(.horizontal, 21)
                        .padding(.bottom, 30)
                    }
                }
                
                Spacer()
                
                // Back to Home button
                NavigationLink(destination: RestaurantListView()
                    .navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true)
                ) {
                    Text("Back to Home")
                        .font(.custom("ExpoArabic-Medium", size: 22))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(width: 280, height: 56)
                        .background(brandBrown)
                        .cornerRadius(13)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 20)
                
                // Bottom nav bar
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
        BookingConfirmationView(
            restaurant: Restaurant(
                name: "Myazu",
                arabicName: "ميازو",
                rating: 4.5,
                cuisine: "Japanese, Sushi",
                arabicCuisine: "ياباني، سوشي",
                imageName: "restaurant-myazu",
                hasMichelin: true,
                description: "Myazu Jeddah delivers contemporary Japanese fusion dining.",
                arabicDescription: "ميازو يقدّم تجربة طعام يابانية عصرية."
            ),
            activity: nil,
            selectedDate: Date(),
            selectedTime: "1:00PM",
            selectedBranch: "Albasateen Mall, Alrawdha",
            quantity: 4
        )
    }
}
