import SwiftUI

/// Cars filter bottom sheet — Figma **1202:11294**; Arabic copy for **1377:22980**.
struct CarFilterPopupView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @Binding var isPresented: Bool
    @Binding var activeFilters: Set<String>

    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    private let darkGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)
    private let chipBorder = Color(red: 0xEC / 255.0, green: 0xED / 255.0, blue: 0xF0 / 255.0)
    private let chipText = Color(red: 0x55 / 255.0, green: 0x5E / 255.0, blue: 0x67 / 255.0)

    private let categories = ["Standard", "Luxury"]
    private let passengers = ["4 Passengers", "7 Passengers", "8-15 Passengers"]

    private var isArabic: Bool { languageManager.current == .arabic }

    var body: some View {
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

            Text(isArabic ? "تصفية حسب:" : "Filter by:")
                .font(.custom("ExpoArabic-Medium", size: 16))
                .foregroundColor(brandBrown)
                .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                .padding(.horizontal, 11)
                .padding(.top, 16)

            categorySection
                .padding(.top, 16)

            divider
                .padding(.top, 20)

            passengersSection
                .padding(.top, 14)

            Spacer(minLength: 8)

            applyButton
                .padding(.bottom, 30)
        }
        .frame(height: 441)
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

    private var categorySection: some View {
        VStack(alignment: isArabic ? .trailing : .leading, spacing: 12) {
            Text(isArabic ? "الفئة" : "Category")
                .font(.custom("ExpoArabic-Medium", size: 14))
                .foregroundColor(darkGreen)
                .padding(.horizontal, 12)

            chipGridMulti(items: categories)
        }
    }

    private var passengersSection: some View {
        VStack(alignment: isArabic ? .trailing : .leading, spacing: 12) {
            Text(isArabic ? "الركاب" : "Passengers")
                .font(.custom("ExpoArabic-Medium", size: 14))
                .foregroundColor(darkGreen)
                .padding(.horizontal, 12)

            chipGridMulti(items: passengers)
        }
    }

    private func chipGridMulti(items: [String]) -> some View {
        let rows = stride(from: 0, to: items.count, by: 2).map { i in
            Array(items[i..<min(i + 2, items.count)])
        }

        return VStack(spacing: 10) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { item in
                        chipToggle(item)
                    }
                    if row.count == 1 {
                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
    }

    private func chipLabel(_ key: String) -> String {
        CarFilterKey.displayLabel(key, isArabic: isArabic)
    }

    private func chipToggle(_ label: String) -> some View {
        let isOn = activeFilters.contains(label)
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if isOn {
                    activeFilters.remove(label)
                } else {
                    activeFilters.insert(label)
                }
            }
        } label: {
            Text(chipLabel(label))
                .font(.custom("ExpoArabic-Medium", size: 12))
                .foregroundColor(isOn ? darkGreen : chipText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isOn ? darkGreen : chipBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var divider: some View {
        Rectangle()
            .fill(chipBorder)
            .frame(height: 1)
            .padding(.horizontal, 12)
    }

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
