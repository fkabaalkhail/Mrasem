import SwiftUI

/// My Reservations — Figma 1331:13911 (segment `#213C2E`, dots `#213C2E` / `#D9D9D9`); cards 1202:9355 / 370:8995; history expired 370:8905.
struct MyReservationsView: View {
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var reservationStore: ReservationStore
    @EnvironmentObject private var languageManager: LanguageManager

    @State private var segment: ReservationSegment = .upcoming
    @State private var ticketPageIndex: Int = 0

    private enum ReservationSegment {
        case upcoming
        case history
    }

    private var isArabic: Bool { languageManager.current == .arabic }

    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)
    private let pageBg = Color(red: 0xF3 / 255.0, green: 0xF3 / 255.0, blue: 0xF3 / 255.0)
    private let segmentTrack = Color(red: 0xD9 / 255.0, green: 0xD9 / 255.0, blue: 0xD9 / 255.0)
    private let segmentInactiveText = Color(red: 0x87 / 255.0, green: 0x87 / 255.0, blue: 0x87 / 255.0)

    private var upcomingList: [StoredReservation] { reservationStore.upcoming }
    private var historyList: [StoredReservation] { reservationStore.history }

    private var activeList: [StoredReservation] {
        segment == .upcoming ? upcomingList : historyList
    }

    /// Figma 1331:13911 — active segment pill `#213C2E` (EN + AR).
    private var segmentActiveFill: Color { textGreen }

    var body: some View {
        GeometryReader { geo in
            let screenW = geo.size.width
            let contentDir: LayoutDirection = isArabic ? .rightToLeft : .leftToRight
            ZStack {
                pageBg.ignoresSafeArea()

                VStack(spacing: 0) {
                    headerBar

                    segmentControl
                        .padding(.top, 22)
                        .padding(.bottom, 16)

                    if activeList.isEmpty {
                        Spacer(minLength: 12)
                        emptyState
                            .padding(.horizontal, 31)
                        Spacer(minLength: 0)
                    } else {
                        ticketPager(screenWidth: screenW)
                            .environment(\.layoutDirection, contentDir)
                    }

                    reservationsBottomNav
                }
            }
            .frame(width: screenW, height: geo.size.height)
            .environment(\.layoutDirection, contentDir)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: segment) { _, _ in ticketPageIndex = 0 }
        .onChange(of: activeList.count) { _, newCount in
            if ticketPageIndex >= newCount { ticketPageIndex = max(0, newCount - 1) }
        }
    }

    @ViewBuilder
    private func ticketPager(screenWidth: CGFloat) -> some View {
        let cardW = screenWidth - 62
        VStack(spacing: 0) {
            TabView(selection: $ticketPageIndex) {
                ForEach(Array(activeList.enumerated()), id: \.element.id) { index, reservation in
                    ScrollView(.vertical, showsIndicators: false) {
                        ReservationTicketCard(
                            reservation: reservation,
                            mode: segment == .upcoming ? .upcoming : .history,
                            openURL: openURL
                        )
                        .frame(width: cardW)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(minHeight: 420)

            if activeList.count > 1 {
                Group {
                    // Figma 364:8002 — `icons/3dot` (Group 98): 15pt circles, 10pt gap, #213C2E / #D9D9D9; only under Upcoming with multiple tickets.
                    if segment == .upcoming {
                        upcomingPaginationDots
                    } else {
                        pageIndicatorDotRow
                    }
                }
                .padding(.top, 4)
                .padding(.bottom, 16)
            } else {
                Spacer().frame(height: 16)
            }
        }
        .frame(width: screenWidth)
    }

    /// Figma 370:9124 / 370:9041 — capsule pagination under History when multiple bookings.
    private var pageIndicatorDotRow: some View {
        HStack(spacing: 7) {
            ForEach(0..<activeList.count, id: \.self) { i in
                Capsule()
                    .fill(i == ticketPageIndex ? segmentActiveFill : segmentTrack)
                    .frame(width: i == ticketPageIndex ? 14 : 6, height: 6)
            }
        }
        .frame(maxWidth: .infinity)
    }

    /// Figma `icons/3dot` (Group 98): 15×15 circles, 10pt gap; active `#213C2E`, inactive `#D9D9D9`.
    private var upcomingPaginationDots: some View {
        let activeFill = segmentActiveFill
        return HStack(spacing: 10) {
            ForEach(0..<activeList.count, id: \.self) { i in
                Circle()
                    .fill(i == ticketPageIndex ? activeFill : segmentTrack)
                    .frame(width: 15, height: 15)
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(ticketPageIndex + 1) of \(activeList.count)")
    }

    private var headerBar: some View {
        Group {
            if isArabic {
                arabicHeaderBar
            } else {
                englishHeaderBar
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background(brandBrown.ignoresSafeArea(edges: .top))
    }

    /// Figma 370:8995 — title `حجوزاتي` 20pt, white, end-aligned.
    private var arabicHeaderBar: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 8)
            Text("حجوزاتي")
                .font(.custom("ExpoArabic-Medium", size: 20))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 21)
                .padding(.top, 6)
                .padding(.bottom, 18)
        }
    }

    /// Same chrome as `CalendarBookingsView` (brown, logo row, `group2`, title metrics).
    private var englishHeaderBar: some View {
        VStack(spacing: 0) {
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
                    Image("group2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 20)
                }
                .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)

            Text("My Reservations")
                .font(.custom("ExpoArabic-Medium", size: 24))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 21)
                .padding(.top, 14)
                .padding(.bottom, 10)
        }
    }

    /// Arabic: السجل (left) · القادمة (right). Figma: green `#213C2E` active pill for both locales.
    private var segmentControl: some View {
        HStack(spacing: 0) {
            if isArabic {
                segmentHistoryButton
                segmentUpcomingButton
            } else {
                segmentUpcomingButtonEN
                segmentHistoryButtonEN
            }
        }
        .background(segmentTrack)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 31)
        .environment(\.layoutDirection, .leftToRight)
    }

    private var segmentHistoryButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { segment = .history }
        } label: {
            Text("السجل")
                .font(.custom("ExpoArabic-Medium", size: 16))
                .foregroundColor(segment == .history ? .white : segmentInactiveText)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(segment == .history ? segmentActiveFill : Color.clear)
        }
        .buttonStyle(.plain)
    }

    private var segmentUpcomingButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { segment = .upcoming }
        } label: {
            Text("القادمة")
                .font(.custom("ExpoArabic-Medium", size: 16))
                .foregroundColor(segment == .upcoming ? .white : segmentInactiveText)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(segment == .upcoming ? segmentActiveFill : Color.clear)
        }
        .buttonStyle(.plain)
    }

    private var segmentUpcomingButtonEN: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { segment = .upcoming }
        } label: {
            Text("Upcoming")
                .font(.custom("ExpoArabic-Medium", size: 16))
                .foregroundColor(segment == .upcoming ? .white : segmentInactiveText)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(segment == .upcoming ? segmentActiveFill : Color.clear)
        }
        .buttonStyle(.plain)
    }

    private var segmentHistoryButtonEN: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { segment = .history }
        } label: {
            Text("History")
                .font(.custom("ExpoArabic-Medium", size: 16))
                .foregroundColor(segment == .history ? .white : segmentInactiveText)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(segment == .history ? segmentActiveFill : Color.clear)
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        Text(emptyStateMessage)
            .font(.custom("ExpoArabic-Medium", size: 14))
            .foregroundColor(textGreen.opacity(0.55))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    private var emptyStateMessage: String {
        if isArabic {
            return segment == .upcoming ? "لا توجد حجوزات قادمة." : "لا يوجد سجل حجوزات بعد."
        }
        return segment == .upcoming ? "No upcoming reservations." : "No reservation history yet."
    }

    private var reservationsBottomNav: some View {
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
                TicketsNavigationLink(width: 23, height: 18)
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

// MARK: - Ticket card

private struct ReservationTicketCard: View {
    @EnvironmentObject private var languageManager: LanguageManager

    let reservation: StoredReservation
    let mode: ReservationTicketMode
    let openURL: OpenURLAction

    private var isArabic: Bool { languageManager.current == .arabic }

    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)
    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    enum ReservationTicketMode {
        case upcoming
        case history
    }

    /// Prefer stored payload; if missing or CI fails, build a scannable payload (stable digits derived from id).
    private var displayQRPayload: String {
        let stored = reservation.qrPayload.trimmingCharacters(in: .whitespacesAndNewlines)
        if BookingQRImage.canMake(from: stored) { return stored }
        let digits = reservation.id.filter(\.isNumber)
        let code = digits.count >= 8 ? String(digits.prefix(14)) : Self.stableNumericTicketCode(seed: reservation.id)
        return BookingTicketCode.qrPayload(ticketCode: code, place: reservation.placeTitle)
    }

    /// 14-digit code deterministic from `seed` so the QR does not flicker on redraw (unlike `BookingTicketCode.new()` each time).
    private static func stableNumericTicketCode(seed: String) -> String {
        var h = seed.unicodeScalars.reduce(5381) { $0 &* 33 &+ Int($1.value) }
        return (0..<14).map { _ in
            h = h &* 31 &+ 104_729
            return String(abs(h) % 10)
        }.joined()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Figma 1202:10521 — hero 288×168, corner radius 7 (inset 12 from card).
            ZStack(alignment: isArabic ? .topTrailing : .topLeading) {
                Image(reservation.imageName)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 168)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(7)

                if mode == .history {
                    // Figma 370:8905 — `icons/expired tag` (81×16 pill, #D9D9D9 / #878787).
                    Image(isArabic ? "expired-tag-ar" : "expired-tag")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 16)
                        .accessibilityLabel(isArabic ? "منتهية" : "Expired")
                        .padding(10)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)

            // Figma — title 24pt `#213C2E`.
            Text(reservation.placeTitle)
                .font(.custom("ExpoArabic-Medium", size: 24))
                .foregroundColor(textGreen)
                .lineLimit(2)
                .minimumScaleFactor(0.88)
                .multilineTextAlignment(isArabic ? .trailing : .leading)
                .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                .padding(.horizontal, 13)
                .padding(.top, 10)

            if !reservation.subtitle.isEmpty {
                subtitleRow
                    .padding(.horizontal, 13)
                    .padding(.top, 8)
            }

            // Figma — 84×84 QR, modules `#31231b`; LTR so code isn’t mirrored in RTL.
            HStack(alignment: .bottom, spacing: 10) {
                reservationMetaColumn
                Image("ticket-qr")
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 84, height: 84)
                    .environment(\.layoutDirection, .leftToRight)
            }
            .padding(.horizontal, 13)
            .padding(.top, 22)
        }
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .stroke(Color.black.opacity(0.07), lineWidth: 0.5)
        )
    }

    /// Date / time / location stack (Figma 1202:10515–10520 / 370:9117–9122).
    private var reservationMetaColumn: some View {
        let colAlign: Alignment = isArabic ? .trailing : .leading
        let hAlign: HorizontalAlignment = isArabic ? .trailing : .leading
        let labelColor = textGreen
        let valueColor = textGreen

        return VStack(alignment: hAlign, spacing: 0) {
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: hAlign, spacing: 4) {
                    Text(isArabic ? "التاريخ" : "Date")
                        .font(.custom("ExpoArabic-Medium", size: 16))
                        .foregroundColor(labelColor)
                    Text(displayDateString())
                        .font(.custom("ExpoArabic-Medium", size: 13))
                        .foregroundColor(valueColor)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(isArabic ? .trailing : .leading)
                }
                .frame(maxWidth: .infinity, alignment: colAlign)

                VStack(alignment: hAlign, spacing: 4) {
                    Text(isArabic ? "الوقت" : "Time")
                        .font(.custom("ExpoArabic-Medium", size: 16))
                        .foregroundColor(labelColor)
                    Text(displayTimeString())
                        .font(.custom("ExpoArabic-Medium", size: 13))
                        .foregroundColor(valueColor)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(isArabic ? .trailing : .leading)
                }
                .frame(maxWidth: .infinity, alignment: colAlign)
            }
            .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)

            Text(isArabic ? "الموقع" : "Location")
                .font(.custom("ExpoArabic-Medium", size: 16))
                .foregroundColor(labelColor)
                .padding(.top, 18)
                .frame(maxWidth: .infinity, alignment: colAlign)

            Button {
                let q = reservation.branch.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                if let url = URL(string: "http://maps.apple.com/?q=\(q)") {
                    openURL(url)
                }
            } label: {
                Text(reservation.branch)
                    .font(.custom("ExpoArabic-Medium", size: 13))
                    .foregroundColor(textGreen)
                    .underline()
                    .multilineTextAlignment(isArabic ? .trailing : .leading)
                    .frame(maxWidth: .infinity, alignment: colAlign)
            }
            .buttonStyle(.plain)
            .padding(.top, 6)
        }
        .frame(maxWidth: .infinity, alignment: colAlign)
    }

    @ViewBuilder
    private var subtitleRow: some View {
        if isArabic {
            HStack {
                Spacer(minLength: 0)
                HStack(alignment: .top, spacing: 6) {
                    Text(reservation.subtitle)
                        .font(.custom("ExpoArabic-Medium", size: 12))
                        .foregroundColor(textGreen.opacity(0.7))
                        .multilineTextAlignment(.trailing)
                        .fixedSize(horizontal: false, vertical: true)
                    Image(reservation.usesForkSubtitleIcon ? "fork-knife-icon" : "location-icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14, height: 14)
                        .padding(.top, 2)
                }
            }
            .environment(\.layoutDirection, .leftToRight)
        } else {
            HStack(alignment: .top, spacing: 6) {
                Image(reservation.usesForkSubtitleIcon ? "fork-knife-icon" : "location-icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14, height: 14)
                    .padding(.top, 2)
                Text(reservation.subtitle)
                    .font(.custom("ExpoArabic-Medium", size: 12))
                    .foregroundColor(textGreen.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func displayDateString() -> String {
        if !isArabic { return reservation.dateDisplay }
        let f = DateFormatter()
        f.locale = Locale(identifier: "ar_SA")
        f.calendar = Calendar(identifier: .gregorian)
        f.setLocalizedDateFormatFromTemplate("dMMMM")
        return f.string(from: reservation.eventDate)
    }

    private func displayTimeString() -> String {
        if !isArabic { return reservation.timeDisplay }
        let cal = Calendar.current
        let h = cal.component(.hour, from: reservation.eventDate)
        let m = cal.component(.minute, from: reservation.eventDate)
        if h == 0 && m == 0 { return reservation.timeDisplay }
        let f = DateFormatter()
        f.locale = Locale(identifier: "ar_SA")
        f.dateFormat = "h:mm a"
        return f.string(from: reservation.eventDate)
    }
}

// MARK: - Tickets tab (4th icon)

struct TicketsNavigationLink: View {
    var width: CGFloat = 23
    var height: CGFloat = 18
    /// Calendar tab: present as its own stack so there is no `<` back to Calendar.
    var opensAsStandaloneRoot: Bool = false

    var body: some View {
        Group {
            if opensAsStandaloneRoot {
                NavigationLink {
                    NavigationStack {
                        MyReservationsView()
                    }
                    .navigationBarBackButtonHidden(true)
                    .toolbar(.hidden, for: .navigationBar)
                } label: {
                    label
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                NavigationLink(destination: MyReservationsView()) {
                    label
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private var label: some View {
        Image("nav-icon-ticket")
            .resizable()
            .renderingMode(.original)
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: height)
    }
}

#Preview("My Reservations") {
    let past = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
    let future = Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()
    let store = ReservationStore(previewReservations: [
        StoredReservation(
            id: "11111111111111",
            placeTitle: "Myazu Restaurant",
            subtitle: "Japanese, Sushi",
            imageName: "restaurant-myazu",
            dateDisplay: "Jan 3",
            timeDisplay: "8:00PM",
            branch: "Albasateen Mall, Alrawdha",
            qrPayload: "MRASEM|11111111111111|Myazu Restaurant",
            eventDate: future,
            usesForkSubtitleIcon: true
        ),
        StoredReservation(
            id: "22222222222222",
            placeTitle: "Myazu Restaurant",
            subtitle: "Japanese, Sushi",
            imageName: "restaurant-myazu",
            dateDisplay: "Jan 3",
            timeDisplay: "8:00PM",
            branch: "Albasateen Mall, Alrawdha",
            qrPayload: "MRASEM|22222222222222|Myazu Restaurant",
            eventDate: past,
            usesForkSubtitleIcon: true
        ),
    ])
    NavigationStack {
        MyReservationsView()
            .environmentObject(store)
            .environmentObject(InvitationStore())
            .environmentObject(LanguageManager())
    }
}
