import SwiftUI
import UIKit

struct BookingConfirmationView: View {
    let restaurant: Restaurant?
    let activity: Activity?
    let seasonEvent: SeasonEvent?
    let selectedDate: Date?
    let selectedTime: String
    let selectedBranch: String
    let quantity: Int
    let ticketCode: String
    let selectedAdditionalServices: Set<String>

    @State private var showWalletPass = false
    @State private var showSidePanel = false
    @EnvironmentObject private var reservationStore: ReservationStore
    @EnvironmentObject private var languageManager: LanguageManager

    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)
    private let pageBg = Color(red: 0xF3 / 255.0, green: 0xF3 / 255.0, blue: 0xF3 / 255.0)
    private let confirmGray = Color(red: 0x67 / 255.0, green: 0x67 / 255.0, blue: 0x67 / 255.0)

    private var isArabic: Bool { languageManager.current == .arabic }

    private var dateString: String {
        guard let date = selectedDate else { return "—" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        formatter.locale = isArabic ? Locale(identifier: "ar") : Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    private var placeTitle: String {
        if let r = restaurant {
            return isArabic ? "\(r.arabicName) — مطعم" : r.name + " Restaurant"
        }
        if let a = activity { return a.name }
        if let e = seasonEvent { return e.name }
        return isArabic ? "الحجز" : "Booking"
    }

    /// Venue line without " Restaurant" suffix for confirmation card (Figma: e.g. "Khemah The Groves")
    private var venueDisplayName: String {
        if let r = restaurant { return isArabic ? r.arabicName : r.name }
        if let a = activity { return a.name }
        if let e = seasonEvent { return e.name }
        return isArabic ? "الحجز" : "Booking"
    }

    private var heroImageName: String {
        restaurant?.imageName ?? activity?.imageName ?? seasonEvent?.imageName ?? "mrasem-logo"
    }

    private var peopleLine: String {
        if isArabic {
            if quantity == 1 { return "حتى راكب واحد" }
            return "حتى \(quantity) ركاب"
        }
        if quantity == 1 { return "Up to 1 passenger" }
        return "Up to \(quantity) passengers"
    }

    private var additionalServicesLine: String? {
        guard !selectedAdditionalServices.isEmpty else { return nil }
        return AdditionalServiceLocalization.joinedDisplay(services: selectedAdditionalServices, arabic: isArabic)
    }

    private var hasBookingCheckAsset: Bool {
        UIImage(named: "booking-checkmark") != nil
    }

    var body: some View {
        ZStack(alignment: .top) {
            pageBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Same 90pt brown + floating logo row as RestaurantDetailView / BookingDetailsView.
                brandBrown
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 90)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        confirmationHeader
                            .padding(.top, 10)
                            .padding(.horizontal, 21)

                        bookingDetailsCard
                            .padding(.top, 28)
                            .padding(.horizontal, 21)
                            .padding(.bottom, 24)
                    }
                }

                Spacer(minLength: 0)

                VStack(spacing: 12) {
                    Button(action: { showWalletPass = true }) {
                        Image("add-to-apple-wallet-badge")
                            .resizable()
                            .renderingMode(.original)
                            .scaledToFit()
                            .frame(width: 136, height: 42)
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel(isArabic ? "إضافة إلى Apple Wallet" : "Add to Apple Wallet")

                    NavigationLink(destination: CategorySelectionView()) {
                        Text(isArabic ? "العودة للرئيسية" : "Back to Home")
                            .font(.custom("ExpoArabic-Medium", size: 22))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(brandBrown)
                            .cornerRadius(13)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 26)
                .padding(.bottom, 12)

                bottomNav
            }
            .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)

            // Centered logo + side menu — same chrome height/padding as restaurant detail (90pt bar below).
            VStack {
                HStack(alignment: .center) {
                    Color.clear.frame(width: 44, height: 44)

                    Spacer()

                    Image("mrasem-logo")
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFit()
                        .frame(height: 50)

                    Spacer()

                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.25)) { showSidePanel = true }
                    }) {
                        Image("group2")
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

            if showSidePanel {
                SidePanelView(isOpen: $showSidePanel)
                    .transition(.opacity)
                    .zIndex(20)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            reservationStore.registerCompletedBookingIfNeeded(
                ticketCode: ticketCode,
                restaurant: restaurant,
                activity: activity,
                seasonEvent: seasonEvent,
                selectedDate: selectedDate,
                selectedTime: selectedTime,
                branch: selectedBranch
            )
        }
        .sheet(isPresented: $showWalletPass) {
            NavigationStack {
                ZStack {
                    pageBg.ignoresSafeArea()
                    ScrollView {
                        VStack(spacing: 20) {
                            Text(isArabic ? "تذكرتك" : "Your ticket")
                                .font(.custom("ExpoArabic-Medium", size: 18))
                                .foregroundColor(textGreen)
                            BookingWalletPassView(
                                guestName: "Abdullah",
                                placeName: placeTitle,
                                heroImageName: heroImageName,
                                dateString: dateString,
                                ticketCode: ticketCode
                            )
                        }
                        .padding(.vertical, 24)
                    }
                }
                .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(isArabic ? "تم" : "Done") { showWalletPass = false }
                    }
                }
            }
        }
    }

    /// Figma 1202:11746 / 1017:2186 — check + title + body
    private var confirmationHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            Group {
                if hasBookingCheckAsset {
                    Image("booking-checkmark")
                        .resizable()
                        .renderingMode(.original)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color(red: 0x4C / 255.0, green: 0xAF / 255.0, blue: 0x50 / 255.0))
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text(isArabic ? "تم تأكيد حجزك!" : "Your Booking is Confirmed!")
                    .font(.custom("ExpoArabic-Medium", size: 20))
                    .foregroundColor(textGreen)

                Text(
                    isArabic
                        ? "تم تأكيد حجزك بنجاح! ستصلك رسالة تأكيد على رقم جوالك +966 559035417."
                        : "Your booking has been successfully confirmed! A confirmation message will be sent to your phone number +966 559035417."
                )
                    .font(.custom("ExpoArabic-Medium", size: 12))
                    .foregroundColor(confirmGray)
                    .lineSpacing(4)
                    .multilineTextAlignment(isArabic ? .trailing : .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    /// Figma 1202:11746 — details title, venue + thumb, icon rows
    private var bookingDetailsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(isArabic ? "تفاصيل الحجز" : "Booking Details")
                .font(.custom("ExpoArabic-Medium", size: 16))
                .foregroundColor(textGreen)

            HStack(alignment: .top, spacing: 12) {
                Text(venueDisplayName)
                    .font(.custom("ExpoArabic-Medium", size: 20))
                    .foregroundColor(brandBrown)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                    .multilineTextAlignment(isArabic ? .trailing : .leading)

                Image(heroImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 118, height: 61)
                    .clipped()
                    .cornerRadius(7)
            }
            .padding(.top, 14)

            VStack(alignment: .leading, spacing: 0) {
                // Asset PNGs follow legacy filenames: `booking-passengers` = clock art, `booking-clock` = pin,
                // `booking-location` = fork (see BookingDetailsView). Match semantics to Figma row order: date → time → branch → guests.
                confirmationDetailRow(icon: "booking-calendar", text: dateString)
                    .padding(.top, 18)
                confirmationDetailRow(icon: "booking-passengers", text: selectedTime)
                    .padding(.top, 14)
                confirmationDetailRow(icon: "booking-clock", text: selectedBranch, underline: true)
                    .padding(.top, 14)
                confirmationDetailRow(icon: "booking-fork", text: peopleLine)
                    .padding(.top, 14)
                if let line = additionalServicesLine {
                    confirmationDetailRow(systemIcon: "figure.roll", text: line)
                        .padding(.top, 14)
                }
            }
        }
    }

    private func confirmationDetailRow(icon: String, text: String, underline: Bool = false) -> some View {
        HStack(alignment: .center, spacing: 10) {
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
    }

    private func confirmationDetailRow(systemIcon: String, text: String) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: systemIcon)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(textGreen.opacity(0.85))
                .frame(width: 18, height: 18)
            Text(text)
                .font(.custom("ExpoArabic-Medium", size: 11))
                .foregroundColor(textGreen)
        }
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
            seasonEvent: nil,
            selectedDate: Date(),
            selectedTime: "1:00PM",
            selectedBranch: "Albasateen Mall, Alrawdha",
            quantity: 4,
            ticketCode: "11223344556677",
            selectedAdditionalServices: ["Wheelchair"]
        )
        .environmentObject(ReservationStore())
        .environmentObject(InvitationStore())
        .environmentObject(LanguageManager())
    }
}
