import SwiftUI

/// Display labels for additional services; selection values stay English for storage and APIs.
enum AdditionalServiceLocalization {
    static func label(for key: String, arabic: Bool) -> String {
        guard arabic else { return key }
        switch key {
        case "Personal Helper": return "مساعد شخصي"
        case "Wheelchair": return "كرسي متحرك"
        case "Translator": return "مترجم"
        default: return key
        }
    }

    static func noServicesPlaceholder(arabic: Bool) -> String {
        arabic ? "بدون خدمات إضافية" : "No additional services"
    }

    static func joinedDisplay(services: Set<String>, arabic: Bool) -> String {
        services.sorted().map { label(for: $0, arabic: arabic) }.joined(separator: ", ")
    }
}

/// Frame of the “Additional services” field in `BookingDetailsView`’s named coordinate space (reliable vs global overlay math).
struct AdditionalServicesFieldFramePreference: PreferenceKey {
    static var defaultValue: CGRect { .zero }
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        let n = nextValue()
        if n.width > 0, n.height > 0 { value = n }
    }
}

/// Additional services picker — Figma **1202:11601** (dropdown list: 8pt radius, 44pt rows, shadow 0/4/14 @ 10%).
struct AdditionalServicesPopupView: View {
    @Binding var isPresented: Bool
    @Binding var selection: Set<String>
    /// Distance from the top of this overlay to place the dropdown (field `maxY` + gap in the same coordinate space as the overlay’s parent).
    var dropdownTopInset: CGFloat

    @EnvironmentObject private var languageManager: LanguageManager

    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)
    private let rowHighlight = Color.black.opacity(0.04)

    private var isArabic: Bool { languageManager.current == .arabic }

    /// Figma copy order; last row clears selection. `key` is stored in `selection` (English).
    private let rows: [(key: String, clearsSelection: Bool)] = [
        ("Personal Helper", false),
        ("Wheelchair", false),
        ("Translator", false),
        ("__clear__", true),
    ]

    var body: some View {
        let gap: CGFloat = 8
        ZStack(alignment: .top) {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) { isPresented = false }
                }

            dropdownCard
                .padding(.horizontal, 21)
                .padding(.top, max(0, dropdownTopInset + gap))
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .top)),
                    removal: .opacity
                ))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
        .ignoresSafeArea()
    }

    private var dropdownCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                let isSelected = isRowSelected(key: row.key, clears: row.clearsSelection)
                let displayTitle = row.key == "__clear__"
                    ? AdditionalServiceLocalization.noServicesPlaceholder(arabic: isArabic)
                    : AdditionalServiceLocalization.label(for: row.key, arabic: isArabic)
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if row.clearsSelection {
                            selection.removeAll()
                        } else {
                            selection = [row.key]
                        }
                        isPresented = false
                    }
                } label: {
                    HStack(alignment: .center, spacing: 0) {
                        Text(displayTitle)
                            .font(.custom("ExpoArabic-Medium", size: 14))
                            .foregroundColor(textGreen)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.leading, 16)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(isSelected ? rowHighlight : Color.clear)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, 6)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: Color.black.opacity(0.1), radius: 7, x: 0, y: 4)
    }

    private func isRowSelected(key: String, clears: Bool) -> Bool {
        if clears { return selection.isEmpty }
        return selection.contains(key)
    }
}
