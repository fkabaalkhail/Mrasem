import MapKit
import SwiftUI

// MARK: - Product / client follow-ups (car rentals — Figma **981:1576** location step)
//
// When the client defines operations, consider persisting: pickup + return date/time (see rental-days UI on
// `CarPickupDateView`), pickup vs return locations, fleet availability from an API, pricing rules, deposits,
// optional driver, insurance add-ons, and a booking record linked to `CarListing` id (not only display name).
//
/// Pickup map — Figma **981:1576** (RTL title **اختر موقع الالتقاء**, 327×198 map @ 5pt radius).
struct CarPickupLocationView: View {
    let car: CarListing
    let pickupDate: Date

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageManager: LanguageManager

    private let brandBrown = Color(red: 0x31 / 255, green: 0x23 / 255, blue: 0x1B / 255)
    private let pageBg = Color(red: 0xF3 / 255, green: 0xF3 / 255, blue: 0xF3 / 255)

    private static let templateCoordinate = CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753)

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CarPickupLocationView.templateCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.045, longitudeDelta: 0.045)
        )
    )

    private var isArabic: Bool { languageManager.current == .arabic }

    var body: some View {
        ZStack(alignment: .top) {
            pageBg.ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar

                mapSection
                    .padding(.top, 32)

                Spacer(minLength: 0)

                bottomTabBar
            }
        }
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
        .navigationBarHidden(true)
    }

    // MARK: - Header (Figma 981:1580 — 172pt brown, title white 20pt)

    private var headerBar: some View {
        ZStack(alignment: .bottom) {
            brandBrown.ignoresSafeArea(edges: .top)

            VStack(alignment: isArabic ? .trailing : .leading, spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.top, 4)

                Text(isArabic ? "اختر موقع الالتقاء" : "Choose pickup location")
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

    // MARK: - Map (327×198 @ 24 inset, 5pt radius — Figma 984:2034)

    private var mapSection: some View {
        Map(position: $position) {
            Marker(isArabic ? "الالتقاء" : "Pickup", coordinate: Self.templateCoordinate)
                .tint(.red)
        }
        .mapStyle(.standard(elevation: .realistic))
        .frame(height: 198)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }

    // MARK: - Bottom bar (50pt — Figma 981:1581)

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

#Preview {
    NavigationStack {
        CarPickupLocationView(
            car: CarListing(name: "Chevrolet Tahoe", category: "Standard", passengers: 7, imageName: "car-tahoe"),
            pickupDate: Date()
        )
        .environmentObject(LanguageManager())
        .environmentObject(InvitationStore())
    }
}
