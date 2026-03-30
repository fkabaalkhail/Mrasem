import SwiftUI

struct BookingView: View {
    let restaurant: Restaurant?
    let activity: Activity?
    
    init(restaurant: Restaurant? = nil, activity: Activity? = nil) {
        self.restaurant = restaurant
        self.activity = activity
    }
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate: Date?
    @State private var currentMonth: Date = Date()
    @State private var quantity: Int = 1
    @State private var selectedTime: String? = "1:00PM"
    @State private var selectedBranch: String = "Al-Basateen Mall"
    
    private let calendar = Calendar.current
    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)
    
    private let timeSlots = ["1:00PM", "3:00PM", "5:30PM", "7:10PM"]
    private let branches = ["Al-Basateen Mall"]
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top brown header with back arrow, logo, menu icon
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
                        
                        // Title
                        Spacer()
                        
                        Text("Choose Date & Branch")
                            .font(.custom("ExpoArabic-Medium", size: 20))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 21)
                            .padding(.bottom, 14)
                    }
                }
                .frame(height: 160)
                
                // Scrollable content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Month and year navigation
                        HStack {
                            Button(action: {
                                currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(textGreen)
                            }
                            
                            Spacer()
                            
                            Text(monthYearString)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 0x3D / 255.0, green: 0x2F / 255.0, blue: 0x4B / 255.0))
                                .textCase(.uppercase)
                            
                            Spacer()
                            
                            Button(action: {
                                currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(textGreen)
                            }
                        }
                        .padding(.horizontal, 31)
                        .frame(width: 360)
                        .padding(.top, 14)
                        
                        // Days of week header
                        HStack(spacing: 4) {
                            ForEach(["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"], id: \.self) { day in
                                Text(day)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(red: 0x3D / 255.0, green: 0x2F / 255.0, blue: 0x4B / 255.0))
                                    .frame(width: 48, height: 27)
                            }
                        }
                        .frame(width: 360)
                        .padding(.top, 8)
                        
                        // Calendar grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                            ForEach(calendarDays, id: \.self) { date in
                                if let date = date {
                                    DateButton(
                                        date: date,
                                        isSelected: selectedDate != nil && calendar.isDate(date, inSameDayAs: selectedDate!),
                                        isDisabled: date < calendar.startOfDay(for: Date())
                                    ) {
                                        if date >= calendar.startOfDay(for: Date()) {
                                            selectedDate = date
                                        }
                                    }
                                } else {
                                    Color.clear.frame(width: 48, height: 56)
                                }
                            }
                        }
                        .frame(width: 360)
                        .padding(.top, 8)
                        
                        // Select Time
                        Text("Select Time")
                            .font(.custom("ExpoArabic-Medium", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(textGreen.opacity(0.84))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 21)
                            .padding(.top, 20)
                        
                        // Time slots
                        HStack(spacing: 8) {
                            ForEach(timeSlots, id: \.self) { time in
                                Button(action: { selectedTime = time }) {
                                    Text(time)
                                        .font(.custom("ExpoArabic-Medium", size: 12))
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedTime == time ? .white : textGreen)
                                        .frame(width: 76, height: 26)
                                        .background(selectedTime == time ? textGreen : Color.clear)
                                        .cornerRadius(5)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(textGreen, lineWidth: 1)
                                        )
                                }
                            }
                            Spacer()
                        }
                        .padding(.leading, 21)
                        .padding(.top, 12)
                        
                        // Select Branch
                        Text("Select Branch")
                            .font(.custom("ExpoArabic-Medium", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(textGreen.opacity(0.84))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 21)
                            .padding(.top, 20)
                        
                        // Branch pills
                        HStack(spacing: 8) {
                            ForEach(branches, id: \.self) { branch in
                                Button(action: { selectedBranch = branch }) {
                                    Text(branch)
                                        .font(.custom("ExpoArabic-Medium", size: 12))
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedBranch == branch ? .white : textGreen)
                                        .padding(.horizontal, 12)
                                        .frame(height: 26)
                                        .background(selectedBranch == branch ? textGreen : Color.clear)
                                        .cornerRadius(5)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(textGreen, lineWidth: 1)
                                        )
                                }
                            }
                            Spacer()
                        }
                        .padding(.leading, 21)
                        .padding(.top, 12)
                        .padding(.bottom, 20)
                    }
                }
                
                // Next button and quantity controls
                HStack(spacing: 20) {
                    NavigationLink(destination: BookingDetailsView(
                        restaurant: restaurant,
                        activity: activity,
                        selectedDate: selectedDate,
                        selectedTime: selectedTime ?? "1:00PM",
                        selectedBranch: selectedBranch,
                        quantity: quantity
                    )) {
                        Text("Next")
                            .font(.custom("ExpoArabic-Medium", size: 22))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(width: 197, height: 56)
                            .background(brandBrown)
                            .cornerRadius(13)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: { quantity += 1 }) {
                            Circle()
                                .fill(brandBrown)
                                .frame(width: 27, height: 27)
                                .overlay(
                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                        
                        Text("\(quantity)")
                            .font(.custom("ExpoArabic-Medium", size: 24))
                            .fontWeight(.medium)
                            .foregroundColor(brandBrown)
                            .frame(width: 18)
                        
                        Button(action: { if quantity > 1 { quantity -= 1 } }) {
                            Circle()
                                .fill(brandBrown)
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
                .padding(.bottom, 16)
                
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
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var calendarDays: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.end - 1) else {
            return []
        }
        
        var days: [Date?] = []
        var currentDate = monthFirstWeek.start
        
        while currentDate < monthLastWeek.end {
            if calendar.component(.month, from: currentDate) == calendar.component(.month, from: currentMonth) {
                days.append(currentDate)
            } else {
                days.append(nil)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
}

struct TimeSlotButton: View {
    let time: String
    @State private var isSelected: Bool = false
    
    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)
    
    var body: some View {
        Button(action: { isSelected.toggle() }) {
            Text(time)
                .font(.custom("ExpoArabic-Medium", size: 12))
                .fontWeight(.medium)
                .foregroundColor(textGreen)
                .frame(width: 76, height: 26)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(textGreen, lineWidth: 1)
                )
        }
    }
}

struct DateButton: View {
    let date: Date
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    private let calendar = Calendar.current
    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isDisabled ? textGreen.opacity(0.3) : (isSelected ? textGreen : Color(red: 0x3D / 255.0, green: 0x2F / 255.0, blue: 0x4B / 255.0)))
            }
            .frame(width: 48, height: 56)
            .background(isSelected ? textGreen.opacity(0.48) : Color.clear)
            .cornerRadius(4)
        }
        .disabled(isDisabled)
    }
}

#Preview {
    NavigationStack {
        BookingView(
            restaurant: Restaurant(
                name: "Le Vesuvio",
                arabicName: "لي فيزوفيو",
                rating: 4.5,
                cuisine: "Italian, Pizza",
                arabicCuisine: "إيطالي، بيتزا",
                imageName: "restaurant-le-vesuvio",
                hasMichelin: false,
                description: "Le Vesuvio offers authentic Italian dining.",
                arabicDescription: "يقدّم لي فيزوفيو تجربة طعام إيطالية أصيلة."
            ),
            activity: nil
        )
    }
}
