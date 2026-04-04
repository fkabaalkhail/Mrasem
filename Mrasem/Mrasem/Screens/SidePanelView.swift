import SwiftUI

struct SidePanelView: View {
    @Binding var isOpen: Bool
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageManager: LanguageManager

    private let panelWidth: CGFloat = 237
    /// Figma 1072:6207 — narrow strip for geometric watermark; menu content stays clear.
    private let decorativeStripWidth: CGFloat = 46

    private var isArabic: Bool { languageManager.current == .arabic }

    private var panelEdge: Edge { isArabic ? .trailing : .leading }

    var body: some View {
        ZStack(alignment: isArabic ? .trailing : .leading) {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { withAnimation(.easeInOut(duration: 0.25)) { isOpen = false } }

            panelContent
                .frame(width: panelWidth)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 60, x: isArabic ? -34 : 34, y: 0)
                .transition(.move(edge: panelEdge))
        }
    }

    private var panelContent: some View {
        // LTR HStack so "outer" strip is always physical left (EN) or physical right (AR).
        HStack(spacing: 0) {
            if isArabic {
                mainColumn
                    .frame(maxWidth: .infinity, alignment: .leading)
                decorativeStrip
                    .frame(width: decorativeStripWidth)
            } else {
                decorativeStrip
                    .frame(width: decorativeStripWidth)
                mainColumn
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .environment(\.layoutDirection, .leftToRight)
        .frame(maxHeight: .infinity)
        .clipped()
    }

    /// Profile, divider, menu, logout — inset from the decorative strip.
    private var mainColumn: some View {
        VStack(alignment: .leading, spacing: 0) {
            profileSection
                .padding(.top, 54)
                .padding(.horizontal, 20)

            Rectangle()
                .fill(Color(red: 0xE9 / 255, green: 0xE9 / 255, blue: 0xF2 / 255))
                .frame(width: 170, height: 1)
                .frame(maxWidth: .infinity, alignment: isArabic ? .center : .leading)
                .padding(.horizontal, 20)
                .padding(.top, 14)

            menuSection
                .padding(.top, 28)

            Spacer()

            logoutButton
                .padding(.horizontal, 20)
                .padding(.bottom, 49)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Decorative strip (Figma 1072:6207 — soft / “transparent into white”, doubled pass)

    private var decorativeStrip: some View {
        VStack(spacing: 0) {
            decoPatternBlock(offset: 0)
            Spacer().frame(height: 100)
            decoPatternBlock(offset: 8)
            Spacer(minLength: 0)
        }
        .frame(maxHeight: .infinity)
        .padding(.top, 30)
        .padding(.bottom, 24)
        .clipped()
    }

    private func decoPatternBlock(offset idx: Int) -> some View {
        let size: CGFloat = 35
        let smallW: CGFloat = 24
        let smallH: CGFloat = 7
        return VStack(spacing: 4) {
            softDecoImage("sp-deco-\(idx + 7)", w: size + 2, h: size)
            softDecoImage("sp-deco-\(idx + 6)", w: size, h: size)
            softDecoImage("sp-deco-\(idx + 5)", w: size, h: size - 4)
            ZStack {
                softDecoImage("sp-deco-\(idx + 1)", w: size, h: size)
                softDecoImage("sp-deco-\(idx + 2)", w: smallW, h: smallH)
                    .offset(x: -4)
                softDecoImage("sp-deco-\(idx + 3)", w: smallW, h: smallH)
                    .offset(x: 4)
                softDecoImage("sp-deco-\(idx + 4)", w: 5, h: smallW + 2)
            }
            .frame(width: size, height: size)
            softDecoImage("sp-deco-\(idx)", w: size, h: size)
        }
    }

    /// Soft “transparent into white” look (Figma): double-pass low opacity instead of solid `#31231B` strokes.
    /// Replace with asset `sp-transparent-white-box` (same art, light/soft strokes) when added to the catalog — swap `Image(name)` below for `Image("sp-transparent-white-box")` using the same sizes.
    private func softDecoImage(_ name: String, w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            Image(name)
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
                .opacity(0.11)
            Image(name)
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
                .opacity(0.07)
                .offset(x: 0.8, y: 0.8)
        }
        .frame(width: w, height: h)
        .rotationEffect(.degrees(-90))
    }

    // MARK: - Profile (Figma 1072:6207)

    private var profileSection: some View {
        VStack(alignment: isArabic ? .center : .leading, spacing: 0) {
            Image("side-panel-avatar")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 68, height: 68)

            Text(isArabic ? "عبدالله خالد" : "Abdullah Khalid")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: 0x0F0F0F))
                .multilineTextAlignment(isArabic ? .center : .leading)
                .padding(.top, 10)

            Text(isArabic ? "عضو" : "Member")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color(hex: 0x6C7072))
                .multilineTextAlignment(isArabic ? .center : .leading)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: isArabic ? .center : .leading)
    }

    // MARK: - Menu

    private var menuSection: some View {
        VStack(spacing: 0) {
            menuRow(icon: "side-panel-home", label: isArabic ? "الرئيسية" : "Home", useSFSymbol: false) {
                withAnimation(.easeInOut(duration: 0.25)) { isOpen = false }
            }
            NavigationLink(destination: ProfileView()) {
                menuRowContent(icon: "person", label: isArabic ? "الحساب" : "Profile", useSFSymbol: true)
            }
            .buttonStyle(PlainButtonStyle())
            .simultaneousGesture(TapGesture().onEnded {
                withAnimation(.easeInOut(duration: 0.25)) { isOpen = false }
            })
            NavigationLink(destination: MembershipView()) {
                menuRowContent(icon: "side-panel-membership", label: isArabic ? "العضوية" : "Membership", useSFSymbol: false)
            }
            .buttonStyle(PlainButtonStyle())
            .simultaneousGesture(TapGesture().onEnded {
                withAnimation(.easeInOut(duration: 0.25)) { isOpen = false }
            })
        }
    }

    /// Figma 1072:6207: icons hug the decorative strip (AR strip right → icon right; EN strip left → icon left).
    private func menuRowContent(icon: String, label: String, useSFSymbol: Bool) -> some View {
        let iconGroup = Group {
            if useSFSymbol {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
                    .foregroundColor(Color(hex: 0x6C7072))
            } else {
                Image(icon)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(hex: 0x6C7072))
            }
        }
        .frame(width: 28, height: 28, alignment: .center)

        return HStack(spacing: 12) {
            if isArabic {
                Text(label)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: 0x0F0F0F))
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                iconGroup
            } else {
                iconGroup
                Text(label)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: 0x0F0F0F))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 56)
        .environment(\.layoutDirection, .leftToRight)
    }

    private func menuRow(icon: String, label: String, useSFSymbol: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            menuRowContent(icon: icon, label: label, useSFSymbol: useSFSymbol)
        }
    }

    // MARK: - Logout (Figma AR: «الخروج» + icon on outer side)

    private var logoutButton: some View {
        Button(action: {}) {
            HStack(spacing: 14) {
                let logoutIcon = Image("side-panel-logout")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 14)
                    .foregroundColor(Color(hex: 0xA71E1E))
                if isArabic {
                    Text("الخروج")
                        .font(.custom("ExpoArabic-Medium", size: 16))
                        .foregroundColor(Color(hex: 0xA71E1E))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    logoutIcon
                } else {
                    logoutIcon
                    Text("Logout")
                        .font(.custom("ExpoArabic-Medium", size: 16))
                        .foregroundColor(Color(hex: 0xA71E1E))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .environment(\.layoutDirection, .leftToRight)
        }
    }
}

private extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}
