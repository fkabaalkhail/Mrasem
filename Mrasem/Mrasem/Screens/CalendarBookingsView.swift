import SwiftUI

/// Calendar + upcoming bookings. Data from `ReservationStore.upcoming`.
struct CalendarBookingsView: View {
    @EnvironmentObject private var reservationStore: ReservationStore

    @State private var currentMonth: Date = Date()
    @State private var selectedDay: Date?

    private let calendar = Calendar.current
    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    private let textGreen = Color(red: 0x21 / 255, green: 0x3C / 255, blue: 0x2E / 255)
    private let darkBase = Color(red: 0x3D / 255, green: 0x2F / 255, blue: 0x4B / 255)
    private let dayHighlight = Color(red: 33 / 255, green: 60 / 255, blue: 46 / 255).opacity(0.48)
    private let upcomingBand = Color(red: 33 / 255, green: 60 / 255, blue: 46 / 255).opacity(0.09)

    private var monthYearUppercased: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: currentMonth).uppercased()
    }

    private var daysWithBookings: Set<DateComponents> {
        var set = Set<DateComponents>()
        for r in reservationStore.upcoming {
            let c = calendar.dateComponents([.year, .month, .day], from: calendar.startOfDay(for: r.eventDate))
            set.insert(c)
        }
        return set
    }

    private func hasBooking(on date: Date) -> Bool {
        let c = calendar.dateComponents([.year, .month, .day], from: calendar.startOfDay(for: date))
        return daysWithBookings.contains(c)
    }

    private var upcomingRows: [StoredReservation] {
        let inMonth = reservationStore.upcoming.filter {
            calendar.isDate($0.eventDate, equalTo: currentMonth, toGranularity: .month)
        }
        if let day = selectedDay {
            let start = calendar.startOfDay(for: day)
            return inMonth.filter { calendar.isDate($0.eventDate, inSameDayAs: start) }
                .sorted { $0.eventDate < $1.eventDate }
        }
        return inMonth.sorted { $0.eventDate < $1.eventDate }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        monthNavigation
                            .padding(.top, 22)

                        weekdayHeader
                            .padding(.top, 8)

                        calendarGrid
                            .padding(.top, 8)
                            .padding(.bottom, 20)
                    }
                    .frame(maxWidth: .infinity)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Upcoming")
                        .font(.custom("ExpoArabic-Medium", size: 15))
                        .foregroundColor(brandBrown)
                        .padding(.horizontal, 21)

                    if upcomingRows.isEmpty {
                        Text(selectedDay == nil ? "No upcoming bookings this month." : "No bookings on this day.")
                            .font(.custom("ExpoArabic-Medium", size: 13))
                            .foregroundColor(textGreen.opacity(0.55))
                            .padding(.horizontal, 21)
                            .padding(.bottom, 8)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(upcomingRows) { reservation in
                                upcomingEventRow(reservation)
                            }
                        }
                        .padding(.horizontal, 21)
                        .padding(.bottom, 16)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(upcomingBand)

                Spacer(minLength: 0)

                bottomTabBar
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Header (logo row unchanged; title sits lower; brown fills behind both)

    private var headerBar: some View {
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

            Text("Calendar")
                .font(.custom("ExpoArabic-Medium", size: 24))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 21)
                .padding(.top, 14)
                .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background(brandBrown.ignoresSafeArea(edges: .top))
    }

    // MARK: - Month + grid

    private var monthNavigation: some View {
        HStack {
            Button {
                currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                selectedDay = nil
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(textGreen)
            }

            Spacer()

            Text(monthYearUppercased)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(darkBase)

            Spacer()

            Button {
                currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                selectedDay = nil
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(textGreen)
            }
        }
        .padding(.horizontal, 31)
        .frame(maxWidth: 360)
        .frame(maxWidth: .infinity)
    }

    private var weekdayHeader: some View {
        let labels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return HStack(spacing: 4) {
            ForEach(labels, id: \.self) { day in
                Text(day)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(darkBase)
                    .frame(width: 48, height: 27)
            }
        }
        .frame(maxWidth: 360)
        .frame(maxWidth: .infinity)
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(48), spacing: 4), count: 7), spacing: 4) {
            ForEach(Array(calendarDays.enumerated()), id: \.offset) { _, day in
                if let day {
                    let booked = hasBooking(on: day)
                    let picked = selectedDay.map { calendar.isDate(day, inSameDayAs: $0) } ?? false
                    CalendarBookingsDayCell(
                        day: calendar.component(.day, from: day),
                        booked: booked,
                        selected: picked,
                        darkBase: darkBase,
                        textGreen: textGreen,
                        dayHighlight: dayHighlight
                    ) {
                        if booked {
                            selectedDay = calendar.startOfDay(for: day)
                        } else {
                            selectedDay = nil
                        }
                    }
                } else {
                    Color.clear
                        .frame(width: 48, height: 56)
                }
            }
        }
        .frame(maxWidth: 360)
        .frame(maxWidth: .infinity)
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

    // MARK: - Upcoming row (Figma card ~310×43)

    private func upcomingEventRow(_ r: StoredReservation) -> some View {
        HStack(alignment: .center, spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(red: 33 / 255, green: 60 / 255, blue: 46 / 255).opacity(0.28))
                .frame(width: 4, height: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(displayTitle(r.placeTitle))
                    .font(.custom("ExpoArabic-Medium", size: 12))
                    .foregroundColor(textGreen)
                    .lineLimit(1)

                Text(longDateString(r.eventDate))
                    .font(.custom("ExpoArabic-Medium", size: 8))
                    .foregroundColor(textGreen)
            }

            Spacer(minLength: 0)

            Text(r.timeDisplay)
                .font(.custom("ExpoArabic-Medium", size: 8))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(brandBrown)
                .cornerRadius(2)
        }
        .padding(.leading, 10)
        .padding(.trailing, 12)
        .frame(height: 43)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private func displayTitle(_ placeTitle: String) -> String {
        placeTitle.replacingOccurrences(of: " Restaurant", with: "")
    }

    private func longDateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM d - yyyy"
        return f.string(from: date)
    }

    // MARK: - Bottom tab

    private var bottomTabBar: some View {
        ZStack {
            brandBrown.ignoresSafeArea(edges: .bottom)
            HStack(spacing: 0) {
                Spacer()
                NavigationLink(destination: CategorySelectionView()) {
                    Image("nav-icon-home")
                        .resizable()
                        .renderingMode(.original)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 22)
                }
                .buttonStyle(.plain)
                Spacer()
                Button(action: {}) {
                    Image("nav-icon-calendar")
                        .resizable()
                        .renderingMode(.original)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 21, height: 21)
                }
                Spacer()
                NavigationLink(destination: CategorySelectionView()) {
                    Image("nav-icon-grid")
                        .resizable()
                        .renderingMode(.original)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
                Spacer()
                TicketsNavigationLink(width: 23, height: 18, opensAsStandaloneRoot: true)
                Spacer()
                InvitationsNavigationLink(width: 20, height: 20, opensAsStandaloneRoot: true)
                Spacer()
            }
            .padding(.top, 8)
        }
        .frame(height: 50)
        .environment(\.layoutDirection, .leftToRight)
    }
}

// MARK: - Day cell

private struct CalendarBookingsDayCell: View {
    let day: Int
    let booked: Bool
    let selected: Bool
    let darkBase: Color
    let textGreen: Color
    let dayHighlight: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text("\(day)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(booked ? textGreen : darkBase)
                .frame(width: 48, height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(booked ? dayHighlight : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(selected && booked ? Color(red: 0x21 / 255, green: 0x3C / 255, blue: 0x2E / 255) : Color.clear, lineWidth: selected && booked ? 2 : 0)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tab bar: calendar icon → this screen (Figma 1202:7173). Grid icon stays the original non-link control.

struct BookingsCalendarNavigationLink: View {
    var body: some View {
        NavigationLink(destination: CalendarBookingsView()) {
            Image("nav-icon-calendar")
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
                .frame(width: 21, height: 21)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let june6 = Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 6)) ?? Date()
    let june10 = Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 10)) ?? Date()
    let store = ReservationStore(previewReservations: [
        StoredReservation(
            id: "cal-1",
            placeTitle: "Rasoi by Vineet Restaurant",
            subtitle: "Fine Dining",
            imageName: "mrasem-logo",
            dateDisplay: "Jun 6",
            timeDisplay: "8:00PM",
            branch: "Riyadh",
            qrPayload: "MRASEM|cal-1|Rasoi",
            eventDate: june6,
            usesForkSubtitleIcon: true
        ),
        StoredReservation(
            id: "cal-2",
            placeTitle: "Moon Mountain Hike",
            subtitle: "Car Tour",
            imageName: "rectangle9",
            dateDisplay: "Jun 10",
            timeDisplay: "12:00PM",
            branch: "Jeddah",
            qrPayload: "MRASEM|cal-2|Moon",
            eventDate: june10,
            usesForkSubtitleIcon: false
        ),
    ])
    NavigationStack {
        CalendarBookingsView()
            .environmentObject(store)
            .environmentObject(InvitationStore())
    }
}
