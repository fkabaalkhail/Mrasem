import SwiftUI

struct ActivityDetailView: View {
    let activity: Activity
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss
    @State private var isFavorite: Bool = false
    @State private var currentImageIndex: Int = 0

    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)
    private let pageBg = Color(red: 0xF3 / 255.0, green: 0xF3 / 255.0, blue: 0xF3 / 255.0)

    private var isArabic: Bool { languageManager.current == .arabic }

    var body: some View {
        ZStack(alignment: .top) {
            pageBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Brown header — matches restaurant (90pt)
                brandBrown
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 90)

                // Hero image — 185pt, full width, heart + pager dots
                ZStack(alignment: .topTrailing) {
                    pageBg
                    GeometryReader { geo in
                        RemoteImage(imageName: activity.imageName)
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

                // Content
                VStack(alignment: .leading, spacing: 0) {
                    // Title
                    Text(activity.displayTitle(isArabic: isArabic))
                        .font(.custom("ExpoArabic-Medium", size: 20))
                        .fontWeight(.medium)
                        .foregroundColor(textGreen)
                        .multilineTextAlignment(isArabic ? .trailing : .leading)
                        .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                        .padding(.horizontal, 21)
                        .padding(.top, 14)

                    // Category
                    Text(activity.displayCategory(isArabic: isArabic))
                        .font(.custom("ExpoArabic-Medium", size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(textGreen.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                        .padding(.horizontal, 21)
                        .padding(.top, 5)

                    // About
                    Text(isArabic ? "عن التجربة" : "About")
                        .font(.custom("ExpoArabic-Medium", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(textGreen)
                        .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                        .padding(.horizontal, 21)
                        .padding(.top, 20)

                    Text(activity.displayDescription(isArabic: isArabic))
                        .font(.custom("ExpoArabic-Medium", size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(textGreen.opacity(0.81))
                        .lineSpacing(4)
                        .multilineTextAlignment(isArabic ? .trailing : .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 21)
                        .padding(.top, 12)

                    if let safety = activity.displaySafetyGuidelines(isArabic: isArabic) {
                        Text(isArabic ? "إرشادات السلامة" : "Safety Guidelines")
                            .font(.custom("ExpoArabic-Medium", size: 15))
                            .fontWeight(.medium)
                            .foregroundColor(textGreen)
                            .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                            .padding(.horizontal, 21)
                            .padding(.top, 22)

                        Text(safety)
                            .font(.custom("ExpoArabic-Medium", size: 12))
                            .fontWeight(.medium)
                            .foregroundColor(textGreen.opacity(0.81))
                            .lineSpacing(4)
                            .multilineTextAlignment(isArabic ? .trailing : .leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 21)
                            .padding(.top, 8)
                    }

                    // Location
                    HStack(spacing: 6) {
                        if isArabic {
                            Text(activity.displayLocation(isArabic: true))
                                .font(.custom("ExpoArabic-Medium", size: 12))
                                .fontWeight(.medium)
                                .foregroundColor(textGreen.opacity(0.79))
                            Image("location-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 14, height: 18)
                        } else {
                            Image("location-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 14, height: 18)
                            Text(activity.displayLocation(isArabic: false))
                                .font(.custom("ExpoArabic-Medium", size: 12))
                                .fontWeight(.medium)
                                .foregroundColor(textGreen.opacity(0.79))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                    .padding(.horizontal, 21)
                    .padding(.top, 25)

                    Spacer()

                    // Book button — matches restaurant padding
                    NavigationLink(destination: BookingView(activity: activity)) {
                        Text(isArabic ? "احجز" : "Book")
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

                // Bottom tab bar
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

            // Header overlay — back + logo + menu
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
                    .buttonStyle(PlainButtonStyle())

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
                    .buttonStyle(PlainButtonStyle())
                }
                .environment(\.layoutDirection, .leftToRight)
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()
            }
            .allowsHitTesting(true)
            .zIndex(10)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        ActivityDetailView(activity: Activity(name: "Scuba Diving", rating: 4.5, category: "Free Diving", imageName: "activity-scuba", location: "Jeddah, Saudi Arabia", description: "Explore the Red Sea with a professional 5-hour diving experience from Jeddah. Swim among colorful coral reefs and vibrant marine life, guided by certified instructors at dive sites suited to all levels. Small groups, top-notch gear, and clear waters make this an unforgettable underwater adventure. Your Red Sea journey starts here."))
            .environmentObject(LanguageManager())
            .environmentObject(InvitationStore())
    }
}
