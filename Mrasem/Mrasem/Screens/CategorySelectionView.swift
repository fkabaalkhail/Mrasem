import SwiftUI

struct CategorySelectionView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Image("bottom-icons")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 59)
                    .padding(.top, 50)
                
                Text(languageManager.current == .arabic ? "اختر من القائمة:" : "Select from the category:")
                    .font(.custom("ExpoArabic-Medium", size: 20))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0))
                    .frame(maxWidth: .infinity, alignment: languageManager.current == .arabic ? .trailing : .leading)
                    .padding(.horizontal, 23)
                    .padding(.top, 15)
                
                VStack(spacing: 27) {
                    HStack(spacing: 30) {
                        NavigationLink(destination: SeasonEventsListView().environmentObject(languageManager)) {
                            CategoryCard(
                                title: languageManager.current == .arabic ? "فعاليات الموسم" : "Season Events",
                                imageName: "season-events",
                                isRTL: languageManager.current == .arabic
                            )
                        }
                        
                        NavigationLink(destination: ActivitiesListView().environmentObject(languageManager)) {
                            CategoryCard(
                                title: languageManager.current == .arabic ? "الأنشطة والجولات السياحية" : "Activities and Tours",
                                imageName: "activities-tours",
                                isRTL: languageManager.current == .arabic
                            )
                        }
                    }
                    
                    HStack(spacing: 30) {
                        NavigationLink(destination: RestaurantListView().environmentObject(languageManager)) {
                            CategoryCard(
                                title: languageManager.current == .arabic ? "المطاعم" : "Restaurants",
                                imageName: "restaurants",
                                isRTL: languageManager.current == .arabic
                            )
                        }
                        
                        CategoryCard(
                            title: languageManager.current == .arabic ? "حجز السيارات" : "Car Booking",
                            imageName: "car-booking",
                            isRTL: languageManager.current == .arabic
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 35)

                Image("bottom-icons")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 59)
                    .padding(.top, 35)
                
                Button(action: {}) {
                    Text(languageManager.current == .arabic ? "ابدأ الان" : "Get Started")
                        .font(.custom("ExpoArabic-Medium", size: 20))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(width: 287, height: 56)
                        .background(Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0))
                        .cornerRadius(13)
                }
                .padding(.top, 25)
                .padding(.bottom, 34)
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }
}

struct CategoryCard: View {
    let title: String
    let imageName: String
    var isRTL: Bool = false
    
    var body: some View {
        ZStack(alignment: isRTL ? .bottomTrailing : .bottomLeading) {
            Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                .frame(width: 148, height: 181)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: 148, height: 181)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Text(title)
                .font(.custom("ExpoArabic-Medium", size: 16))
                .fontWeight(.medium)
                .foregroundColor(.white)
                .lineLimit(2)
                .frame(width: 130, alignment: isRTL ? .trailing : .leading)
                .padding(.bottom, 12)
                .padding(isRTL ? .trailing : .leading, 12)
        }
        .frame(width: 148, height: 181)
    }
}

#Preview {
    CategorySelectionView()
}
