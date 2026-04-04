import SwiftUI

struct CarDetailView: View {
    let car: CarListing
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss

    @State private var showPickupDateScreen = false
    @State private var pickupDate = Date()
    @State private var goToPickupMap = false

    private let brandBrown = Color(red: 0x31 / 255, green: 0x23 / 255, blue: 0x1B / 255)
    private let pageBg = Color(red: 0xF3 / 255, green: 0xF3 / 255, blue: 0xF3 / 255)
    private let darkGreen = Color(red: 0x21 / 255, green: 0x3C / 255, blue: 0x2E / 255)

    private var isArabic: Bool { languageManager.current == .arabic }

    var body: some View {
        ZStack(alignment: .top) {
            pageBg.ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: isArabic ? .trailing : .leading, spacing: 0) {
                        carImageSection
                        detailsSection
                    }
                }
                Spacer(minLength: 0)
                bookButton
                bottomTabBar
            }
        }
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showPickupDateScreen) {
            NavigationStack {
                CarPickupDateView(
                    pickupDate: $pickupDate,
                    onCancel: { showPickupDateScreen = false },
                    onNext: {
                        showPickupDateScreen = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            goToPickupMap = true
                        }
                    }
                )
                .environmentObject(languageManager)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .navigationDestination(isPresented: $goToPickupMap) {
            CarPickupLocationView(car: car, pickupDate: pickupDate)
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        ZStack {
            brandBrown.ignoresSafeArea(edges: .top)

            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .flipsForRightToLeftLayoutDirection(false)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Spacer()

                Image("mrasem-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)

                Spacer()

                Button(action: {}) {
                    Image("group2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 20)
                }
                .buttonStyle(.plain)
            }
            .environment(\.layoutDirection, .leftToRight)
            .padding(.horizontal, 24)
        }
        .frame(height: 100)
    }

    // MARK: - Car Image (185pt, 17pt corners — Figma 348:3666)

    private var carImageSection: some View {
        Image(car.imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity)
            .frame(height: 185)
            .clipped()
            .cornerRadius(17)
    }

    // MARK: - Details

    private var detailsSection: some View {
        VStack(alignment: isArabic ? .trailing : .leading, spacing: 0) {
            Text(car.displayName(isArabic: isArabic))
                .font(.custom("ExpoArabic-Medium", size: 20))
                .foregroundColor(brandBrown)
                .multilineTextAlignment(isArabic ? .trailing : .leading)
                .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                .padding(.top, 16)

            Text(car.displayListSubtitle(isArabic: isArabic))
                .font(.custom("ExpoArabic-Medium", size: 12))
                .foregroundColor(darkGreen.opacity(0.58))
                .multilineTextAlignment(isArabic ? .trailing : .leading)
                .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                .padding(.top, 4)

            Text(isArabic ? "عن المركبة" : "About")
                .font(.custom("ExpoArabic-Medium", size: 16))
                .foregroundColor(darkGreen)
                .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                .padding(.top, 22)

            Text(car.displayAbout(isArabic: isArabic))
                .font(.custom("ExpoArabic-Medium", size: 12))
                .foregroundColor(darkGreen.opacity(0.81))
                .lineSpacing(4)
                .multilineTextAlignment(isArabic ? .trailing : .leading)
                .padding(.top, 8)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                if isArabic {
                    Text(car.displayPassengersLine(isArabic: true))
                        .font(.custom("ExpoArabic-Medium", size: 12))
                        .foregroundColor(darkGreen)
                    Image("car-passenger-icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)
                } else {
                    Image("car-passenger-icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)
                    Text(car.displayPassengersLine(isArabic: false))
                        .font(.custom("ExpoArabic-Medium", size: 12))
                        .foregroundColor(darkGreen)
                }
            }
            .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
            .padding(.top, 30)
        }
        .padding(.horizontal, 21)
    }

    // MARK: - Book

    private var bookButton: some View {
        Button(action: { showPickupDateScreen = true }) {
            Text(isArabic ? "احجز" : "Book")
                .font(.custom("ExpoArabic-Medium", size: 22))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(brandBrown)
                .cornerRadius(13)
        }
        .padding(.horizontal, 29)
        .padding(.bottom, 12)
    }

    // MARK: - Bottom Tab Bar

    private var bottomTabBar: some View {
        ZStack {
            brandBrown.ignoresSafeArea(edges: .bottom)
            HStack(spacing: 0) {
                Spacer()
                NavigationLink(destination: CategorySelectionView()) {
                    Image("nav-icon-home").resizable().renderingMode(.original).aspectRatio(contentMode: .fit).frame(width: 20, height: 22)
                }.buttonStyle(PlainButtonStyle())
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
            Image(name).resizable().renderingMode(.original).aspectRatio(contentMode: .fit).frame(width: w, height: h)
        }
    }
}

#Preview {
    NavigationStack {
        CarDetailView(car: CarListing(
            name: "Chevrolet Tahoe",
            category: "Standard",
            passengers: 7,
            imageName: "car-tahoe",
            about: "The Chevrolet Tahoe delivers a comfortable and reliable ride."
        ))
        .environmentObject(LanguageManager())
        .environmentObject(InvitationStore())
    }
}
