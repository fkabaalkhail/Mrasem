import SwiftUI

struct OTPVerificationView: View {
    let phoneNumber: String
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var reservationStore: ReservationStore
    @EnvironmentObject private var invitationStore: InvitationStore
    @State private var otpDigits: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedIndex: Int?
    @State private var isVerified = false
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var resendCountdown = 55
    @State private var resendTimer: Timer?

    @Environment(\.dismiss) private var dismiss

    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)

    /// Figma verification (8:613): 60×60 cells, 13pt corner, ~6pt gap; 6 digits scaled to fit 375pt width.
    private let figmaOTPBox: CGFloat = 60
    private let figmaOTPCorner: CGFloat = 13
    private let figmaOTPGap: CGFloat = 6
    /// Instruction block top inset inside white sheet (Figma: 167 − 142 = 25).
    private let figmaInstructionTop: CGFloat = 25
    /// Gap from instruction block to OTP row (Figma ≈ 118 − 25 − two 14pt lines).
    private let figmaInstructionToOTP: CGFloat = 39
    /// Gap from OTP row bottom to Continue (Figma: 361 − 260 − 60 = 41).
    private let figmaOTPToContinue: CGFloat = 41

    private var isArabic: Bool { languageManager.current == .arabic }

    var body: some View {
        ZStack {
            brandBrown.ignoresSafeArea()

            VStack(spacing: 0) {
                // Figma EN: "Verification" / AR (1449:9871): "التأكيد" — same 20pt, top ~70; back mirrors for RTL
                ZStack {
                    HStack {
                        if isArabic {
                            Spacer()
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        } else {
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 24)

                    Text(isArabic ? "التأكيد" : "Verification")
                        .font(.custom("ExpoArabic-Medium", size: 20))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                .padding(.top, 70)

                // White sheet — Figma top 142pt ⇒ ~28pt below ~114pt header block
                ZStack(alignment: .top) {
                    Color.white
                        .clipShape(RoundedCorner(radius: 50, corners: [.topLeft, .topRight]))

                    VStack(spacing: 0) {
                        instructionBlock
                            .padding(.top, figmaInstructionTop)

                        if AuthenticationManager.shared.isDemoModeEnabled {
                            Text(isArabic ? "وضع العرض: أدخل الرمز 000000" : "Demo: enter code 000000")
                                .font(.custom("ExpoArabic-Medium", size: 13))
                                .foregroundColor(textGreen.opacity(0.85))
                                .multilineTextAlignment(isArabic ? .trailing : .center)
                                .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .center)
                                .padding(.top, 12)
                                .padding(.horizontal, 24)
                        }

                        // OTP row — always LTR digit order; Figma 32pt numerals when filled
                        otpDigitRow
                            .padding(.top, figmaInstructionToOTP)
                            .environment(\.layoutDirection, .leftToRight)

                        // Continue — 287×56, corner 13
                        Button(action: { verifyOTP() }) {
                            Group {
                                if isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text(isArabic ? "المتابعة" : "Continue")
                                }
                            }
                            .font(.custom("ExpoArabic-Medium", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(width: 287, height: 56)
                            .background(brandBrown)
                            .cornerRadius(13)
                        }
                        .disabled(isLoading)
                        .padding(.top, figmaOTPToContinue)

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.custom("ExpoArabic-Medium", size: 14))
                                .foregroundColor(.red)
                                .multilineTextAlignment(isArabic ? .trailing : .center)
                                .frame(maxWidth: 285)
                                .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .center)
                                .padding(.horizontal, 24)
                                .padding(.top, 12)
                        }

                        // Figma EN: "Re-send code…" / AR 17:225: "إعادة ارسال الرمز خلال 0:55" — same 16pt #213c2e, centered
                        if resendCountdown > 0 {
                            Text(isArabic
                                 ? "إعادة ارسال الرمز خلال 0:\(String(format: "%02d", resendCountdown))"
                                 : "Re-send code in 0:\(String(format: "%02d", resendCountdown))")
                                .font(.custom("ExpoArabic-Medium", size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(textGreen)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 297)
                                .padding(.top, 20)
                        } else {
                            Button(action: { resendOTP() }) {
                                Text(isArabic ? "إعادة ارسال الرمز" : "Resend Code")
                                    .font(.custom("ExpoArabic-Medium", size: 16))
                                    .fontWeight(.medium)
                                    .foregroundColor(textGreen)
                                    .underline()
                            }
                            .padding(.top, 20)
                        }

                        NavigationLink(
                            destination: CategorySelectionView()
                                .environmentObject(languageManager)
                                .environmentObject(reservationStore)
                                .environmentObject(invitationStore),
                            isActive: $isVerified
                        ) { EmptyView() }

                        Spacer(minLength: 0)
                    }
                }
                .padding(.top, 28)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarHidden(true)
        .onAppear {
            focusedIndex = 0
            startResendTimer()
            // Send OTP to Supabase when screen appears
            let digits = phoneNumber.filter { $0.isNumber }
            let normalized = digits.hasPrefix("0") ? "+966\(digits.dropFirst())" : "+966\(digits)"
            Task {
                try? await AuthenticationManager.shared.sendOTP(phone: normalized)
            }
        }
        .onDisappear { resendTimer?.invalidate() }
    }

    /// Figma: same 285pt-wide block & vertical metrics EN/AR; EN centered (8:613), AR trailing (17:223).
    private var instructionBlock: some View {
        VStack(alignment: isArabic ? .trailing : .center, spacing: 0) {
            Text(isArabic
                 ? "تم ارسال رمز التحقق على"
                 : "We've sent you a verification code on")
                .font(.custom("ExpoArabic-Medium", size: 14))
                .fontWeight(.medium)
                .foregroundColor(brandBrown)
                .multilineTextAlignment(isArabic ? .trailing : .center)
                .lineSpacing(4)

            Text(formattedPhoneLine)
                .font(.custom("ExpoArabic-Medium", size: 14))
                .fontWeight(.medium)
                .foregroundColor(brandBrown)
                .multilineTextAlignment(isArabic ? .trailing : .center)
        }
        .frame(maxWidth: 285, alignment: isArabic ? .trailing : .center)
        .frame(maxWidth: .infinity)
    }

    private var formattedPhoneLine: String {
        let digits = phoneNumber.filter { $0.isNumber }
        let local = digits.hasPrefix("966") ? String(digits.dropFirst(3)) : (digits.hasPrefix("0") ? String(digits.dropFirst()) : digits)
        return "+966 \(local)"
    }

    private var otpCellSide: CGFloat {
        let w = UIScreen.main.bounds.width
        let count: CGFloat = 6
        let gap = figmaOTPGap
        let available = max(0, w - 48)
        let raw = (available - (count - 1) * gap) / count
        return min(figmaOTPBox, max(44, floor(raw)))
    }

    private var otpDigitRow: some View {
        let side = otpCellSide
        let count = 6
        return HStack(spacing: figmaOTPGap) {
            ForEach(0..<count, id: \.self) { index in
                TextField("", text: $otpDigits[index])
                    .font(.custom("ExpoArabic-Medium", size: 32))
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .frame(width: side, height: side)
                    .background(otpDigits[index].isEmpty ? Color.clear : Color.white)
                    .overlay(RoundedRectangle(cornerRadius: figmaOTPCorner).stroke(brandBrown, lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: figmaOTPCorner))
                    .focused($focusedIndex, equals: index)
                    .onChange(of: otpDigits[index]) { old, newValue in
                        if newValue.count > 1 {
                            otpDigits[index] = String(newValue.last!)
                        }
                        if !newValue.isEmpty && index < count - 1 {
                            focusedIndex = index + 1
                        }
                        // Backspace: field was cleared — move back and clear previous
                        if newValue.isEmpty && !old.isEmpty && index > 0 {
                            DispatchQueue.main.async {
                                focusedIndex = index - 1
                            }
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func verifyOTP() {
        let code = otpDigits.joined()
        guard code.count == 6 else {
            errorMessage = languageManager.current == .arabic ? "أدخل الرمز المكون من 6 أرقام" : "Enter the 6-digit code"
            return
        }
        errorMessage = nil
        isLoading = true

        let digits = phoneNumber.filter { $0.isNumber }
        let normalized = digits.hasPrefix("0") ? "+966\(digits.dropFirst())" : "+966\(digits)"
        AuthenticationManager.shared.savePhoneNumber(normalized)
        AuthenticationManager.shared.verifyPhone(otp: code) { success, err in
            isLoading = false
            if success {
                isVerified = true
            } else {
                errorMessage = languageManager.current == .arabic ? "رمز التحقق غير صحيح" : "Wrong verification code"
            }
        }
    }

    private func resendOTP() {
        let digits = phoneNumber.filter { $0.isNumber }
        let normalized = digits.hasPrefix("0") ? "+966\(digits.dropFirst())" : "+966\(digits)"
        resendCountdown = 55
        startResendTimer()
        Task {
            try? await AuthenticationManager.shared.sendOTP(phone: normalized)
        }
    }

    private func startResendTimer() {
        resendTimer?.invalidate()
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if resendCountdown > 0 { resendCountdown -= 1 }
            else { resendTimer?.invalidate() }
        }
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
