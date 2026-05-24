import SwiftUI

struct BookingDetailsView: View {
    let restaurant: Restaurant?
    let activity: Activity?
    let seasonEvent: SeasonEvent?
    let selectedDate: Date?
    let selectedTime: String
    let selectedBranch: String
    let quantity: Int

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var selectedAdditionalServices: Set<String> = []
    @State private var showAdditionalServicesPopup = false
    @State private var additionalServicesFieldFrame: CGRect = .zero
    @State private var ticketCode: String = BookingTicketCode.new()

    private static let rootCoordinateSpaceName = "bookingDetailsRoot"

    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)
    private let pageBg = Color(red: 0xF3 / 255.0, green: 0xF3 / 255.0, blue: 0xF3 / 255.0)
    private let fieldBg = Color(red: 0xFA / 255.0, green: 0xFA / 255.0, blue: 0xFA / 255.0)
    private let fieldStroke = Color(red: 0xEC / 255.0, green: 0xED / 255.0, blue: 0xF0 / 255.0)
    private let chevronBoxBg = Color(red: 0xEE / 255.0, green: 0xEE / 255.0, blue: 0xEE / 255.0)

    private var isArabic: Bool { languageManager.current == .arabic }

    private var dateString: String {
        guard let date = selectedDate else { return "—" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        formatter.locale = isArabic ? Locale(identifier: "ar") : Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    private var displayName: String {
        if let r = restaurant { return isArabic ? r.arabicName : r.name }
        if let a = activity { return a.name }
        if let e = seasonEvent { return e.name }
        return ""
    }

    private var displayImage: String {
        restaurant?.imageName ?? activity?.imageName ?? seasonEvent?.imageName ?? ""
    }

    private var additionalServicesFieldText: String {
        if selectedAdditionalServices.isEmpty {
            return isArabic ? "اختر الخدمات" : "Select services"
        }
        return AdditionalServiceLocalization.joinedDisplay(services: selectedAdditionalServices, arabic: isArabic)
    }

    var body: some View {
        ZStack(alignment: .top) {
            pageBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Brown bar only — same height as RestaurantDetailView / ActivityDetailView (90pt); logo in overlay.
                brandBrown
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 90)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(isArabic ? "تفاصيل الحجز" : "Booking Details")
                            .font(.custom("ExpoArabic-Medium", size: 20))
                            .foregroundColor(textGreen)
                            .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                            .padding(.horizontal, 21)
                            .padding(.top, 14)

                        bookingCard

                        Text(isArabic ? "خدمات إضافية" : "Additional Services")
                            .font(.custom("ExpoArabic-Medium", size: 10))
                            .foregroundColor(textGreen.opacity(0.79))
                            .padding(.top, 16)
                            .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                            .padding(.horizontal, 21)

                        Button(action: { showAdditionalServicesPopup = true }) {
                            HStack(spacing: 8) {
                                Text(additionalServicesFieldText)
                                    .font(.custom("ExpoArabic-Medium", size: 12))
                                    .foregroundColor(selectedAdditionalServices.isEmpty ? textGreen.opacity(0.45) : textGreen)
                                    .lineLimit(2)
                                    .multilineTextAlignment(isArabic ? .trailing : .leading)
                                    .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)

                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(chevronBoxBg)
                                        .frame(width: 37, height: 37)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(Color(red: 0x88 / 255.0, green: 0x88 / 255.0, blue: 0x88 / 255.0))
                                }
                            }
                            .padding(.leading, 13)
                            .padding(.trailing, 5)
                            .padding(.vertical, 5)
                            .frame(minHeight: 48)
                            .background(fieldBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(fieldStroke, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .background(
                                GeometryReader { g in
                                    Color.clear.preference(
                                        key: AdditionalServicesFieldFramePreference.self,
                                        value: g.frame(in: .named(Self.rootCoordinateSpaceName))
                                    )
                                }
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 8)
                        .padding(.horizontal, 21)
                        .padding(.bottom, 20)
                    }
                    .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
                }

                Spacer(minLength: 0)

                NavigationLink(destination: BookingConfirmationView(
                    restaurant: restaurant,
                    activity: activity,
                    seasonEvent: seasonEvent,
                    selectedDate: selectedDate,
                    selectedTime: selectedTime,
                    selectedBranch: selectedBranch,
                    quantity: quantity,
                    ticketCode: ticketCode,
                    selectedAdditionalServices: selectedAdditionalServices
                )) {
                    Text(isArabic ? "تأكيد" : "Confirm")
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
                .padding(.bottom, 12)

                bottomNav
            }
            .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)

            // Header chrome — back + logo + menu (same as RestaurantDetailView).
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
            .zIndex(10)
        }
        .coordinateSpace(name: Self.rootCoordinateSpaceName)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onPreferenceChange(AdditionalServicesFieldFramePreference.self) { rect in
            additionalServicesFieldFrame = rect
        }
        .overlay {
            if showAdditionalServicesPopup {
                AdditionalServicesPopupView(
                    isPresented: $showAdditionalServicesPopup,
                    selection: $selectedAdditionalServices,
                    fieldFrame: additionalServicesFieldFrame
                )
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showAdditionalServicesPopup)
    }

    private var bookingCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !displayImage.isEmpty {
                Image(displayImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 168)
                    .clipped()
                    .cornerRadius(7)
                    .padding(.top, 10)
                    .padding(.horizontal, 12)
            }

            Text(displayName)
                .font(.custom("ExpoArabic-Medium", size: 24))
                .foregroundColor(textGreen)
                .padding(.top, 16)
                .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)

            // Figma 1017:2086 — no cuisine/category under title; icon rows only (date → time → place → passengers).
            detailRow(icon: "booking-calendar", text: dateString)
                .padding(.top, 16)
            // Asset names: `booking-passengers` = clock art, `booking-clock` = pin, `booking-fork` = guests (see BookingConfirmationView).
            detailRow(icon: "booking-passengers", text: selectedTime)
                .padding(.top, 14)
            detailRow(icon: "booking-clock", text: selectedBranch, underline: true)
                .padding(.top, 14)
            detailRow(
                icon: "booking-fork",
                text: isArabic
                    ? (quantity == 1 ? "حتى راكب واحد" : "حتى \(quantity) ركاب")
                    : (quantity == 1 ? "Up to 1 passenger" : "Up to \(quantity) passengers")
            )
                .padding(.top, 14)
        }
        .padding(.horizontal, 13)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(9)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 21)
        .padding(.top, 20)
    }

    private func detailRow(icon: String, text: String, underline: Bool = false) -> some View {
        HStack(spacing: 10) {
            Image(icon)
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18)
            Text(text)
                .font(.custom("ExpoArabic-Medium", size: 11))
                .foregroundColor(textGreen)
                .underline(underline)
        }
        .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
    }

    private var bottomNav: some View {
        ZStack {
            brandBrown.ignoresSafeArea(edges: .bottom)
            HStack(spacing: 0) {
                Spacer()
                NavigationLink(destination: CategorySelectionView()) {
                    Image("nav-icon-home").resizable().renderingMode(.original).aspectRatio(contentMode: .fit).frame(width: 20, height: 22)
                }
                .buttonStyle(PlainButtonStyle())
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
            seasonEvent: nil,
            selectedDate: Date(),
            selectedTime: "1:00PM",
            selectedBranch: "Albasateen Mall, Alrawdha",
            quantity: 4
        )
        .environmentObject(ReservationStore())
        .environmentObject(InvitationStore())
        .environmentObject(LanguageManager())
    }
}
