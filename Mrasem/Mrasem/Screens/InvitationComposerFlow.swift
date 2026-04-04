import Combine
import Contacts
import PhotosUI
import SwiftUI
import UIKit

extension Notification.Name {
    /// Close the full-screen invitation composer (after send).
    static let mrasemCloseInvitationComposer = Notification.Name("mrasemCloseInvitationComposer")
}

// MARK: - Draft (passed through composer)

final class InvitationDraft: ObservableObject {
    @Published var recipientPhone: String = ""
    @Published var recipientDisplayName: String = ""
    @Published var category: InvitationPlaceCategory = .restaurants
    @Published var placeTitle: String = "Myazu Restaurant"
    @Published var subtitle: String = "Japanese, Sushi"
    @Published var imageName: String = "restaurant-myazu"
    @Published var branch: String = "Albasateen Mall, Alrawdha"
    @Published var note: String = ""
    @Published var eventDate: Date = Calendar.current.startOfDay(for: Date())
    @Published var timeDisplay: String = "7:10PM"
}

enum InvitationPlaceCategory: String, CaseIterable, Identifiable {
    case restaurants = "Restaurants"
    case activities = "Activities"
    case seasonEvents = "Season events"
    case cars = "Car service"
    var id: String { rawValue }
}

private struct InvitationPlaceOption: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let imageName: String
    let branch: String
    let category: InvitationPlaceCategory
}

private let invitationPlaceCatalog: [InvitationPlaceOption] = [
    InvitationPlaceOption(id: "myazu", title: "Myazu Restaurant", subtitle: "Japanese, Sushi", imageName: "restaurant-myazu", branch: "Albasateen Mall, Alrawdha", category: .restaurants),
    InvitationPlaceOption(id: "vesuvio", title: "Le Vesuvio", subtitle: "Italian, Pizza", imageName: "restaurant-le-vesuvio", branch: "Jeddah Yacht Club & Marina", category: .restaurants),
    InvitationPlaceOption(id: "roka", title: "ROKA", subtitle: "Japanese", imageName: "restaurant-roka", branch: "Jeddah Walk", category: .restaurants),
    InvitationPlaceOption(id: "khemah", title: "Khemah The Groves", subtitle: "Outdoor dining", imageName: "riyadh-khemah-groves", branch: "Riyadh Park", category: .restaurants),
    InvitationPlaceOption(id: "scuba", title: "Scuba Diving", subtitle: "Free Diving", imageName: "activity-scuba", branch: "Jeddah, Red Sea", category: .activities),
    InvitationPlaceOption(id: "winter", title: "Winter Wonderland", subtitle: "Seasonal Attraction", imageName: "season-winter-wonderland", branch: "Jeddah", category: .seasonEvents),
    InvitationPlaceOption(id: "tahoe", title: "Chevrolet Tahoe", subtitle: "Standard · 7 passengers", imageName: "car-tahoe", branch: "Airport pickup", category: .cars),
]

// MARK: - Choose contact (Figma 1202:7974)

struct InvitationChooseContactView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var invitationStore: InvitationStore
    @EnvironmentObject private var draft: InvitationDraft

    @State private var authStatus: CNAuthorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
    @State private var contacts: [InviteContactRow] = []
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var shareInviteURL: URL?
    @State private var showShareSheet = false

    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    private let pageBg = Color(red: 0xF3 / 255.0, green: 0xF3 / 255.0, blue: 0xF3 / 255.0)
    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)
    private let inviteGreen = Color(red: 0x3D / 255.0, green: 0x6D / 255.0, blue: 0x54 / 255.0)
    private let secondaryText = Color(red: 0x8A / 255.0, green: 0x8A / 255.0, blue: 0x8D / 255.0)

    private var filtered: [InviteContactRow] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return contacts }
        return contacts.filter {
            $0.displayName.lowercased().contains(q) || $0.phoneFormatted.lowercased().contains(q)
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            pageBg.ignoresSafeArea()
            VStack(spacing: 0) {
                chooseContactHeaderBar
                searchBar
                    .padding(.top, 22)
                    .padding(.horizontal, 21)

                Group {
                    switch authStatus {
                    case .authorized:
                        contactList
                    case .denied, .restricted:
                        contactsDeniedView
                    case .notDetermined:
                        requestAccessView
                    @unknown default:
                        requestAccessView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .navigationBarHidden(true)
        .task {
            await refreshAuthAndLoad()
        }
        .sheet(isPresented: $showShareSheet) {
            Group {
                if let url = shareInviteURL {
                    ActivityShareView(activityItems: [url, "Join me on Mrasem"])
                }
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(red: 0xC4 / 255.0, green: 0xC4 / 255.0, blue: 0xC4 / 255.0))
            TextField("Search", text: $searchText)
                .font(.custom("ExpoArabic-Medium", size: 14))
                .foregroundColor(textGreen)
        }
        .padding(.horizontal, 14)
        .frame(height: 43)
        .background(Color.white)
        .cornerRadius(9)
    }

    private var contactList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                if isLoading {
                    ProgressView().padding(.top, 40)
                } else {
                    ForEach(filtered) { row in
                        contactRow(row)
                    }
                }
            }
            .padding(.horizontal, 21)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
    }

    private func contactRow(_ row: InviteContactRow) -> some View {
        let member = invitationStore.isMrasemMember(phone: row.normalizedE164)
        return ZStack(alignment: .trailing) {
            NavigationLink {
                InvitationChoosePlaceView(selectedContact: row)
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0xE8 / 255.0, green: 0xE8 / 255.0, blue: 0xE8 / 255.0))
                            .frame(width: 40, height: 40)
                        Text(row.initial)
                            .font(.custom("ExpoArabic-Medium", size: 18))
                            .foregroundColor(brandBrown)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(row.displayName)
                            .font(.custom("ExpoArabic-Medium", size: 16))
                            .foregroundColor(textGreen)
                        Text(row.phoneFormatted)
                            .font(.custom("ExpoArabic-Light", size: 14))
                            .foregroundColor(secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer().frame(width: member ? 8 : 76)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(secondaryText)
                }
                .padding(.horizontal, 15)
                .frame(height: 60)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
            }
            .buttonStyle(.plain)

            if !member {
                Button("Invite") {
                    shareInviteURL = InvitationStore.appInviteURL(forPhone: row.normalizedE164)
                    showShareSheet = true
                }
                .font(.custom("ExpoArabic-Light", size: 14))
                .foregroundColor(inviteGreen)
                .padding(.trailing, 36)
                .buttonStyle(.plain)
                .zIndex(1)
            }
        }
    }

    private var requestAccessView: some View {
        VStack(spacing: 16) {
            Text("Allow access to Contacts to pick someone to invite.")
                .font(.custom("ExpoArabic-Medium", size: 15))
                .foregroundColor(textGreen.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 40)
            Button("Continue") {
                Task { await requestAccess() }
            }
            .font(.custom("ExpoArabic-Medium", size: 16))
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
            .background(brandBrown)
            .cornerRadius(10)
        }
    }

    private var contactsDeniedView: some View {
        VStack(spacing: 16) {
            Text("Contacts access is off. Enable it in Settings to choose from your address book, or enter a number manually.")
                .font(.custom("ExpoArabic-Medium", size: 15))
                .foregroundColor(textGreen.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
                .padding(.top, 32)
            if let url = URL(string: UIApplication.openSettingsURLString) {
                Link("Open Settings", destination: url)
                    .font(.custom("ExpoArabic-Medium", size: 16))
                    .foregroundColor(inviteGreen)
            }
            NavigationLink("Enter phone manually") {
                InvitationManualPhoneView()
            }
            .font(.custom("ExpoArabic-Medium", size: 16))
            .foregroundColor(brandBrown)
            .padding(.top, 8)
        }
    }

    private func refreshAuthAndLoad() async {
        authStatus = CNContactStore.authorizationStatus(for: .contacts)
        if authStatus == .authorized {
            await loadContacts()
        }
    }

    private func requestAccess() async {
        let store = CNContactStore()
        do {
            let granted = try await store.requestAccess(for: .contacts)
            await MainActor.run {
                authStatus = granted ? .authorized : CNContactStore.authorizationStatus(for: .contacts)
            }
            if granted {
                await loadContacts()
            }
        } catch {
            await MainActor.run {
                authStatus = CNContactStore.authorizationStatus(for: .contacts)
            }
        }
    }

    private func loadContacts() async {
        await MainActor.run { isLoading = true }
        let rows = await Task.detached(priority: .userInitiated) {
            InviteContactLoader.fetch()
        }.value
        await MainActor.run {
            contacts = rows
            isLoading = false
        }
    }

    /// Same chrome as `CalendarBookingsView` (brown, logo, `group2`, title 24pt); leading control is back to dismiss composer.
    private var chooseContactHeaderBar: some View {
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
                    Image("group2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 20)
                }
                .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)

            Text("Choose Contact")
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
}

// MARK: - Manual phone fallback

private struct InvitationManualPhoneView: View {
    @EnvironmentObject private var draft: InvitationDraft
    @State private var phone = ""

    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    private let pageBg = Color(red: 0xF3 / 255.0, green: 0xF3 / 255.0, blue: 0xF3 / 255.0)
    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Phone number")
                .font(.custom("ExpoArabic-Medium", size: 14))
                .foregroundColor(textGreen)
            TextField("+9665xxxxxxxx", text: $phone)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .padding(12)
                .background(Color.white)
                .cornerRadius(8)

            NavigationLink {
                InvitationChoosePlaceView(selectedContact: InviteContactRow(
                    id: "manual",
                    givenName: "",
                    familyName: "",
                    phoneFormatted: phone,
                    normalizedE164: InvitationStore.normalizePhone(phone)
                ))
            } label: {
                Text("Next")
                    .font(.custom("ExpoArabic-Medium", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(brandBrown)
                    .cornerRadius(10)
            }
            .disabled(phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            Spacer()
        }
        .padding(24)
        .background(pageBg.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Choose place (Figma 1202:8547, 1202:8664)

struct InvitationChoosePlaceView: View {
    @Environment(\.dismiss) private var dismiss
    let selectedContact: InviteContactRow
    @EnvironmentObject private var draft: InvitationDraft

    @State private var showCategoryMenu = false
    @State private var showPlacePicker = false
    @State private var photoItem: PhotosPickerItem? // Reserved for future attachment upload

    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)
    private let labelColor = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0).opacity(0.84)

    private var placesForCategory: [InvitationPlaceOption] {
        invitationPlaceCatalog.filter { $0.category == draft.category }
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 0) {
                placeHeader(title: "Choose Place")
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Choose category")
                            .font(.custom("ExpoArabic-Medium", size: 16))
                            .foregroundColor(labelColor)
                            .padding(.top, 24)
                            .padding(.leading, 21)

                        Button {
                            showCategoryMenu = true
                        } label: {
                            HStack {
                                Image(systemName: "square.stack.3d.up")
                                    .foregroundColor(textGreen)
                                Text(draft.category.rawValue)
                                    .font(.custom("ExpoArabic-Light", size: 14))
                                    .foregroundColor(textGreen)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(textGreen)
                            }
                            .padding(12)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(brandBrown, lineWidth: 1.5))
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 12)

                        Text("Pick place")
                            .font(.custom("ExpoArabic-Medium", size: 16))
                            .foregroundColor(labelColor)
                            .padding(.top, 24)
                            .padding(.leading, 21)

                        Button {
                            showPlacePicker = true
                        } label: {
                            HStack {
                                Text(draft.placeTitle)
                                    .font(.custom("ExpoArabic-Light", size: 14))
                                    .foregroundColor(textGreen)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(textGreen)
                            }
                            .padding(12)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(brandBrown, lineWidth: 1.5))
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 12)

                        Text("Add Note (Optional)")
                            .font(.custom("ExpoArabic-Medium", size: 16))
                            .foregroundColor(labelColor)
                            .padding(.top, 24)
                            .padding(.leading, 21)

                        TextField("Add Note", text: $draft.note, axis: .vertical)
                            .lineLimit(3...6)
                            .font(.custom("ExpoArabic-Light", size: 14))
                            .foregroundColor(textGreen)
                            .padding(12)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(brandBrown, lineWidth: 1.5))
                            .padding(.horizontal, 17)
                            .padding(.top, 8)

                        Text("Insert photo")
                            .font(.custom("ExpoArabic-Medium", size: 16))
                            .foregroundColor(labelColor)
                            .padding(.top, 20)
                            .padding(.leading, 21)

                        PhotosPicker(selection: $photoItem, matching: .images) {
                            HStack {
                                Image(systemName: "camera")
                                    .foregroundColor(textGreen.opacity(0.4))
                                Text("Insert photo")
                                    .font(.custom("ExpoArabic-Light", size: 14))
                                    .foregroundColor(textGreen.opacity(0.27))
                                Spacer()
                            }
                            .padding(12)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(brandBrown, lineWidth: 1.5))
                        }
                        .padding(.horizontal, 17)
                        .padding(.top, 8)

                        NavigationLink {
                            InvitationChooseDateView()
                        } label: {
                            Text("Next")
                                .font(.custom("ExpoArabic-Medium", size: 22))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(brandBrown)
                                .cornerRadius(13)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 28)
                        .padding(.top, 36)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            draft.recipientPhone = selectedContact.normalizedE164
            draft.recipientDisplayName = selectedContact.displayName
        }
        .confirmationDialog("Category", isPresented: $showCategoryMenu) {
            ForEach(InvitationPlaceCategory.allCases) { cat in
                Button(cat.rawValue) { draft.category = cat; pickFirstPlaceInCategory() }
            }
        }
        .sheet(isPresented: $showPlacePicker) {
            NavigationStack {
                List(placesForCategory) { opt in
                    Button {
                        applyPlace(opt)
                        showPlacePicker = false
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(opt.title).font(.custom("ExpoArabic-Medium", size: 16))
                            Text(opt.subtitle).font(.custom("ExpoArabic-Light", size: 12)).foregroundColor(.secondary)
                        }
                    }
                }
                .navigationTitle("Pick place")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { showPlacePicker = false }
                    }
                }
            }
        }
    }

    private func pickFirstPlaceInCategory() {
        if let first = invitationPlaceCatalog.first(where: { $0.category == draft.category }) {
            applyPlace(first)
        }
    }

    private func applyPlace(_ opt: InvitationPlaceOption) {
        draft.placeTitle = opt.title
        draft.subtitle = opt.subtitle
        draft.imageName = opt.imageName
        draft.branch = opt.branch
    }

    private func placeHeader(title: String) -> some View {
        ZStack(alignment: .bottomLeading) {
            Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
            VStack(alignment: .leading, spacing: 0) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
                .padding(.leading, 4)
                Text(title)
                    .font(.custom("ExpoArabic-Medium", size: 20))
                    .foregroundColor(.white)
                    .padding(.leading, 21)
                    .padding(.bottom, 18)
            }
        }
        .frame(height: 132)
    }
}

// MARK: - Choose date (Figma 1202:8376)

struct InvitationChooseDateView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var draft: InvitationDraft
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date?

    private let calendar = Calendar.current
    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)
    private let dayHeaderColor = Color(red: 0x3D / 255.0, green: 0x2F / 255.0, blue: 0x4B / 255.0)

    private let timeSlots = ["1:00PM", "3:00PM", "5:30PM", "7:10PM", "8:00PM"]

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 0) {
                dateHeader(title: "Choose a Date")
                ScrollView {
                    VStack(spacing: 0) {
                        monthHeader
                        weekdayRow
                        calendarGrid
                        Text("Select Time")
                            .font(.custom("ExpoArabic-Medium", size: 16))
                            .foregroundColor(textGreen.opacity(0.84))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 21)
                            .padding(.top, 20)
                        timeRow
                            .padding(.top, 12)
                        NavigationLink {
                            InvitationDetailsSummaryView()
                        } label: {
                            Text("Next")
                                .font(.custom("ExpoArabic-Medium", size: 22))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(brandBrown)
                                .cornerRadius(13)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 28)
                        .padding(.top, 28)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if selectedDate == nil {
                selectedDate = calendar.startOfDay(for: Date())
            }
            draft.eventDate = selectedDate ?? Date()
        }
        .onChange(of: selectedDate) { _, d in
            if let d { draft.eventDate = calendar.startOfDay(for: d) }
        }
    }

    private var monthHeader: some View {
        HStack {
            Button {
                currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(textGreen)
            }
            Spacer()
            Text(monthYearString)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(dayHeaderColor)
                .textCase(.uppercase)
            Spacer()
            Button {
                currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundColor(textGreen)
            }
        }
        .padding(.horizontal, 31)
        .padding(.top, 14)
    }

    private var weekdayRow: some View {
        HStack(spacing: 4) {
            ForEach(["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"], id: \.self) { day in
                Text(day)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(dayHeaderColor)
                    .frame(width: 48, height: 27)
            }
        }
        .frame(width: 360)
        .padding(.top, 8)
    }

    private var calendarGrid: some View {
        let startOfToday = calendar.startOfDay(for: Date())
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
            ForEach(Array(calendarDays.enumerated()), id: \.offset) { _, date in
                if let date = date {
                    let disabled = calendar.startOfDay(for: date) < startOfToday
                    let selected = selectedDate != nil && calendar.isDate(date, inSameDayAs: selectedDate!)
                    InvitationDateCell(day: calendar.component(.day, from: date), isSelected: selected, isDisabled: disabled) {
                        if !disabled {
                            selectedDate = calendar.startOfDay(for: date)
                        }
                    }
                } else {
                    Color.clear.frame(width: 48, height: 56)
                }
            }
        }
        .frame(width: 360)
        .padding(.top, 8)
    }

    private var timeRow: some View {
        HStack(spacing: 8) {
            ForEach(timeSlots, id: \.self) { t in
                Button {
                    draft.timeDisplay = t
                } label: {
                    Text(t)
                        .font(.custom("ExpoArabic-Medium", size: 12))
                        .foregroundColor(draft.timeDisplay == t ? .white : textGreen)
                        .frame(width: 76, height: 26)
                        .background(draft.timeDisplay == t ? textGreen : Color.clear)
                        .cornerRadius(5)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(textGreen, lineWidth: 1))
                }
            }
            Spacer()
        }
        .padding(.leading, 21)
    }

    private var monthYearString: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: currentMonth)
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

    private func dateHeader(title: String) -> some View {
        ZStack(alignment: .bottomLeading) {
            brandBrown
            VStack(alignment: .leading, spacing: 0) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
                .padding(.leading, 4)
                Text(title)
                    .font(.custom("ExpoArabic-Medium", size: 20))
                    .foregroundColor(.white)
                    .padding(.leading, 21)
                    .padding(.bottom, 18)
            }
        }
        .frame(height: 132)
    }
}

private struct InvitationDateCell: View {
    let day: Int
    let isSelected: Bool
    let isDisabled: Bool
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
    }

    private var textColor: Color {
        if isDisabled { return Color(red: 0.65, green: 0.65, blue: 0.67) }
        if isSelected { return textGreen }
        return defaultText
    }

    private var backgroundFill: Color {
        if isDisabled { return Color.gray.opacity(0.14) }
        if isSelected { return textGreen.opacity(0.48) }
        return Color.clear
    }
}

// MARK: - Details summary (Figma 1202:12165)

struct InvitationDetailsSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var invitationStore: InvitationStore
    @EnvironmentObject private var draft: InvitationDraft
    @Environment(\.openURL) private var openURL

    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    private let pageBg = Color(red: 0xF3 / 255.0, green: 0xF3 / 255.0, blue: 0xF3 / 255.0)
    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)

    var body: some View {
        ZStack {
            pageBg.ignoresSafeArea()
            VStack(spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    brandBrown
                    VStack(alignment: .leading, spacing: 0) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(pageBg)
                                .frame(width: 44, height: 44)
                        }
                        .padding(.leading, 4)
                        Text("Invitation Details")
                            .font(.custom("ExpoArabic-Medium", size: 20))
                            .foregroundColor(pageBg)
                            .padding(.leading, 21)
                            .padding(.bottom, 18)
                    }
                }
                .frame(height: 132)

                ScrollView {
                    VStack(spacing: 20) {
                        summaryCard
                        if !draft.note.isEmpty {
                            Text(draft.note)
                                .font(.custom("ExpoArabic-Light", size: 14))
                                .foregroundColor(textGreen.opacity(0.75))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 21)
                        }
                        Button {
                            invitationStore.sendInvite(
                                recipientPhone: draft.recipientPhone,
                                placeTitle: draft.placeTitle,
                                subtitle: draft.subtitle,
                                imageName: draft.imageName,
                                branch: draft.branch,
                                eventDate: draft.eventDate,
                                timeDisplay: draft.timeDisplay
                            )
                            NotificationCenter.default.post(name: .mrasemCloseInvitationComposer, object: nil)
                        } label: {
                            Text("Send invitation")
                                .font(.custom("ExpoArabic-Medium", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(brandBrown)
                                .cornerRadius(13)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 28)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(draft.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 168)
                .clipped()
                .cornerRadius(7)
                .padding(.top, 10)
                .padding(.horizontal, 12)

            Text(draft.placeTitle)
                .font(.custom("ExpoArabic-Medium", size: 24))
                .foregroundColor(textGreen)
                .padding(.top, 16)

            Text("To: \(draft.recipientDisplayName.isEmpty ? draft.recipientPhone : draft.recipientDisplayName)")
                .font(.custom("ExpoArabic-Medium", size: 12))
                .foregroundColor(textGreen.opacity(0.7))
                .padding(.top, 8)

            HStack(alignment: .bottom, spacing: 10) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 36) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Date").font(.custom("ExpoArabic-Medium", size: 16)).foregroundColor(textGreen)
                            Text(dateDisplay).font(.custom("ExpoArabic-Medium", size: 13)).foregroundColor(textGreen)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Time").font(.custom("ExpoArabic-Medium", size: 16)).foregroundColor(textGreen)
                            Text(draft.timeDisplay).font(.custom("ExpoArabic-Medium", size: 13)).foregroundColor(textGreen)
                        }
                    }
                    Text("Location")
                        .font(.custom("ExpoArabic-Medium", size: 16))
                        .foregroundColor(textGreen)
                        .padding(.top, 18)
                    Button {
                        let q = draft.branch.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                        if let url = URL(string: "http://maps.apple.com/?q=\(q)") { openURL(url) }
                    } label: {
                        Text(draft.branch)
                            .font(.custom("ExpoArabic-Medium", size: 13))
                            .foregroundColor(brandBrown)
                            .underline()
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
                Spacer(minLength: 0)
            }
            .padding(.top, 18)
        }
        .padding(.horizontal, 13)
        .padding(.bottom, 20)
        .background(Color.white)
        .cornerRadius(9)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 21)
    }

    private var dateDisplay: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: draft.eventDate)
    }

}

// MARK: - Contact models & loader

struct InviteContactRow: Identifiable, Hashable {
    let id: String
    let givenName: String
    let familyName: String
    let phoneFormatted: String
    let normalizedE164: String

    var displayName: String {
        let t = "\(givenName) \(familyName)".trimmingCharacters(in: .whitespaces)
        return t.isEmpty ? phoneFormatted : t
    }

    var initial: String {
        guard let ch = givenName.first ?? familyName.first ?? phoneFormatted.first else {
            return "?"
        }
        return String(ch).uppercased()
    }
}

enum InviteContactLoader {
    static func fetch() -> [InviteContactRow] {
        let store = CNContactStore()
        let keys: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactIdentifierKey as CNKeyDescriptor,
        ]
        let request = CNContactFetchRequest(keysToFetch: keys)
        var rows: [InviteContactRow] = []
        do {
            try store.enumerateContacts(with: request) { contact, _ in
                for labeled in contact.phoneNumbers {
                    let raw = labeled.value.stringValue
                    let norm = InvitationStore.normalizePhone(raw)
                    guard norm.count >= 10 else { continue }
                    let id = "\(contact.identifier)_\(norm)"
                    rows.append(InviteContactRow(
                        id: id,
                        givenName: contact.givenName,
                        familyName: contact.familyName,
                        phoneFormatted: formatDisplayPhone(norm),
                        normalizedE164: norm
                    ))
                }
            }
        } catch {
            return []
        }
        rows.sort { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
        return rows
    }

    private static func formatDisplayPhone(_ e164: String) -> String {
        var s = e164
        if s.hasPrefix("+966") && s.count > 4 {
            let idx = s.index(s.startIndex, offsetBy: 4)
            return "+966 \(s[idx...])"
        }
        return s
    }
}

// MARK: - Share sheet

struct ActivityShareView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
