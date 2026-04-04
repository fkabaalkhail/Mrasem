import SwiftUI

struct OTPVerificationView: View {
    let phoneNumber: String
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var reservationStore: ReservationStore
    @EnvironmentObject private var invitationStore: InvitationStore
    @State private var otpDigits: [String] = Array(repeating: "", count: 5)
    @FocusState private var focusedIndex: Int?

    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)

    var body: some View {
        ZStack {
            brandBrown.ignoresSafeArea()

            VStack(spacing: 0) {
                // Title on brown
                Text(languageManager.current == .arabic ? "التحقق" : "Verification")
                    .font(.custom("ExpoArabic-Medium", size: 20))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.top, 70)

                // White sheet — top:142 in Figma, height:670
                ZStack(alignment: .top) {
                    Color.white
                        .clipShape(RoundedCorner(radius: 50, corners: [.topLeft, .topRight]))

                    VStack(spacing: 0) {
                        // Body text
                        VStack(spacing: 0) {
                            Text(languageManager.current == .arabic
                                 ? "لقد أرسلنا لك رمز التحقق على"
                                 : "We've sent you a verification code on")
                                .font(.custom("ExpoArabic-Medium", size: 14))
                                .fontWeight(.medium)
                                .foregroundColor(brandBrown)
                                .multilineTextAlignment(languageManager.current == .arabic ? .trailing : .leading)

                            Text("+966 \(phoneNumber)")
                                .font(.custom("ExpoArabic-Medium", size: 14))
                                .fontWeight(.medium)
                                .foregroundColor(brandBrown)
                        }
                        .frame(width: 285, alignment: languageManager.current == .arabic ? .trailing : .leading)
                        .padding(.top, 25)

                        // 5 OTP boxes — 60×60, rounded 13, border brandBrown, spaced ~66px apart
                        HStack(spacing: 6) {
                            ForEach(0..<5, id: \.self) { index in
                                TextField("", text: $otpDigits[index])
                                    .font(.custom("ExpoArabic-Medium", size: 32))
                                    .fontWeight(.medium)
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                    .keyboardType(.numberPad)
                                    .frame(width: 60, height: 60)
                                    .background(otpDigits[index].isEmpty ? Color.clear : Color.white)
                                    .overlay(RoundedRectangle(cornerRadius: 13).stroke(brandBrown, lineWidth: 1))
                                    .cornerRadius(13)
                                    .focused($focusedIndex, equals: index)
                                    .onChange(of: otpDigits[index]) { _, newValue in
                                        if newValue.count > 1 {
                                            otpDigits[index] = String(newValue.last!)
                                        }
                                        if !newValue.isEmpty && index < 4 {
                                            focusedIndex = index + 1
                                        }
                                    }
                            }
                        }
                        .padding(.top, 93)

                        // Continue button — 287×56, brandBrown, rounded 13
                        NavigationLink(destination: CategorySelectionView()
                            .environmentObject(languageManager)
                            .environmentObject(reservationStore)
                            .environmentObject(invitationStore)) {
                            Text(languageManager.current == .arabic ? "متابعة" : "Continue")
                                .font(.custom("ExpoArabic-Medium", size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(width: 287, height: 56)
                                .background(brandBrown)
                                .cornerRadius(13)
                        }
                        .padding(.top, 41)

                        // Resend text — textGreen, 16px
                        Text(languageManager.current == .arabic
                             ? "إعادة إرسال الرمز خلال 0:55"
                             : "Re- send code in 0:55")
                            .font(.custom("ExpoArabic-Medium", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(textGreen)
                            .padding(.top, 20)

                        Spacer()
                    }
                }
                .padding(.top, 25)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationBarHidden(true)
        .onAppear { focusedIndex = 0 }
    }
}

#Preview {
    NavigationStack {
        OTPVerificationView(phoneNumber: "506744153")
            .environmentObject(LanguageManager())
            .environmentObject(ReservationStore())
            .environmentObject(InvitationStore())
    }
}
