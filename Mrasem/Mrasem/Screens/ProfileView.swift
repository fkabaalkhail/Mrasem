import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageManager: LanguageManager

    private var isArabic: Bool { languageManager.current == .arabic }

    private let brandBrown = Color(red: 0x31/255, green: 0x23/255, blue: 0x1B/255)
    private let fieldBorder = Color(red: 0xF1/255, green: 0xEC/255, blue: 0xEC/255)
    private let textDark = Color(red: 0x26/255, green: 0x24/255, blue: 0x22/255)
    private let textGray = Color(red: 0xAB/255, green: 0xAB/255, blue: 0xAB/255)
    private let logoutRed = Color(red: 0xA7/255, green: 0x1E/255, blue: 0x1E/255)

    var body: some View {
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                decorativeStrip
                profileContent
            }
            .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
        }
        .navigationBarHidden(true)
    }

    // MARK: - Header (brown bar with back arrow + logo)

    private var headerBar: some View {
        ZStack {
            brandBrown.ignoresSafeArea(edges: .top)

            HStack {
                Button(action: { dismiss() }) {
                    Image("profile-back-arrow")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }

                Spacer()

                Image("mrasem-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)

                Spacer()

                Color.clear.frame(width: 24, height: 24)
            }
            .padding(.horizontal, 24)
        }
        .frame(height: 126)
    }

    // MARK: - Decorative geometric strip

    private var decorativeStrip: some View {
        HStack(spacing: 8) {
            decoStripImage("sp-deco-0", size: 58)
            decoStripImage("sp-deco-5", size: 58)
            decoStripImage("sp-deco-1", size: 58)
            decoStripImage("sp-deco-6", size: 58)
            decoStripImage("sp-deco-4", w: 20, h: 58)
            decoStripImage("sp-deco-7", size: 58)
        }
        .frame(height: 58)
        .clipped()
        .padding(.top, 0)
    }

    private func decoStripImage(_ name: String, size: CGFloat) -> some View {
        Image(name)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
    }

    private func decoStripImage(_ name: String, w: CGFloat, h: CGFloat) -> some View {
        Image(name)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: w, height: h)
    }

    // MARK: - Profile content

    private var profileContent: some View {
        VStack(spacing: 0) {
            avatarSection
                .padding(.top, 20)

            formFields
                .padding(.top, 30)

            Spacer()

            Button(action: {}) {
                Text(isArabic ? "تسجيل الخروج" : "Logout")
                    .font(.custom("ExpoArabic-Medium", size: 16))
                    .foregroundColor(logoutRed)
            }
            .padding(.bottom, 50)
        }
    }

    // MARK: - Avatar + Name (Figma 1043:2479 — AR: edit badge, سعود خالد)

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

            Text(isArabic ? "سعود خالد" : "Saud Khalid")
                .font(.custom("ExpoArabic-Bold", size: 18))
                .foregroundColor(textDark)
                .tracking(0.036)
                .padding(.top, 12)
        }
    }

    // MARK: - Form fields

    private var formFields: some View {
        VStack(alignment: isArabic ? .trailing : .leading, spacing: 16) {
            fieldRow(
                label: isArabic ? "رقم الجوال" : "Phone Number",
                value: "+966 5312313580"
            )
            fieldRow(
                label: isArabic ? "رقم العضوية" : "Membership Number",
                value: "7826550197"
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
                Image("profile-field-edit")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 15, height: 15)

                Spacer()

                Text(value)
                    .font(.custom("ExpoArabic-Medium", size: 14))
                    .foregroundColor(textGray)
                    .tracking(0.028)
                    .multilineTextAlignment(isArabic ? .trailing : .leading)
            }
            .environment(\.layoutDirection, .leftToRight)
            .padding(.horizontal, 15)
            .frame(height: 54)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(fieldBorder, lineWidth: 1)
            )
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(LanguageManager())
}
