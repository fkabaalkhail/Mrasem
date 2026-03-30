import SwiftUI

struct SeasonEventDetailView: View {
    let event: SeasonEvent
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageManager: LanguageManager

    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)

    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 0xF3 / 255.0, green: 0xF3 / 255.0, blue: 0xF3 / 255.0)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Brown header background (no buttons — those are in overlay)
                brandBrown.ignoresSafeArea(edges: .top)
                    .frame(height: 110)

                // Event image — full width, edge-to-edge
                Image(event.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 185)
                    .clipped()

                // Content
                VStack(alignment: .leading, spacing: 0) {
                    Text(event.name)
                        .font(.custom("ExpoArabic-Medium", size: 20))
                        .fontWeight(.medium)
                        .foregroundColor(textGreen)
                        .padding(.top, 14)

                    // Category
                    HStack(spacing: 6) {
                        Image("fork-knife-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 14, height: 14)
                        Text(event.category)
                            .font(.custom("ExpoArabic-Medium", size: 12))
                            .fontWeight(.medium)
                            .foregroundColor(textGreen.opacity(0.7))
                    }
                    .padding(.top, 5)

                    // About
                    Text("About")
                        .font(.custom("ExpoArabic-Medium", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(textGreen)
                        .padding(.top, 20)

                    Text(event.description)
                        .font(.custom("ExpoArabic-Medium", size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(textGreen.opacity(0.81))
                        .lineSpacing(4)
                        .padding(.top, 12)

                    // Location
                    HStack(spacing: 6) {
                        Image("location-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 14, height: 18)
                        Text(event.location)
                            .font(.custom("ExpoArabic-Medium", size: 12))
                            .fontWeight(.medium)
                            .foregroundColor(textGreen.opacity(0.79))
                    }
                    .padding(.top, 25)

                    Spacer()

                    // Book button — full width
                    NavigationLink(destination: BookingView(restaurant: nil, activity: nil)) {
                        Text("Book")
                            .font(.custom("ExpoArabic-Medium", size: 22))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(brandBrown)
                            .cornerRadius(13)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 21)

                // Brown bottom nav — 5 icons
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

            // Header overlay — back + logo + menu on top so back button is always tappable
            VStack {
                HStack(alignment: .center) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
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
                }
                .padding(.horizontal, 16)
                .padding(.top, 44)

                Spacer()
            }
            .allowsHitTesting(true)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        SeasonEventDetailView(
            event: SeasonEvent(
                name: "Winter Wonderland",
                category: "Seasonal Attraction",
                imageName: "season-winter-wonderland",
                location: "Jeddah, Saudi Arabia",
                description: "Step into a magical winter experience in the heart of Jeddah."
            )
        )
        .environmentObject(LanguageManager())
    }
}
