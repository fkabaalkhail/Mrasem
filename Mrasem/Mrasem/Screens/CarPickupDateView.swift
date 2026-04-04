import SwiftUI

/// Car booking — pickup date (Figma **980:1371** Arabic). Continues to `CarPickupLocationView` (**981:1576**).
struct CarPickupDateView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @Binding var pickupDate: Date
    var onCancel: () -> Void
    var onNext: () -> Void

    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date?
    @State private var rentalDays: Int = 1

    private var calendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 1 // Sunday-first grid (Figma Su…Sa)
        c.locale = isArabic ? Locale(identifier: "ar_SA") : Locale(identifier: "en_US")
        return c
    }

    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)
    private let dayHeaderColor = Color(red: 0x3D / 255.0, green: 0x2F / 255.0, blue: 0x4B / 255.0)

    private var isArabic: Bool { languageManager.current == .arabic }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        monthHeader
                        weekdayRow
                        calendarGrid
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 16)
                }

                Spacer(minLength: 0)

                footerControls
                    .padding(.horizontal, 21)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    .background(Color.white)

                bottomTabBar
            }
        }
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
        .navigationBarHidden(true)
        .onAppear {
            if selectedDate == nil {
                let start = calendar.startOfDay(for: pickupDate)
                selectedDate = start >= calendar.startOfDay(for: Date()) ? start : calendar.startOfDay(for: Date())
            }
            if let s = selectedDate {
                pickupDate = s
                currentMonth = s
            }
        }
        .onChange(of: selectedDate) { _, d in
            if let d { pickupDate = calendar.startOfDay(for: d) }
        }
    }

    // MARK: - Header (Figma 980:1375 — 172pt brown, title **اختر التاريخ**)

    private var headerBar: some View {
        ZStack(alignment: .bottom) {
            brandBrown.ignoresSafeArea(edges: .top)

            VStack(alignment: isArabic ? .trailing : .leading, spacing: 0) {
                HStack {
                    Button(action: onCancel) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.top, 4)

                Text(isArabic ? "اختر التاريخ" : "Choose a Date")
                    .font(.custom("ExpoArabic-Medium", size: 20))
                    .foregroundColor(.white)
                    .multilineTextAlignment(isArabic ? .trailing : .leading)
                    .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                    .padding(.bottom, 20)
            }
        }
        .frame(height: 172)
    }

    private var monthHeader: some View {
        HStack {
            Button {
                currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(textGreen)
                    .frame(width: 44, height: 32)
            }
            Spacer()
            Text(monthYearString)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(dayHeaderColor)
            Spacer()
            Button {
                currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(textGreen)
                    .frame(width: 44, height: 32)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 14)
    }

    private var weekdayRow: some View {
        HStack(spacing: 4) {
            ForEach(weekdayLabels, id: \.self) { day in
                Text(day)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(dayHeaderColor)
                    .frame(width: 48, height: 27)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private var weekdayLabels: [String] {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1
        let loc = isArabic ? Locale(identifier: "ar_SA") : Locale(identifier: "en_US")
        let f = DateFormatter()
        f.calendar = cal
        f.locale = loc
        f.dateFormat = "EEE"
        guard let sunday = cal.date(from: DateComponents(year: 2024, month: 6, day: 2)) else {
            return ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
        }
        return (0..<7).compactMap { i in
            guard let d = cal.date(byAdding: .day, value: i, to: sunday) else { return nil }
            return f.string(from: d)
        }
    }

    private var calendarGrid: some View {
        let startOfToday = calendar.startOfDay(for: Date())
        return LazyVGrid(columns: Array(repeating: GridItem(.fixed(48), spacing: 4), count: 7), spacing: 4) {
            ForEach(Array(calendarDays.enumerated()), id: \.offset) { _, date in
                if let date {
                    let dayStart = calendar.startOfDay(for: date)
                    let disabled = dayStart < startOfToday
                    let selected = selectedDate != nil && calendar.isDate(date, inSameDayAs: selectedDate!)
                    let weekend = {
                        let w = calendar.component(.weekday, from: date)
                        return w == 1 || w == 7
                    }()
                    CarDateCell(
                        day: calendar.component(.day, from: date),
                        isSelected: selected,
                        isDisabled: disabled,
                        useWeekendAccent: weekend && !disabled && !selected
                    ) {
                        if !disabled {
                            selectedDate = dayStart
                        }
                    }
                } else {
                    Color.clear.frame(width: 48, height: 56)
                }
            }
        }
        .frame(width: 360)
        .frame(maxWidth: .infinity)
    }

    private var monthYearString: String {
        let f = DateFormatter()
        f.calendar = calendar
        f.locale = isArabic ? Locale(identifier: "ar_SA") : Locale(identifier: "en_US_POSIX")
        f.dateFormat = "MMMM yyyy"
        let s = f.string(from: currentMonth)
        return isArabic ? s : s.uppercased()
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

    // MARK: - Footer (Figma 980:1400 — **التالي** + stepper; then 50pt brown bar)

    private var footerControls: some View {
        VStack(spacing: 14) {
            Button(action: onNext) {
                Text(isArabic ? "التالي" : "Next")
                    .font(.custom("ExpoArabic-Medium", size: 22))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(brandBrown)
                    .cornerRadius(13)
            }
            .buttonStyle(.plain)
            .disabled(selectedDate == nil)

            HStack {
                Spacer(minLength: 0)
                HStack(spacing: 12) {
                    stepperButton(systemName: "plus") {
                        rentalDays = min(30, rentalDays + 1)
                    }
                    Text("\(rentalDays)")
                        .font(.custom("ExpoArabic-Medium", size: 24))
                        .foregroundColor(brandBrown)
                        .frame(minWidth: 28)
                    stepperButton(systemName: "minus") {
                        rentalDays = max(1, rentalDays - 1)
                    }
                }
            }
        }
    }

    private func stepperButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 27, height: 27)
                .background(brandBrown)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

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
                BookingsCalendarNavigationLink()
                Spacer()
                tabIcon("nav-icon-grid", w: 20, h: 20)
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

    private func tabIcon(_ name: String, w: CGFloat, h: CGFloat) -> some View {
        Button(action: {}) {
            Image(name)
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
                .frame(width: w, height: h)
        }
    }
}

// MARK: - Date cell (Figma 980:1431 — sage fill selected; **#213c2e** for weekend accent)

private struct CarDateCell: View {
    let day: Int
    let isSelected: Bool
    let isDisabled: Bool
    var useWeekendAccent: Bool = false
    let action: () -> Void

    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)
    private let defaultText = Color(red: 0x3D / 255.0, green: 0x2F / 255.0, blue: 0x4B / 255.0)

    var body: some View {
        Button(action: action) {
            Text("\(day)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(textColor)
                .frame(width: 48, height: 56)
                .background(backgroundFill)
                .cornerRadius(4)
        }
        .disabled(isDisabled)
        .buttonStyle(.plain)
    }

    private var textColor: Color {
        if isDisabled { return Color(red: 0.65, green: 0.65, blue: 0.67) }
        if isSelected { return textGreen }
        if useWeekendAccent { return textGreen }
        return defaultText
    }

    private var backgroundFill: Color {
        if isDisabled { return Color.gray.opacity(0.14) }
        if isSelected { return textGreen.opacity(0.48) }
        return Color.clear
    }
}

#Preview {
    NavigationStack {
        CarPickupDateView(
            pickupDate: .constant(Date()),
            onCancel: {},
            onNext: {}
        )
        .environmentObject(LanguageManager())
        .environmentObject(InvitationStore())
    }
}
