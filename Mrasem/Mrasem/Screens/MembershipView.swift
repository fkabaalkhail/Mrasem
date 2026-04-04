import SwiftUI

struct MembershipView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageManager: LanguageManager

    @State private var isAddingToWallet = false
    @State private var walletAlertMessage: String?

    private var isArabic: Bool { languageManager.current == .arabic }

    private let brandBrown = Color(red: 0x31/255, green: 0x23/255, blue: 0x1B/255)
    private let panelHairline = Color.black.opacity(0.16)
    private let cardWidthPhone: CGFloat = 320

    var body: some View {
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar

                ZStack(alignment: .top) {
                    Color.white

                    VStack(spacing: 0) {
                        decorativeStrip

                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: isArabic ? .trailing : .leading, spacing: 0) {
                                Text(isArabic ? "عضويتي" : "My Membership")
                                    .font(.custom("ExpoArabic-Medium", size: 20))
                                    .foregroundColor(brandBrown)
                                    .padding(.leading, isArabic ? 0 : 13)
                                    .padding(.trailing, isArabic ? 13 : 0)
                                    .padding(.top, 18)
                                    .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)

                                membershipCard
                                    .padding(.top, 20)

                                appleWalletSection
                                    .padding(.top, 12)
                            }
                            .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                            .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
                            .padding(.bottom, 40)
                        }
                    }

                    HStack(spacing: 0) {
                        panelHairline.frame(width: 1)
                        Spacer(minLength: 0)
                        panelHairline.frame(width: 1)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .allowsHitTesting(false)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Apple Wallet", isPresented: Binding(
            get: { walletAlertMessage != nil },
            set: { if !$0 { walletAlertMessage = nil } }
        )) {
            Button("OK", role: .cancel) { walletAlertMessage = nil }
        } message: {
            Text(walletAlertMessage ?? "")
        }
    }

    // MARK: - Apple Wallet (Figma 1377:23174)

    private var appleWalletSection: some View {
        VStack(spacing: 10) {
            Button(action: {
                Task { await addMembershipToAppleWallet() }
            }) {
                Image("add-to-apple-wallet-badge")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 155, height: 48)
            }
            .buttonStyle(.plain)
            .disabled(isAddingToWallet)
            .accessibilityLabel(isArabic ? "إضافة إلى Apple Wallet" : "Add to Apple Wallet")

            if isAddingToWallet {
                ProgressView()
                    .tint(brandBrown)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @MainActor
    private func addMembershipToAppleWallet() async {
        isAddingToWallet = true
        defer { isAddingToWallet = false }
        do {
            try await WalletPassAddService.addMembershipPassToWallet()
        } catch {
            let msg = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            walletAlertMessage = msg
        }
    }

    // MARK: - Header

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
        Image(name)
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
    }

    private func decoImg(_ name: String, w: CGFloat, h: CGFloat) -> some View {
        Image(name)
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: w, height: h)
    }

    // MARK: - Membership Card

    private var membershipCard: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            VStack(spacing: 0) {
                ZStack {
                    brandBrown

                    Image("mrasem-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 44)
                }
                .frame(height: 98)

                ZStack {
                    Color.white

                    HStack(spacing: 6) {
                        decoImg("sp-deco-0", size: 42)
                        decoImg("sp-deco-5", size: 42)
                        decoImg("sp-deco-1", size: 42)
                        decoImg("sp-deco-6", size: 42)
                        decoImg("sp-deco-4", w: 14, h: 42)
                        decoImg("sp-deco-7", size: 42)
                    }

                    VStack(spacing: 0) {
                        panelHairline.frame(height: 1)
                        Spacer(minLength: 0)
                        panelHairline.frame(height: 1)
                    }
                    .allowsHitTesting(false)
                }
                .frame(height: 76)

                VStack(alignment: isArabic ? .trailing : .leading, spacing: 0) {
                    Text(isArabic ? "الاسم" : "NAME")
                        .font(.custom("ExpoArabic-Medium", size: 11))
                        .foregroundColor(.white)
                        .textCase(isArabic ? .none : .uppercase)
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)

                    Text(isArabic ? "عبدالله" : "Abdullah Khalid")
                        .font(.custom("ExpoArabic-Light", size: 28))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)

                    Text(isArabic ? "رقم العضوية" : "MEMBERSHIP NUMBER")
                        .font(.custom("ExpoArabic-Medium", size: 11))
                        .foregroundColor(.white)
                        .textCase(isArabic ? .none : .uppercase)
                        .padding(.top, 16)
                        .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)

                    Text("7826550197")
                        .font(.custom("ExpoArabic-Medium", size: 14))
                        .foregroundColor(.white)
                        .tracking(0.028)
                        .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                }
                .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                .padding(.horizontal, 16)
                .background(brandBrown)

                VStack(spacing: 12) {
                    VStack(spacing: 8) {
                        Image("membership-qr")
                            .resizable()
                            .interpolation(.none)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 118, height: 118)

                        Text("7826550197")
                            .font(.custom("ExpoArabic-Medium", size: 14))
                            .foregroundColor(brandBrown)
                            .tracking(0.028)
                    }
                    .padding(16)
                    .frame(width: 150, height: 176)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(panelHairline, lineWidth: 1)
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(brandBrown)
            }
            .frame(maxWidth: cardWidthPhone)
            .clipShape(RoundedRectangle(cornerRadius: 11))
            .overlay(
                RoundedRectangle(cornerRadius: 11)
                    .stroke(panelHairline, lineWidth: 1)
            )
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 28)
    }
}

#Preview {
    MembershipView()
        .environmentObject(LanguageManager())
}
