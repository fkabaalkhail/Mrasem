import SwiftUI

struct MembershipLoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var membershipNumber: String = ""
    @State private var rememberMe: Bool = false

    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
    private let textGreen = Color(red: 0x21 / 255.0, green: 0x3C / 255.0, blue: 0x2E / 255.0)

    var body: some View {
        ZStack {
            brandBrown.ignoresSafeArea()

            VStack(spacing: 0) {
                Text(languageManager.current == .arabic ? "تسجيل الدخول" : "Login")
                    .font(.custom("ExpoArabic-Medium", size: 20))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.top, 70)

                // White sheet
                ZStack(alignment: .top) {
                    Color.white
                        .clipShape(RoundedCorner(radius: 50, corners: [.topLeft, .topRight]))

                    VStack(spacing: 0) {
                        MembershipCardIcon()
                            .frame(width: 148, height: 177)
                            .padding(.top, 34)

                        Text(languageManager.current == .arabic ? "أدخل رقم العضوية" : "Enter your Membership Number")
                            .font(.custom("ExpoArabic-Medium", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(brandBrown)
                            .multilineTextAlignment(.center)
                            .frame(width: 297)
                            .padding(.top, 33)

                        VStack(alignment: .leading, spacing: 0) {
                            Text(languageManager.current == .arabic ? "رقم العضوية" : "Membership Number")
                                .font(.custom("ExpoArabic-Medium", size: 14))
                                .fontWeight(.medium)
                                .foregroundColor(brandBrown)
                                .padding(.bottom, 13)
                                .frame(maxWidth: .infinity, alignment: languageManager.current == .arabic ? .trailing : .leading)

                            TextField("", text: $membershipNumber)
                                .font(.custom("ExpoArabic-Medium", size: 14))
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                                .frame(height: 48)
                                .padding(.horizontal, 10)
                                .background(Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 7).stroke(brandBrown, lineWidth: 1))
                                .cornerRadius(7)
                                .keyboardType(.numberPad)
                                .frame(maxWidth: .infinity, alignment: languageManager.current == .arabic ? .trailing : .leading)
                        }
                        .frame(width: 285, alignment: languageManager.current == .arabic ? .trailing : .leading)
                        .frame(maxWidth: .infinity, alignment: languageManager.current == .arabic ? .trailing : .leading)
                        .padding(.horizontal, 44)
                        .padding(.top, 86)

                        HStack(spacing: 6) {
                            Button(action: { rememberMe.toggle() }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(brandBrown, lineWidth: 1)
                                        .frame(width: 18, height: 18)
                                    if rememberMe {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(brandBrown)
                                    }
                                }
                            }
                            Text(languageManager.current == .arabic ? "تذكرني" : "Remember Me")
                                .font(.custom("ExpoArabic-Medium", size: 12))
                                .fontWeight(.medium)
                                .foregroundColor(textGreen)
                        }
                        .frame(maxWidth: .infinity, alignment: languageManager.current == .arabic ? .trailing : .leading)
                        .padding(.horizontal, 44)
                        .padding(.top, 16)

                        // Login with Phone Number — brown bg, white text
                        Button(action: { dismiss() }) {
                            Text(languageManager.current == .arabic ? "تسجيل الدخول برقم الجوال" : "Login with Phone Number")
                                .font(.custom("ExpoArabic-Medium", size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(width: 287, height: 56)
                                .background(brandBrown)
                                .cornerRadius(13)
                        }
                        .padding(.top, 106)

                        // Next + FaceID — brown bg, white text
                        HStack(spacing: 18) {
                            NavigationLink(destination: OTPVerificationView(phoneNumber: "").environmentObject(languageManager)) {
                                Text(languageManager.current == .arabic ? "التالي" : "Next")
                                    .font(.custom("ExpoArabic-Medium", size: 16))
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(width: 205, height: 56)
                                    .background(brandBrown)
                                    .cornerRadius(13)
                            }

                            Button(action: {}) {
                                ZStack {
                                    Color.white
                                    FaceIDIcon()
                                        .frame(width: 39, height: 39)
                                }
                                .frame(width: 64, height: 56)
                                .cornerRadius(13)
                            }
                        }
                        .padding(.top, 15)

                        Spacer()
                    }
                }
                .padding(.top, 47)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationBarHidden(true)
    }
}

struct MembershipCardIcon: View {
    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 0, y: 166.023))
                path.addCurve(to: CGPoint(x: 11.0814, y: 177.105), control1: CGPoint(x: 0, y: 172.134), control2: CGPoint(x: 4.97096, y: 177.105))
                path.addLine(to: CGPoint(x: 136.527, y: 177.105))
                path.addCurve(to: CGPoint(x: 147.608, y: 166.023), control1: CGPoint(x: 142.637, y: 177.105), control2: CGPoint(x: 147.608, y: 172.134))
                path.addLine(to: CGPoint(x: 147.608, y: 88.6319))
                path.addCurve(to: CGPoint(x: 136.527, y: 77.5506), control1: CGPoint(x: 147.608, y: 82.5215), control2: CGPoint(x: 142.637, y: 77.5506))
                path.addLine(to: CGPoint(x: 110.735, y: 77.5506))
                path.addCurve(to: CGPoint(x: 73.6991, y: 43.1595), control1: CGPoint(x: 109.301, y: 58.3523), control2: CGPoint(x: 93.2577, y: 43.1595))
                path.addCurve(to: CGPoint(x: 36.6986, y: 77.5506), control1: CGPoint(x: 54.1586, y: 43.1595), control2: CGPoint(x: 38.1311, y: 58.3523))
                path.addLine(to: CGPoint(x: 11.0814, y: 77.5506))
                path.addCurve(to: CGPoint(x: 0, y: 88.6319), control1: CGPoint(x: 4.97096, y: 77.5506), control2: CGPoint(x: 0, y: 82.5215))
                path.addLine(to: CGPoint(x: 0, y: 166.023))
                path.closeSubpath()
                
                path.move(to: CGPoint(x: 136.527, y: 171.569))
                path.addLine(to: CGPoint(x: 11.0814, y: 171.569))
                path.addCurve(to: CGPoint(x: 5.53608, y: 166.023), control1: CGPoint(x: 8.02404, y: 169.08), control2: CGPoint(x: 5.53608, y: 169.081))
                path.addLine(to: CGPoint(x: 5.53608, y: 134.014))
                path.addLine(to: CGPoint(x: 142.072, y: 134.014))
                path.addLine(to: CGPoint(x: 142.072, y: 166.023))
                path.addCurve(to: CGPoint(x: 136.527, y: 171.569), control1: CGPoint(x: 142.072, y: 169.081), control2: CGPoint(x: 139.584, y: 171.569))
                path.closeSubpath()
                
                path.move(to: CGPoint(x: 48.3157, y: 107.375))
                path.addCurve(to: CGPoint(x: 73.6995, y: 117.478), control1: CGPoint(x: 54.964, y: 113.62), control2: CGPoint(x: 63.8798, y: 117.478))
                path.addCurve(to: CGPoint(x: 99.107, y: 107.375), control1: CGPoint(x: 83.528, y: 117.478), control2: CGPoint(x: 92.4523, y: 113.62))
                path.addLine(to: CGPoint(x: 141.723, y: 107.375))
                path.addLine(to: CGPoint(x: 141.723, y: 128.478))
                path.addLine(to: CGPoint(x: 5.7104, y: 128.478))
                path.addLine(to: CGPoint(x: 5.7104, y: 107.375))
                path.addLine(to: CGPoint(x: 48.3157, y: 107.375))
                path.closeSubpath()
                
                path.move(to: CGPoint(x: 142.072, y: 88.6319))
                path.addLine(to: CGPoint(x: 142.072, y: 101.839))
                path.addLine(to: CGPoint(x: 103.955, y: 101.839))
                path.addCurve(to: CGPoint(x: 110.736, y: 83.0866), control1: CGPoint(x: 107.792, y: 96.4668), control2: CGPoint(x: 110.222, y: 90.0456))
                path.addLine(to: CGPoint(x: 136.527, y: 83.0866))
                path.addCurve(to: CGPoint(x: 142.072, y: 88.6319), control1: CGPoint(x: 139.584, y: 85.5749), control2: CGPoint(x: 142.072, y: 85.5749))
                path.closeSubpath()
                
                path.move(to: CGPoint(x: 73.6991, y: 48.6956))
                path.addCurve(to: CGPoint(x: 105.34, y: 80.3365), control1: CGPoint(x: 91.146, y: 48.6956), control2: CGPoint(x: 105.34, y: 62.8892))
                path.addCurve(to: CGPoint(x: 73.6991, y: 111.942), control1: CGPoint(x: 105.34, y: 97.7646), control2: CGPoint(x: 91.1464, y: 111.942))
                path.addCurve(to: CGPoint(x: 42.0937, y: 80.3365), control1: CGPoint(x: 56.271, y: 111.942), control2: CGPoint(x: 42.0937, y: 97.7642))
                path.addCurve(to: CGPoint(x: 73.6991, y: 48.6956), control1: CGPoint(x: 42.0937, y: 62.8892), control2: CGPoint(x: 56.2714, y: 48.6956))
                path.closeSubpath()
                
                path.move(to: CGPoint(x: 11.0814, y: 83.0866))
                path.addLine(to: CGPoint(x: 36.6972, y: 83.0866))
                path.addCurve(to: CGPoint(x: 43.4716, y: 101.839), control1: CGPoint(x: 37.211, y: 90.0456), control2: CGPoint(x: 39.6387, y: 96.4668))
                path.addLine(to: CGPoint(x: 5.53608, y: 101.839))
                path.addLine(to: CGPoint(x: 5.53608, y: 88.6319))
                path.addCurve(to: CGPoint(x: 11.0814, y: 83.0866), control1: CGPoint(x: 5.53608, y: 85.5749), control2: CGPoint(x: 8.02439, y: 83.0866))
                path.closeSubpath()
            }
            .fill(Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0))
            
            Path { path in
                path.move(to: CGPoint(x: 38.1984, y: 152.243))
                path.addLine(to: CGPoint(x: 17.5673, y: 152.243))
                path.addCurve(to: CGPoint(x: 14.8434, y: 155.011), control1: CGPoint(x: 16.8409, y: 152.254), control2: CGPoint(x: 15.6386, y: 153.069))
                path.addCurve(to: CGPoint(x: 17.5673, y: 157.778), control1: CGPoint(x: 14.8434, y: 155.737), control2: CGPoint(x: 15.129, y: 156.434))
                path.addLine(to: CGPoint(x: 38.1984, y: 157.778))
                path.addCurve(to: CGPoint(x: 40.9223, y: 155.011), control1: CGPoint(x: 38.9248, y: 157.767), control2: CGPoint(x: 40.1271, y: 156.952))
                path.addCurve(to: CGPoint(x: 38.1984, y: 152.243), control1: CGPoint(x: 40.9223, y: 154.284), control2: CGPoint(x: 40.6367, y: 153.587))
                path.closeSubpath()
            }
            .fill(Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0))
            
            Path { path in
                path.move(to: CGPoint(x: 62.5192, y: 85.6067))
                path.addLine(to: CGPoint(x: 60.8246, y: 95.4905))
                path.addCurve(to: CGPoint(x: 64.8414, y: 98.4086), control1: CGPoint(x: 60.438, y: 97.756), control2: CGPoint(x: 62.8236, y: 99.4716))
                path.addLine(to: CGPoint(x: 73.7168, y: 93.7431))
                path.addLine(to: CGPoint(x: 82.5922, y: 98.4086))
                path.addCurve(to: CGPoint(x: 86.609, y: 95.4905), control1: CGPoint(x: 84.6161, y: 99.468), control2: CGPoint(x: 86.9956, y: 97.7567))
                path.addLine(to: CGPoint(x: 84.9144, y: 85.6067))
                path.addLine(to: CGPoint(x: 92.0938, y: 78.6084))
                path.addCurve(to: CGPoint(x: 90.5596, y: 73.8862), control1: CGPoint(x: 93.7353, y: 77.008), control2: CGPoint(x: 92.8275, y: 74.215))
                path.addLine(to: CGPoint(x: 80.6368, y: 72.4456))
                path.addLine(to: CGPoint(x: 76.1998, y: 63.4539))
                path.addCurve(to: CGPoint(x: 71.2342, y: 63.4539), control1: CGPoint(x: 75.2673, y: 61.5644), control2: CGPoint(x: 72.1667, y: 61.5644))
                path.addLine(to: CGPoint(x: 66.7971, y: 72.4456))
                path.addLine(to: CGPoint(x: 56.8744, y: 73.8862))
                path.addCurve(to: CGPoint(x: 55.3402, y: 78.6084), control1: CGPoint(x: 54.6078, y: 74.215), control2: CGPoint(x: 53.6983, y: 77.0077))
                path.addLine(to: CGPoint(x: 62.5192, y: 85.6067))
                path.closeSubpath()
                
                path.move(to: CGPoint(x: 69.0325, y: 77.7152))
                path.addCurve(to: CGPoint(x: 71.1179, y: 76.2002), control1: CGPoint(x: 69.4768, y: 77.6505), control2: CGPoint(x: 69.8988, y: 77.4788))
                path.addLine(to: CGPoint(x: 73.7168, y: 70.9334))
                path.addLine(to: CGPoint(x: 76.3157, y: 76.2002))
                path.addCurve(to: CGPoint(x: 78.4011, y: 77.7152), control1: CGPoint(x: 76.5146, y: 76.6028), control2: CGPoint(x: 76.8083, y: 76.951))
                path.addLine(to: CGPoint(x: 84.2128, y: 78.5585))
                path.addLine(to: CGPoint(x: 80.0083, y: 82.6578))
                path.addCurve(to: CGPoint(x: 79.2107, y: 85.1082), control1: CGPoint(x: 79.687, y: 82.9712), control2: CGPoint(x: 79.4465, y: 83.358))
                path.addLine(to: CGPoint(x: 80.2042, y: 90.8994))
                path.addLine(to: CGPoint(x: 75.0047, y: 88.1652))
                path.addCurve(to: CGPoint(x: 72.4285, y: 88.1652), control1: CGPoint(x: 74.6074, y: 87.9566), control2: CGPoint(x: 74.1654, y: 87.8475))
                path.addLine(to: CGPoint(x: 67.229, y: 90.8994))
                path.addLine(to: CGPoint(x: 68.2225, y: 85.1082))
                path.addCurve(to: CGPoint(x: 67.425, y: 82.6578), control1: CGPoint(x: 68.2979, y: 84.6657), control2: CGPoint(x: 68.2647, y: 84.2116))
                path.addLine(to: CGPoint(x: 63.2204, y: 78.5585))
                path.addLine(to: CGPoint(x: 69.0325, y: 77.7152))
                path.closeSubpath()
            }
            .fill(Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0))
            
            Path { path in
                path.move(to: CGPoint(x: 71.3327, y: 2.72393))
                path.addLine(to: CGPoint(x: 71.3327, y: 26.5799))
                path.addCurve(to: CGPoint(x: 74.1005, y: 29.3038), control1: CGPoint(x: 71.3443, y: 27.3063), control2: CGPoint(x: 71.641, y: 27.9991))
                path.addCurve(to: CGPoint(x: 76.8684, y: 26.5799), control1: CGPoint(x: 74.827, y: 29.3038), control2: CGPoint(x: 75.5244, y: 29.0182))
                path.addLine(to: CGPoint(x: 76.8684, y: 2.72393))
                path.addCurve(to: CGPoint(x: 74.1005, y: 0), control1: CGPoint(x: 76.8568, y: 1.99752), control2: CGPoint(x: 76.56, y: 1.30479))
                path.addCurve(to: CGPoint(x: 71.3327, y: 2.72393), control1: CGPoint(x: 73.374, y: 0), control2: CGPoint(x: 72.6766, y: 0.285604))
                path.closeSubpath()
            }
            .fill(Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0))
            
            Path { path in
                path.move(to: CGPoint(x: 119.236, y: 13.5201))
                path.addLine(to: CGPoint(x: 107.746, y: 34.4257))
                path.addCurve(to: CGPoint(x: 108.839, y: 38.1842), control1: CGPoint(x: 107.571, y: 34.7443), control2: CGPoint(x: 107.46, y: 35.0942))
                path.addCurve(to: CGPoint(x: 112.598, y: 37.0908), control1: CGPoint(x: 110.16, y: 38.912), control2: CGPoint(x: 111.854, y: 38.4454))
                path.addLine(to: CGPoint(x: 124.088, y: 16.1852))
                path.addCurve(to: CGPoint(x: 122.995, y: 12.4267), control1: CGPoint(x: 124.263, y: 15.8666), control2: CGPoint(x: 124.374, y: 15.5167))
                path.addCurve(to: CGPoint(x: 119.236, y: 13.5201), control1: CGPoint(x: 121.654, y: 11.6872), control2: CGPoint(x: 119.971, y: 12.1794))
                path.closeSubpath()
            }
            .fill(Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0))
            
            Path { path in
                path.move(to: CGPoint(x: 24.4292, y: 13.0322))
                path.addCurve(to: CGPoint(x: 23.3709, y: 16.8017), control1: CGPoint(x: 23.7892, y: 13.3919), control2: CGPoint(x: 23.3181, y: 13.991))
                path.addLine(to: CGPoint(x: 35.0521, y: 37.6003))
                path.addCurve(to: CGPoint(x: 38.8216, y: 38.6587), control1: CGPoint(x: 35.8025, y: 38.9357), control2: CGPoint(x: 37.4937, y: 39.4041))
                path.addCurve(to: CGPoint(x: 39.8799, y: 34.8892), control1: CGPoint(x: 39.4617, y: 38.299), control2: CGPoint(x: 39.9327, y: 37.6999))
                path.addLine(to: CGPoint(x: 28.1987, y: 14.0905))
                path.addCurve(to: CGPoint(x: 24.4292, y: 13.0322), control1: CGPoint(x: 27.4497, y: 12.759), control2: CGPoint(x: 25.7643, y: 12.286))
                path.closeSubpath()
            }
            .fill(Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0))
        }
    }
}

#Preview {
    MembershipLoginView()
}
