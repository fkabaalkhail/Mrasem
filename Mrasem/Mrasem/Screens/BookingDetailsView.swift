import SwiftUI

struct BookingDetailsView: View {
    let restaurant: Restaurant?
    let activity: Activity?
    let selectedDate: Date?
    let selectedTime: String
    let selectedBranch: String
    let quantity: Int
    
    @Environment(\.dismiss) private var dismiss
    
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
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top brown header
                ZStack {
                    brandBrown.ignoresSafeArea(edges: .top)
                    
                    VStack(spacing: 0) {
                        HStack(alignment: .center) {
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                            }
                            
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
                        
                        Spacer()
                        
                        Text("Booking Details")
                            .font(.custom("ExpoArabic-Medium", size: 20))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 21)
                            .padding(.bottom, 14)
                    }
                }
                .frame(height: 135)
                
                // Booking card
                VStack(alignment: .leading, spacing: 0) {
                    // Restaurant image — wider per Figma (288px)
                    Image(displayImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 168)
                        .clipped()
                        .cornerRadius(7)
                        .padding(.top, 10)
                        .padding(.horizontal, 12)
                    
                    // Restaurant name
                    Text(displayName)
                        .font(.custom("ExpoArabic-Medium", size: 24))
                        .fontWeight(.medium)
                        .foregroundColor(textGreen)
                        .padding(.top, 16)
                    
                    // Cuisine — fork icon (Group-1.png)
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
                                .foregroundColor(textGreen.opacity(0.7))
                        }
                        .padding(.top, 6)
                    }
                    
                    Divider().padding(.top, 16)
                    
                    // Date — calendar icon
                    HStack(spacing: 10) {
                        Image("booking-calendar")
                            .resizable()
                            .renderingMode(.original)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18, height: 18)
                        Text(dateString)
                            .font(.custom("ExpoArabic-Medium", size: 11))
                            .fontWeight(.medium)
                            .foregroundColor(textGreen)
                    }
                    .padding(.top, 16)
                    
                    // Time — clock icon (Group-2.png)
                    HStack(spacing: 10) {
                        Image("booking-passengers")
                            .resizable()
                            .renderingMode(.original)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18, height: 18)
                        Text(selectedTime)
                            .font(.custom("ExpoArabic-Medium", size: 11))
                            .fontWeight(.medium)
                            .foregroundColor(textGreen)
                    }
                    .padding(.top, 14)
                    
                    // Location / Branch — location pin (Group.png)
                    HStack(spacing: 10) {
                        Image("booking-clock")
                            .resizable()
                            .renderingMode(.original)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18, height: 18)
                        Text(selectedBranch)
                            .font(.custom("ExpoArabic-Medium", size: 11))
                            .fontWeight(.medium)
                            .foregroundColor(textGreen)
                    }
                    .padding(.top, 14)
                    
                    // Passengers — person icon (Group-3.png)
                    HStack(spacing: 10) {
                        Image("booking-fork")
                            .resizable()
                            .renderingMode(.original)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18, height: 18)
                        Text("Up to \(quantity) passengers")
                            .font(.custom("ExpoArabic-Medium", size: 11))
                            .fontWeight(.medium)
                            .foregroundColor(textGreen)
                    }
                    .padding(.top, 14)
                }
                .padding(.horizontal, 13)
                .padding(.bottom, 20)
                .frame(maxWidth: 313, alignment: .leading)
                .background(Color.white)
                .cornerRadius(9)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                .padding(.top, 30)
                
                Spacer()
                
                // Confirm button
                NavigationLink(destination: BookingConfirmationView(
                    restaurant: restaurant,
                    activity: activity,
                    selectedDate: selectedDate,
                    selectedTime: selectedTime,
                    selectedBranch: selectedBranch,
                    quantity: quantity
                )) {
                    Text("Confirm")
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
        BookingDetailsView(
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
