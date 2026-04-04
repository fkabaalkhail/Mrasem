import SwiftUI

/// Invitations — Sent / Received (Figma 1202:7592 empty Sent, 1307:51434 pending Sent, 1202:9244 Received, respond flow). Arabic copy 1331:25391; header/nav/FAB/segment (AR) use brown `#31231b`.
struct InvitationsView: View {
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var invitationStore: InvitationStore
    @EnvironmentObject private var languageManager: LanguageManager

    @State private var segment: InvitationSegment = .sent
    @State private var pageSent = 0
    @State private var pageReceived = 0
    @State private var showInvitationComposer = false

    private enum InvitationSegment {
        case sent
        case received
    }

    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)
    private let pageBg = Color(red: 0xF3 / 255.0, green: 0xF3 / 255.0, blue: 0xF3 / 255.0)
    private let segmentTrack = Color(red: 0xD9 / 255.0, green: 0xD9 / 255.0, blue: 0xD9 / 255.0)
    private let segmentInactiveText = Color(red: 0x87 / 255.0, green: 0x87 / 255.0, blue: 0x87 / 255.0)
    private let emptyTitleGray = Color(red: 121 / 255.0, green: 120 / 255.0, blue: 120 / 255.0).opacity(0.5)
    private let emptySubtitleGray = Color(red: 121 / 255.0, green: 120 / 255.0, blue: 120 / 255.0).opacity(0.76)
    private let pendingBadgeBg = Color(red: 255 / 255.0, green: 193 / 255.0, blue: 7 / 255.0)
    private let pendingBadgeText = Color(red: 120 / 255.0, green: 91 / 255.0, blue: 4 / 255.0)
    private let acceptedBadgeBg = Color(red: 0x50 / 255.0, green: 0x8B / 255.0, blue: 0x6C / 255.0)
    private let declinedBadgeBg = Color(red: 0xFF / 255.0, green: 0xEB / 255.0, blue: 0xEE / 255.0)
    private let declinedBadgeText = Color(red: 0xC6 / 255.0, green: 0x28 / 255.0, blue: 0x28 / 255.0)

    private var sentList: [SentInvitation] { invitationStore.sentInvitations }
    private var receivedList: [ReceivedInvitation] { invitationStore.receivedInvitations }

    private var isArabic: Bool { languageManager.current == .arabic }

    private var activePage: Binding<Int> {
        segment == .sent ? $pageSent : $pageReceived
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                pageBg.ignoresSafeArea()

                VStack(spacing: 0) {
                    headerBar

                    segmentControl
                        .padding(.top, 22)
                        .padding(.bottom, 16)

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            if segment == .sent {
                                sentContent
                            } else {
                                receivedContent
                            }
                        }
                        .padding(.bottom, 24)
                    }
                    .background(pageBg)

                    Spacer(minLength: 0)

                    invitationsBottomNav
                }

                if segment == .sent, !sentList.isEmpty {
                    sendInviteFAB
                        .padding(.leading, 31)
                        .padding(.bottom, 58)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
        }
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showInvitationComposer) {
            NavigationStack {
                InvitationChooseContactView()
                    .environmentObject(InvitationDraft())
                    .environmentObject(invitationStore)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .onReceive(NotificationCenter.default.publisher(for: .mrasemCloseInvitationComposer)) { _ in
            showInvitationComposer = false
        }
        .onChange(of: segment) { _, _ in
            pageSent = min(pageSent, max(0, sentList.count - 1))
            pageReceived = min(pageReceived, max(0, receivedList.count - 1))
        }
        .onChange(of: sentList.count) { _, c in
            if pageSent >= c { pageSent = max(0, c - 1) }
        }
        .onChange(of: receivedList.count) { _, c in
            if pageReceived >= c { pageReceived = max(0, c - 1) }
        }
    }

    // MARK: - Sent

    @ViewBuilder
    private var sentContent: some View {
        if sentList.isEmpty {
            sentEmptyState
                .padding(.top, 40)
                .padding(.horizontal, 21)
        } else {
            TabView(selection: $pageSent) {
                    ForEach(Array(sentList.enumerated()), id: \.element.id) { index, inv in
                        SentInvitationCard(invitation: inv, openURL: openURL, colors: sentCardColors(for: inv.outcome), isArabic: isArabic)
                            .padding(.horizontal, 21)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 440)

            if sentList.count > 1 {
                pageDots(count: sentList.count, current: pageSent)
                    .padding(.top, 12)
            }
        }
    }

    private func sentCardColors(for outcome: SentInvitationOutcome) -> SentInvitationCard.BadgeColors {
        switch outcome {
        case .pending:
            return SentInvitationCard.BadgeColors(bg: pendingBadgeBg, fg: pendingBadgeText, label: isArabic ? "قيد الانتظار" : "Pending")
        case .accepted:
            return SentInvitationCard.BadgeColors(bg: acceptedBadgeBg, fg: Color(red: 0x1A / 255.0, green: 0x41 / 255.0, blue: 0x2D / 255.0), label: isArabic ? "مقبولة" : "Accepted")
        case .declined:
            return SentInvitationCard.BadgeColors(bg: declinedBadgeBg, fg: declinedBadgeText, label: isArabic ? "مرفوضة" : "Declined")
        }
    }

    private var sentEmptyState: some View {
        VStack(spacing: 50) {
            Image("icons-circle-cross")
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: 88, height: 88)
                .padding(.top, 24)

            VStack(spacing: 6) {
                Text(isArabic ? "لا توجد دعوات" : "No Invitations")
                    .font(.custom("ExpoArabic-Medium", size: 26))
                    .foregroundColor(emptyTitleGray)
                    .multilineTextAlignment(.center)
                Text(isArabic ? "ابدأ بإرسال الدعوات" : "Start by sending invitations")
                    .font(.custom(isArabic ? "ExpoArabic-Medium" : "ExpoArabic-Light", size: 16))
                    .foregroundColor(emptySubtitleGray)
                    .opacity(isArabic ? 0.6 : 1)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: 300)

            Button {
                showInvitationComposer = true
            } label: {
                Text(isArabic ? "ارسل دعوة" : "Send an invite")
                    .font(.custom("ExpoArabic-Medium", size: 16))
                    .foregroundColor(Color(red: 0xE8 / 255.0, green: 0xE2 / 255.0, blue: 0xF5 / 255.0))
                    .frame(minWidth: 160)
                    .frame(maxWidth: 200)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(brandBrown)
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Received

    @ViewBuilder
    private var receivedContent: some View {
        if receivedList.isEmpty {
            receivedEmptyChrome
                .padding(.top, 48)
        } else {
            TabView(selection: $pageReceived) {
                    ForEach(Array(receivedList.enumerated()), id: \.element.id) { index, inv in
                        Group {
                            if inv.userResponse == .awaiting {
                                NavigationLink {
                                    InvitationRespondView(invitationId: inv.id)
                                } label: {
                                    ReceivedInvitationCard(invitation: inv, openURL: openURL, isArabic: isArabic)
                                }
                                .buttonStyle(.plain)
                            } else {
                                ReceivedInvitationCard(invitation: inv, openURL: openURL, isArabic: isArabic)
                            }
                        }
                        .padding(.horizontal, 21)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 440)

            if receivedList.count > 1 {
                pageDots(count: receivedList.count, current: pageReceived)
                    .padding(.top, 12)
            }
        }
    }

    /// Figma 1202:9244 — Received tab empty: optional caption + pagination dots.
    private var receivedEmptyChrome: some View {
        VStack(spacing: 16) {
            Spacer().frame(minHeight: 100)
            if isArabic {
                Text("لا توجد دعوات مستلمة")
                    .font(.custom("ExpoArabic-Medium", size: 16))
                    .foregroundColor(emptySubtitleGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            pageDots(count: 3, current: 0)
                .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Chrome

    /// Same chrome as `CalendarBookingsView` (brown, logo row, `group2`, title metrics).
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

            Text(isArabic ? "الدعوات" : "Invitations")
                .font(.custom("ExpoArabic-Medium", size: isArabic ? 20 : 24))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                .padding(.horizontal, 21)
                .padding(.top, 14)
                .padding(.bottom, 10)
                .onTapGesture(count: 3) {
                    invitationStore.loadDemoDataset()
                }
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background(brandBrown.ignoresSafeArea(edges: .top))
    }

    private var segmentControl: some View {
        HStack(spacing: 0) {
            if isArabic {
                // Figma: المرسلة إلي (leading) · المرسلة (trailing, default active).
                segmentReceivedButtonAR
                segmentSentButtonAR
            } else {
                segmentSentButtonEN
                segmentReceivedButtonEN
            }
        }
        .background(segmentTrack)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 31)
        .environment(\.layoutDirection, .leftToRight)
    }

    /// English: green active pill; Arabic: brown pill (matches header).
    private var segmentActiveFill: Color { isArabic ? brandBrown : textGreen }

    private var segmentSentButtonEN: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { segment = .sent }
        } label: {
            Text("Sent")
                .font(.custom("ExpoArabic-Medium", size: 16))
                .foregroundColor(segment == .sent ? .white : segmentInactiveText)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(segment == .sent ? segmentActiveFill : Color.clear)
        }
        .buttonStyle(.plain)
    }

    private var segmentReceivedButtonEN: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { segment = .received }
        } label: {
            Text("Received")
                .font(.custom("ExpoArabic-Medium", size: 16))
                .foregroundColor(segment == .received ? .white : segmentInactiveText)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(segment == .received ? segmentActiveFill : Color.clear)
        }
        .buttonStyle(.plain)
    }

    private var segmentSentButtonAR: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { segment = .sent }
        } label: {
            Text("المرسلة")
                .font(.custom("ExpoArabic-Medium", size: 16))
                .foregroundColor(segment == .sent ? .white : segmentInactiveText)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(segment == .sent ? segmentActiveFill : Color.clear)
        }
        .buttonStyle(.plain)
    }

    private var segmentReceivedButtonAR: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { segment = .received }
        } label: {
            Text("المرسلة إلي")
                .font(.custom("ExpoArabic-Medium", size: 16))
                .foregroundColor(segment == .received ? .white : segmentInactiveText)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(segment == .received ? segmentActiveFill : Color.clear)
        }
        .buttonStyle(.plain)
    }

    private func pageDots(count: Int, current: Int) -> some View {
        let activeDot = isArabic ? brandBrown : textGreen
        return HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { i in
                Circle()
                    .fill(i == current ? activeDot : Color.gray.opacity(0.35))
                    .frame(width: 6, height: 6)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var sendInviteFAB: some View {
        Button {
            showInvitationComposer = true
        } label: {
            Circle()
                .fill(brandBrown)
                .frame(width: 46, height: 46)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isArabic ? "ارسل دعوة" : "Send an invite")
    }

    private var invitationsBottomNav: some View {
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
                Image("nav-icon-profile")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                Spacer()
            }
            .padding(.top, 8)
        }
        .frame(height: 50)
        .environment(\.layoutDirection, .leftToRight)
    }
}

// MARK: - Sent card

private struct SentInvitationCard: View {
    struct BadgeColors {
        let bg: Color
        let fg: Color
        let label: String
    }

    let invitation: SentInvitation
    let openURL: OpenURLAction
    let colors: BadgeColors
    let isArabic: Bool

    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)

    private var hAlign: HorizontalAlignment { isArabic ? .trailing : .leading }
    private var frameAlign: Alignment { isArabic ? .trailing : .leading }
    private var textAlign: TextAlignment { isArabic ? .trailing : .leading }

    var body: some View {
        VStack(alignment: hAlign, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Image(invitation.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 168)
                    .clipped()
                    .cornerRadius(7)

                Text(colors.label)
                    .font(.custom("ExpoArabic-Medium", size: 14))
                    .foregroundColor(colors.fg)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .frame(minWidth: 82)
                    .background(colors.bg)
                    .cornerRadius(5)
                    .padding(10)
            }
            .padding(.top, 10)
            .padding(.horizontal, 12)

            Text(invitation.placeTitle)
                .font(.custom("ExpoArabic-Medium", size: 24))
                .foregroundColor(textGreen)
                .multilineTextAlignment(textAlign)
                .frame(maxWidth: .infinity, alignment: frameAlign)
                .padding(.top, 16)

            if !invitation.subtitle.isEmpty {
                HStack(spacing: 6) {
                    if !isArabic {
                        Image("fork-knife-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 14, height: 14)
                    }
                    Text(invitation.subtitle)
                        .font(.custom("ExpoArabic-Medium", size: 12))
                        .foregroundColor(textGreen.opacity(0.7))
                        .multilineTextAlignment(textAlign)
                    if isArabic {
                        Image("fork-knife-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 14, height: 14)
                    }
                }
                .padding(.top, 6)
                .frame(maxWidth: .infinity, alignment: frameAlign)
            }

            Text(isArabic ? "إلى: \(invitation.recipientPhone)" : "To: \(invitation.recipientPhone)")
                .font(.custom("ExpoArabic-Medium", size: 12))
                .foregroundColor(textGreen.opacity(0.7))
                .multilineTextAlignment(textAlign)
                .frame(maxWidth: .infinity, alignment: frameAlign)
                .padding(.top, 8)

            HStack(alignment: .bottom, spacing: 10) {
                VStack(alignment: hAlign, spacing: 0) {
                    HStack(alignment: .top, spacing: 36) {
                        VStack(alignment: hAlign, spacing: 4) {
                            Text(isArabic ? "التاريخ" : "Date")
                                .font(.custom("ExpoArabic-Medium", size: 16))
                                .foregroundColor(textGreen)
                            Text(invitation.dateDisplay)
                                .font(.custom("ExpoArabic-Medium", size: 13))
                                .foregroundColor(textGreen)
                                .multilineTextAlignment(textAlign)
                        }
                        VStack(alignment: hAlign, spacing: 4) {
                            Text(isArabic ? "الوقت" : "Time")
                                .font(.custom("ExpoArabic-Medium", size: 16))
                                .foregroundColor(textGreen)
                            Text(invitation.timeDisplay)
                                .font(.custom("ExpoArabic-Medium", size: 13))
                                .foregroundColor(textGreen)
                                .multilineTextAlignment(textAlign)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: frameAlign)

                    Text(isArabic ? "الموقع" : "Location")
                        .font(.custom("ExpoArabic-Medium", size: 16))
                        .foregroundColor(textGreen)
                        .frame(maxWidth: .infinity, alignment: frameAlign)
                        .padding(.top, 18)

                    Button {
                        let q = invitation.branch.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                        if let url = URL(string: "http://maps.apple.com/?q=\(q)") {
                            openURL(url)
                        }
                    } label: {
                        Text(invitation.branch)
                            .font(.custom("ExpoArabic-Medium", size: 13))
                            .foregroundColor(textGreen)
                            .underline()
                            .multilineTextAlignment(textAlign)
                            .frame(maxWidth: .infinity, alignment: frameAlign)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: frameAlign)

                Spacer(minLength: 0)
            }
            .padding(.top, 18)
        }
        .padding(.horizontal, 13)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: frameAlign)
        .background(Color.white)
        .cornerRadius(9)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Received card

private struct ReceivedInvitationCard: View {
    let invitation: ReceivedInvitation
    let openURL: OpenURLAction
    let isArabic: Bool

    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)
    private let pendingBadgeBg = Color(red: 255 / 255.0, green: 193 / 255.0, blue: 7 / 255.0)
    private let pendingBadgeText = Color(red: 120 / 255.0, green: 91 / 255.0, blue: 4 / 255.0)
    private let acceptedBadgeBg = Color(red: 0x50 / 255.0, green: 0x8B / 255.0, blue: 0x6C / 255.0)
    private let declinedBadgeBg = Color(red: 0xFF / 255.0, green: 0xEB / 255.0, blue: 0xEE / 255.0)
    private let declinedBadgeText = Color(red: 0xC6 / 255.0, green: 0x28 / 255.0, blue: 0x28 / 255.0)

    private var badge: (String, Color, Color) {
        switch invitation.userResponse {
        case .awaiting:
            return (isArabic ? "قيد الانتظار" : "Pending", pendingBadgeBg, pendingBadgeText)
        case .accepted:
            return (isArabic ? "مقبولة" : "Accepted", acceptedBadgeBg, Color(red: 0x1A / 255.0, green: 0x41 / 255.0, blue: 0x2D / 255.0))
        case .declined:
            return (isArabic ? "مرفوضة" : "Declined", declinedBadgeBg, declinedBadgeText)
        }
    }

    private var hAlign: HorizontalAlignment { isArabic ? .trailing : .leading }
    private var frameAlign: Alignment { isArabic ? .trailing : .leading }
    private var textAlign: TextAlignment { isArabic ? .trailing : .leading }

    var body: some View {
        VStack(alignment: hAlign, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Image(invitation.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 168)
                    .clipped()
                    .cornerRadius(7)

                Text(badge.0)
                    .font(.custom("ExpoArabic-Medium", size: 14))
                    .foregroundColor(badge.2)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(badge.1)
                    .cornerRadius(5)
                    .padding(10)
            }
            .padding(.top, 10)
            .padding(.horizontal, 12)

            Text(invitation.placeTitle)
                .font(.custom("ExpoArabic-Medium", size: 24))
                .foregroundColor(textGreen)
                .multilineTextAlignment(textAlign)
                .frame(maxWidth: .infinity, alignment: frameAlign)
                .padding(.top, 16)

            if !invitation.subtitle.isEmpty {
                HStack(spacing: 6) {
                    if !isArabic {
                        Image("fork-knife-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 14, height: 14)
                    }
                    Text(invitation.subtitle)
                        .font(.custom("ExpoArabic-Medium", size: 12))
                        .foregroundColor(textGreen.opacity(0.7))
                        .multilineTextAlignment(textAlign)
                    if isArabic {
                        Image("fork-knife-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 14, height: 14)
                    }
                }
                .padding(.top, 6)
                .frame(maxWidth: .infinity, alignment: frameAlign)
            }

            Text(isArabic ? "من: \(invitation.inviterPhone)" : "From: \(invitation.inviterPhone)")
                .font(.custom("ExpoArabic-Medium", size: 12))
                .foregroundColor(textGreen.opacity(0.7))
                .multilineTextAlignment(textAlign)
                .frame(maxWidth: .infinity, alignment: frameAlign)
                .padding(.top, 8)

            HStack(alignment: .bottom, spacing: 10) {
                VStack(alignment: hAlign, spacing: 0) {
                    HStack(alignment: .top, spacing: 36) {
                        VStack(alignment: hAlign, spacing: 4) {
                            Text(isArabic ? "التاريخ" : "Date")
                                .font(.custom("ExpoArabic-Medium", size: 16))
                                .foregroundColor(textGreen)
                            Text(invitation.dateDisplay)
                                .font(.custom("ExpoArabic-Medium", size: 13))
                                .foregroundColor(textGreen)
                                .multilineTextAlignment(textAlign)
                        }
                        VStack(alignment: hAlign, spacing: 4) {
                            Text(isArabic ? "الوقت" : "Time")
                                .font(.custom("ExpoArabic-Medium", size: 16))
                                .foregroundColor(textGreen)
                            Text(invitation.timeDisplay)
                                .font(.custom("ExpoArabic-Medium", size: 13))
                                .foregroundColor(textGreen)
                                .multilineTextAlignment(textAlign)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: frameAlign)

                    Text(isArabic ? "الموقع" : "Location")
                        .font(.custom("ExpoArabic-Medium", size: 16))
                        .foregroundColor(textGreen)
                        .frame(maxWidth: .infinity, alignment: frameAlign)
                        .padding(.top, 18)

                    Button {
                        let q = invitation.branch.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                        if let url = URL(string: "http://maps.apple.com/?q=\(q)") {
                            openURL(url)
                        }
                    } label: {
                        Text(invitation.branch)
                            .font(.custom("ExpoArabic-Medium", size: 13))
                            .foregroundColor(textGreen)
                            .underline()
                            .multilineTextAlignment(textAlign)
                            .frame(maxWidth: .infinity, alignment: frameAlign)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: frameAlign)

                Spacer(minLength: 0)
            }
            .padding(.top, 18)
        }
        .padding(.horizontal, 13)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: frameAlign)
        .background(Color.white)
        .cornerRadius(9)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Respond

struct InvitationRespondView: View {
    let invitationId: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var invitationStore: InvitationStore
    @EnvironmentObject private var languageManager: LanguageManager

    private var invitation: ReceivedInvitation? {
        invitationStore.receivedInvitations.first { $0.id == invitationId }
    }

    private var isArabic: Bool { languageManager.current == .arabic }

    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)
    private let pageBg = Color(red: 0xF3 / 255.0, green: 0xF3 / 255.0, blue: 0xF3 / 255.0)

    var body: some View {
        Group {
            if let inv = invitation {
                respondContent(inv: inv)
            } else {
                Text(isArabic ? "الدعوة غير متوفرة" : "Invitation unavailable")
                    .font(.custom("ExpoArabic-Medium", size: 16))
                    .foregroundColor(textGreen.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(pageBg.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private func respondContent(inv: ReceivedInvitation) -> some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                brandBrown
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: isArabic ? "chevron.right" : "chevron.left")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(pageBg)
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)

                Text(isArabic ? "دعوة" : "Invitation")
                    .font(.custom("ExpoArabic-Medium", size: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                    .padding(.horizontal, 21)
                    .padding(.bottom, 18)
            }
            .frame(height: 120)

            ScrollView {
                VStack(alignment: isArabic ? .trailing : .leading, spacing: 20) {
                    ReceivedInvitationCard(invitation: inv, openURL: openURL, isArabic: isArabic)
                        .padding(.horizontal, 21)
                        .padding(.top, 20)

                    if inv.userResponse == .awaiting {
                        Text(isArabic ? "هل ترغب في الانضمام إلى هذا الحجز؟" : "Would you like to join this reservation?")
                            .font(.custom("ExpoArabic-Medium", size: 16))
                            .foregroundColor(textGreen)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 24)

                        VStack(spacing: 12) {
                            Button {
                                invitationStore.applyReceivedResponse(invitationId: inv.id, accept: true)
                                dismiss()
                            } label: {
                                Text(isArabic ? "قبول" : "Accept")
                                    .font(.custom("ExpoArabic-Medium", size: 16))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(textGreen)
                                    .cornerRadius(10)
                            }
                            .buttonStyle(.plain)

                            Button {
                                invitationStore.applyReceivedResponse(invitationId: inv.id, accept: false)
                                dismiss()
                            } label: {
                                Text(isArabic ? "رفض" : "Decline")
                                    .font(.custom("ExpoArabic-Medium", size: 16))
                                    .foregroundColor(brandBrown)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(brandBrown, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 21)
                        .padding(.bottom, 32)
                    } else {
                        Text(
                            inv.userResponse == .accepted
                                ? (isArabic ? "لقد قبلت هذه الدعوة." : "You accepted this invitation.")
                                : (isArabic ? "لقد رفضت هذه الدعوة." : "You declined this invitation.")
                        )
                            .font(.custom("ExpoArabic-Medium", size: 14))
                            .foregroundColor(textGreen.opacity(0.65))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 32)
                    }
                }
            }
        }
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
    }
}

// MARK: - Tab bar link

struct InvitationsNavigationLink: View {
    var width: CGFloat = 20
    var height: CGFloat = 20
    /// Calendar tab: present as its own stack so there is no `<` back to Calendar.
    var opensAsStandaloneRoot: Bool = false

    var body: some View {
        Group {
            if opensAsStandaloneRoot {
                NavigationLink {
                    NavigationStack {
                        InvitationsView()
                    }
                    .navigationBarBackButtonHidden(true)
                    .toolbar(.hidden, for: .navigationBar)
                } label: {
                    label
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                NavigationLink(destination: InvitationsView()) {
                    label
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private var label: some View {
        Image("nav-icon-profile")
            .resizable()
            .renderingMode(.original)
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: height)
    }
}

#Preview("Invitations — empty") {
    NavigationStack {
        InvitationsView()
            .environmentObject(InvitationStore())
            .environmentObject(LanguageManager())
    }
}

#Preview("Invitations — Arabic") {
    NavigationStack {
        InvitationsView()
            .environmentObject(InvitationStore())
            .environmentObject({
                let m = LanguageManager()
                m.current = .arabic
                return m
            }())
    }
}

#Preview("Invitations — demo") {
    let sent: [SentInvitation] = [
        SentInvitation(
            id: "1",
            outcome: .pending,
            placeTitle: "Myazu Restaurant",
            subtitle: "Japanese, Sushi",
            imageName: "restaurant-myazu",
            dateDisplay: "Jan 3",
            timeDisplay: "8:00PM",
            branch: "Albasateen Mall, Alrawdha",
            recipientPhone: "+966588762140"
        ),
    ]
    let received: [ReceivedInvitation] = [
        ReceivedInvitation(
            id: "r1",
            userResponse: .awaiting,
            placeTitle: "Khemah The Groves",
            subtitle: "Outdoor dining",
            imageName: "riyadh-khemah-groves",
            dateDisplay: "Feb 12",
            timeDisplay: "7:00PM",
            branch: "Riyadh Park",
            inviterPhone: "+966555010203",
            linkedSentId: nil
        ),
    ]
    return NavigationStack {
        InvitationsView()
            .environmentObject(InvitationStore(previewSent: sent, previewReceived: received))
            .environmentObject(LanguageManager())
    }
}
