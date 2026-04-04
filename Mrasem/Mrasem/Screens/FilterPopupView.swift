import SwiftUI

struct FilterPopupView: View {
    @Binding var isPresented: Bool
    @Binding var selectedArea: String
    @State private var selectedFilter: String = ""
    @EnvironmentObject private var languageManager: LanguageManager

    private let brandBrown = Color(red: 0x31/255, green: 0x23/255, blue: 0x1B/255)
    private let darkGreen = Color(red: 0x21/255, green: 0x3C/255, blue: 0x2E/255)
    private let chipBorder = Color(red: 0xEC/255, green: 0xED/255, blue: 0xF0/255)
    private let chipText = Color(red: 0x55/255, green: 0x5E/255, blue: 0x67/255)

    /// Canonical English keys for API / `RestaurantStore` (unchanged).
    private let areaKeysLTR = ["Jeddah", "Riyadh", "Mecca", "AlUla", "Southern Provence"]
    /// Figma 1389:38071 — RTL row order: الرياض|جدة then العلا|مكة; southern alone on reading-start (half width).
    private let areaKeysRTL = ["Riyadh", "Jeddah", "AlUla", "Mecca", "Southern Provence"]
    private let filterKeys = ["Restaurants", "Activities and Tours", "Season Events", "Cars"]

    private var isArabic: Bool { languageManager.current == .arabic }

    private var areaKeys: [String] { isArabic ? areaKeysRTL : areaKeysLTR }

    private func areaLabel(for key: String) -> String {
        switch key {
        case "Jeddah": return isArabic ? "جدة" : "Jeddah"
        case "Riyadh": return isArabic ? "الرياض" : "Riyadh"
        case "Mecca": return isArabic ? "مكة" : "Mecca"
        case "AlUla": return isArabic ? "العلا" : "AlUla"
        case "Southern Provence": return isArabic ? "المنطقة الجنوبية" : "Southern Provence"
        default: return key
        }
    }

    private func filterLabel(for key: String) -> String {
        switch key {
        case "Restaurants": return isArabic ? "مطاعم" : "Restaurants"
        case "Activities and Tours": return isArabic ? "أنشطة وجولات سياحية" : "Activities and Tours"
        case "Season Events": return isArabic ? "فعاليات الموسم" : "Season Events"
        case "Cars": return isArabic ? "السيارات" : "Cars"
        default: return key
        }
    }

    var body: some View {
        // Figma 1377:22315 — full-screen overlay; white sheet is pinned to the bottom (631pt tall, top corners 30).
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) { isPresented = false }
                }

            sheetContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }

    private var sheetContent: some View {
        VStack(spacing: 0) {
            dragIndicator
                .padding(.top, 14)

            Text(isArabic ? "تصفية حسب" : "Filter by:")
                .font(.custom("ExpoArabic-Medium", size: 16))
                .foregroundColor(brandBrown)
                .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                .padding(isArabic ? .trailing : .leading, 11)
                .padding(.top, 16)

            areaSection
                .padding(.top, 20)

            divider
                .padding(.top, 24)

            filterSection
                .padding(.top, 16)

            Spacer()

            applyButton
                .padding(.bottom, 30)
        }
        .frame(height: 631)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(30, corners: [.topLeft, .topRight])
        .ignoresSafeArea(edges: .bottom)
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
    }

    private var dragIndicator: some View {
        RoundedRectangle(cornerRadius: 7)
            .fill(brandBrown.opacity(0.73))
            .frame(width: 39, height: 6)
    }

    // MARK: - Area Section

    private var areaSection: some View {
        VStack(alignment: isArabic ? .trailing : .leading, spacing: 12) {
            Text(isArabic ? "المنطقة" : "Area")
                .font(.custom("ExpoArabic-Medium", size: 14))
                .foregroundColor(darkGreen)
                .padding(isArabic ? .trailing : .leading, 12)

            chipGrid(keys: areaKeys, label: areaLabel(for:), selected: $selectedArea, loneChipHalfWidth: isArabic)
        }
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        VStack(alignment: isArabic ? .trailing : .leading, spacing: 12) {
            Text(isArabic ? "التصنيف" : "Filter")
                .font(.custom("ExpoArabic-Medium", size: 14))
                .foregroundColor(darkGreen)
                .padding(isArabic ? .trailing : .leading, 12)

            chipGrid(keys: filterKeys, label: filterLabel(for:), selected: $selectedFilter, loneChipHalfWidth: false)
        }
    }

    // MARK: - Chip Grid (2 columns)

    private func chipGrid(keys: [String], label: @escaping (String) -> String, selected: Binding<String>, loneChipHalfWidth: Bool) -> some View {
        let rows = stride(from: 0, to: keys.count, by: 2).map { i in
            Array(keys[i..<min(i + 2, keys.count)])
        }

        return VStack(spacing: 10) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { key in
                        chipButton(
                            label: label(key),
                            isSelected: selected.wrappedValue == key,
                            fillRowWidth: row.count > 1 || !loneChipHalfWidth,
                            action: {
                                selected.wrappedValue = selected.wrappedValue == key ? "" : key
                            }
                        )
                    }
                    if row.count == 1 {
                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
    }

    /// Figma — selected chip uses a stronger `213C2E` stroke than the 1pt `ECEDF0` default.
    private func chipButton(label: String, isSelected: Bool, fillRowWidth: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.custom("ExpoArabic-Medium", size: 12))
                .foregroundColor(isSelected ? darkGreen : chipText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .padding(.horizontal, 8)
                .frame(height: 48)
                .frame(maxWidth: fillRowWidth ? .infinity : 171.5)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? darkGreen : chipBorder, lineWidth: isSelected ? 2 : 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Divider

    private var divider: some View {
        Rectangle()
            .fill(chipBorder)
            .frame(height: 1)
            .padding(.horizontal, 12)
    }

    // MARK: - Apply Button

    private var applyButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.25)) { isPresented = false }
        }) {
            Text(isArabic ? "تطبيق" : "Apply")
                .font(.custom("ExpoArabic-Medium", size: 14))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 49)
                .background(brandBrown)
                .cornerRadius(13)
        }
        .padding(.horizontal, 13)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
