import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var showEditName = false

    private var isArabic: Bool { languageManager.current == .arabic }
    private var auth: AuthenticationManager { .shared }
    private var displayName: String {
        let name = auth.userName
        if let name, !name.isEmpty { return name }
        return auth.phoneNumber ?? "—"
    }

    private let brandBrown = Color(red: 0x31/255, green: 0x23/255, blue: 0x1B/255)
    private let fieldBorder = Color(red: 0xF1/255, green: 0xEC/255, blue: 0xEC/255)
    private let textDark = Color(red: 0x26/255, green: 0x24/255, blue: 0x22/255)
    private let textGray = Color(red: 0xAB/255, green: 0xAB/255, blue: 0xAB/255)
    private let logoutRed = Color(red: 0xA7/255, green: 0x1E/255, blue: 0x1E/255)

    var body: some View {
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                // Brown bar only — matches ActivityDetailView / SeasonEventDetailView / RestaurantDetailView (90pt).
                brandBrown
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 90)

                decorativeStrip
                profileContent
            }
            .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)

            // Header chrome — same back + logo + menu as detail screens (Figma 1040:3000).
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
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showEditName) {
            EditNameView()
                .environmentObject(languageManager)
        }
    }

    // MARK: - Decorative strip

    private var decorativeStrip: some View {
        HStack(spacing: 8) {
            decoImg("sp-deco-0", size: 58)
            decoImg("sp-deco-5", size: 58)
            decoImg("sp-deco-1", size: 58)
            decoImg("sp-deco-6", size: 58)
            decoImg("sp-deco-4", w: 20, h: 58)
            decoImg("sp-deco-7", size: 58)
        }
        .frame(height: 58)
        .clipped()
    }

    private func decoImg(_ name: String, size: CGFloat) -> some View {
        Image(name).resizable().aspectRatio(contentMode: .fit).frame(width: size, height: size)
    }
    private func decoImg(_ name: String, w: CGFloat, h: CGFloat) -> some View {
        Image(name).resizable().aspectRatio(contentMode: .fit).frame(width: w, height: h)
    }

    // MARK: - Content

    private var profileContent: some View {
        VStack(spacing: 0) {
            avatarSection.padding(.top, 20)
            formFields.padding(.top, 30)
            Spacer()
            Button(action: { logout() }) {
                Text(isArabic ? "تسجيل الخروج" : "Logout")
                    .font(.custom("ExpoArabic-Medium", size: 16))
                    .foregroundColor(logoutRed)
            }
            .padding(.bottom, 50)
        }
    }

    // MARK: - Avatar + Name + Edit

    private var avatarSection: some View {
        VStack(spacing: 0) {
            ZStack(alignment: isArabic ? .bottomLeading : .bottomTrailing) {
                Image("profile-avatar")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 86, height: 86)
                Image("profile-edit-avatar")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 23, height: 23)
                    .offset(x: isArabic ? -2 : 2, y: 2)
            }

            HStack(spacing: 8) {
                Text(displayName)
                    .font(.custom("ExpoArabic-Bold", size: 18))
                    .foregroundColor(textDark)
                    .tracking(0.036)

                Button(action: { showEditName = true }) {
                    Image("profile-field-edit")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 15)
                }
            }
            .padding(.top, 12)
        }
    }

    // MARK: - Form fields

    private var formFields: some View {
        VStack(alignment: isArabic ? .trailing : .leading, spacing: 16) {
            fieldRow(
                label: isArabic ? "رقم الجوال" : "Phone Number",
                value: auth.phoneNumber ?? "—"
            )
            fieldRow(
                label: isArabic ? "رقم العضوية" : "Membership Number",
                value: auth.membershipNumber ?? "—"
            )
        }
        .padding(.horizontal, 24)
    }

    private func fieldRow(label: String, value: String) -> some View {
        VStack(alignment: isArabic ? .trailing : .leading, spacing: 12) {
            Text(label)
                .font(.custom("ExpoArabic-Medium", size: 14))
                .foregroundColor(textDark)
                .tracking(0.028)
                .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
            HStack {
                Spacer()
                Text(value)
                    .font(.custom("ExpoArabic-Medium", size: 14))
                    .foregroundColor(textGray)
                    .tracking(0.028)
            }
            .environment(\.layoutDirection, .leftToRight)
            .padding(.horizontal, 15)
            .frame(height: 54)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(fieldBorder, lineWidth: 1))
        }
    }

    // MARK: - Logout

    private func logout() {
        AuthenticationManager.shared.logout()
        // Post notification so AppCoordinator can reset to login
        NotificationCenter.default.post(name: Notification.Name("userDidLogout"), object: nil)
        dismiss()
    }
}

#Preview {
    ProfileView()
        .environmentObject(LanguageManager())
}
