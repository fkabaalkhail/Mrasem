import SwiftUI

struct PhoneLoginView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var countryCode: String = "+966"
    @State private var phoneNumber: String = ""
    @State private var rememberMe: Bool = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text(languageManager.current == .arabic ? "تسجيل الدخول" : "Login")
                    .font(.custom("ExpoArabic-Medium", size: 20))
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .padding(.top, 70)
                
                ZStack(alignment: .top) {
                    Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)
                        .clipShape(RoundedCorner(radius: 50, corners: [.topLeft, .topRight]))
                    
                    VStack(spacing: 0) {
                        PhoneIcon()
                            .frame(width: 94, height: 166)
                            .padding(.top, 45)
                        
                        Text(languageManager.current == .arabic ? "أدخل رقم جوالك" : "Enter your Mobile Number")
                            .font(.custom("ExpoArabic-Medium", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(width: 297)
                            .padding(.top, 33)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text(languageManager.current == .arabic ? "رقم الجوال" : "Phone Number")
                                .font(.custom("ExpoArabic-Medium", size: 14))
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.bottom, 13)
                                .frame(maxWidth: .infinity, alignment: languageManager.current == .arabic ? .trailing : .leading)
                            
                            HStack(spacing: 12) {
                                TextField("", text: $countryCode)
                                    .font(.custom("ExpoArabic-Medium", size: 14))
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(red: 0x6A / 255.0, green: 0x6A / 255.0, blue: 0x6A / 255.0))
                                    .frame(width: 48, height: 48)
                                    .background(Color.white)
                                    .cornerRadius(7)
                                    .multilineTextAlignment(.center)
                                
                                TextField("", text: $phoneNumber)
                                    .font(.custom("ExpoArabic-Medium", size: 14))
                                    .fontWeight(.medium)
                                    .foregroundColor(.black)
                                    .frame(height: 48)
                                    .padding(.horizontal, 10)
                                    .background(Color.white)
                                    .cornerRadius(7)
                                    .keyboardType(.numberPad)
                            }
                            .frame(maxWidth: .infinity, alignment: languageManager.current == .arabic ? .trailing : .leading)
                        }
                        // Fixed content width like Figma, then align within full width
                        .frame(width: 287, alignment: languageManager.current == .arabic ? .trailing : .leading)
                        .frame(maxWidth: .infinity, alignment: languageManager.current == .arabic ? .trailing : .leading)
                        .padding(.horizontal, 44)
                        .padding(.top, 86)
                        
                        HStack(spacing: 6) {
                            Button(action: {
                                rememberMe.toggle()
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.white, lineWidth: 1)
                                        .frame(width: 18, height: 18)
                                    
                                    if rememberMe {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            
                            Text(languageManager.current == .arabic ? "تذكرني" : "Remember Me")
                                .font(.custom("ExpoArabic-Medium", size: 12))
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: languageManager.current == .arabic ? .trailing : .leading)
                        .padding(.horizontal, 44)
                        .padding(.top, 16)
                        
                        NavigationLink(destination: MembershipLoginView().environmentObject(languageManager)) {
                            Text(languageManager.current == .arabic ? "تسجيل الدخول للأعضاء" : "Member Login")
                                .font(.custom("ExpoArabic-Medium", size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                                .frame(width: 287, height: 56)
                                .background(Color.white)
                                .cornerRadius(13)
                        }
                        .padding(.top, 106)
                        
                        HStack(spacing: 18) {
                            NavigationLink(destination: CategorySelectionView().environmentObject(languageManager)) {
                                Text(languageManager.current == .arabic ? "التالي" : "Next")
                                    .font(.custom("ExpoArabic-Medium", size: 16))
                                    .fontWeight(.medium)
                                    .foregroundColor(.black)
                                    .frame(width: 205, height: 56)
                                    .background(Color.white)
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
    }
}

struct PhoneIcon: View {
    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 80.2333, y: 0))
                path.addLine(to: CGPoint(x: 13.8333, y: 0))
                path.addCurve(to: CGPoint(x: 0, y: 13.8333), control1: CGPoint(x: 6.19733, y: 0), control2: CGPoint(x: 0, y: 6.19733))
                path.addLine(to: CGPoint(x: 0, y: 152.167))
                path.addCurve(to: CGPoint(x: 13.8333, y: 166), control1: CGPoint(x: 0, y: 159.803), control2: CGPoint(x: 6.19733, y: 166))
                path.addLine(to: CGPoint(x: 80.2333, y: 166))
                path.addCurve(to: CGPoint(x: 94.0667, y: 152.167), control1: CGPoint(x: 87.8693, y: 166), control2: CGPoint(x: 94.0667, y: 159.803))
                path.addLine(to: CGPoint(x: 94.0667, y: 13.8333))
                path.addCurve(to: CGPoint(x: 80.2333, y: 0), control1: CGPoint(x: 94.0667, y: 6.19733), control2: CGPoint(x: 87.8693, y: 0))
                path.closeSubpath()
                
                path.move(to: CGPoint(x: 88.5333, y: 152.167))
                path.addCurve(to: CGPoint(x: 80.2333, y: 160.467), control1: CGPoint(x: 88.5333, y: 156.732), control2: CGPoint(x: 84.7983, y: 160.467))
                path.addLine(to: CGPoint(x: 13.8333, y: 160.467))
                path.addCurve(to: CGPoint(x: 5.53333, y: 152.167), control1: CGPoint(x: 9.26833, y: 160.467), control2: CGPoint(x: 5.53333, y: 156.732))
                path.addLine(to: CGPoint(x: 5.53333, y: 13.8333))
                path.addCurve(to: CGPoint(x: 13.8333, y: 5.53333), control1: CGPoint(x: 5.53333, y: 9.26833), control2: CGPoint(x: 9.26833, y: 5.53333))
                path.addLine(to: CGPoint(x: 25.9513, y: 5.53333))
                path.addLine(to: CGPoint(x: 29.1883, y: 12.0073))
                path.addCurve(to: CGPoint(x: 36.6307, y: 16.6), control1: CGPoint(x: 29.8764, y: 13.3913), control2: CGPoint(x: 30.9382, y: 14.555))
                path.addLine(to: CGPoint(x: 57.436, y: 16.6))
                path.addCurve(to: CGPoint(x: 64.8783, y: 12.0073), control1: CGPoint(x: 60.6177, y: 16.6), control2: CGPoint(x: 63.4673, y: 14.8293))
                path.addLine(to: CGPoint(x: 68.1153, y: 5.53333))
                path.addLine(to: CGPoint(x: 80.2333, y: 5.53333))
                path.addCurve(to: CGPoint(x: 88.5333, y: 13.8333), control1: CGPoint(x: 84.7983, y: 5.53333), control2: CGPoint(x: 88.5333, y: 9.26833))
                path.addLine(to: CGPoint(x: 88.5333, y: 152.167))
                path.closeSubpath()
            }
            .fill(Color.white)
            
            Path { path in
                path.move(to: CGPoint(x: 60.8667, y: 149.4))
                path.addLine(to: CGPoint(x: 33.2, y: 149.4))
                path.addCurve(to: CGPoint(x: 30.4333, y: 152.167), control1: CGPoint(x: 31.6783, y: 149.4), control2: CGPoint(x: 30.4333, y: 150.645))
                path.addCurve(to: CGPoint(x: 33.2, y: 154.933), control1: CGPoint(x: 30.4333, y: 153.688), control2: CGPoint(x: 31.6783, y: 154.933))
                path.addLine(to: CGPoint(x: 60.8667, y: 154.933))
                path.addCurve(to: CGPoint(x: 63.6334, y: 152.167), control1: CGPoint(x: 62.3883, y: 154.933), control2: CGPoint(x: 63.6334, y: 153.688))
                path.addCurve(to: CGPoint(x: 60.8667, y: 149.4), control1: CGPoint(x: 63.6334, y: 150.645), control2: CGPoint(x: 62.3883, y: 149.4))
                path.closeSubpath()
            }
            .fill(Color.white)
        }
    }
}

struct FaceIDIcon: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 1.44613, y: 12.2722))
            path.addCurve(to: CGPoint(x: 1.28844, y: 12.2638), control1: CGPoint(x: 1.39432, y: 12.2722), control2: CGPoint(x: 1.34176, y: 12.2722))
            path.addCurve(to: CGPoint(x: 0.00866129, y: 10.6671), control1: CGPoint(x: 0.907046, y: 12.2217), control2: CGPoint(x: 0.557992, y: 12.0298))
            path.addCurve(to: CGPoint(x: 0.101597, y: 8.99123), control1: CGPoint(x: -0.0332422, y: 11.0485), control2: CGPoint(x: 0.00866129, y: 10.6671))
            path.addCurve(to: CGPoint(x: 0.352221, y: 8.15709), control1: CGPoint(x: 0.101597, y: 9.8109), control2: CGPoint(x: 0.213578, y: 8.99123))
            path.addLine(to: CGPoint(x: 0.352221, y: 8.14338))
            path.addCurve(to: CGPoint(x: 8.14972, y: 0.351972), control1: CGPoint(x: 1.02182, y: 4.3688), control2: CGPoint(x: 4.37133, y: 1.01928))
            path.addLine(to: CGPoint(x: 8.16419, y: 0.351972))
            path.addCurve(to: CGPoint(x: 10.678, y: 0.00841267), control1: CGPoint(x: 8.99867, y: 0.213304), control2: CGPoint(x: 9.83696, y: 0.0987363))
            path.addCurve(to: CGPoint(x: 12.2728, y: 1.29162), control1: CGPoint(x: 11.0597, y: -0.0329034), control2: CGPoint(x: 11.4421, y: 0.07908))
            path.addCurve(to: CGPoint(x: 10.9896, y: 2.88639), control1: CGPoint(x: 12.3141, y: 1.67326), control2: CGPoint(x: 12.2021, y: 2.05569))
            path.addCurve(to: CGPoint(x: 8.6502, y: 3.20633), control1: CGPoint(x: 11.7208, y: 2.65384), control2: CGPoint(x: 11.3713, y: 2.84507))
            path.addCurve(to: CGPoint(x: 5.13234, y: 5.12981), control1: CGPoint(x: 7.39937, y: 3.42496), control2: CGPoint(x: 6.15312, y: 4.10903))
            path.addCurve(to: CGPoint(x: 3.20658, y: 8.64005), control1: CGPoint(x: 4.11157, y: 6.15058), control2: CGPoint(x: 3.42673, y: 7.39684))
            path.addCurve(to: CGPoint(x: 2.88664, y: 10.9787), control1: CGPoint(x: 3.07743, y: 9.41636), control2: CGPoint(x: 2.97074, y: 10.1962))
            path.addCurve(to: CGPoint(x: 1.44613, y: 12.2722), control1: CGPoint(x: 2.84863, y: 11.3341), control2: CGPoint(x: 2.68045, y: 11.6629))
            path.closeSubpath()
            
            path.move(to: CGPoint(x: 37.5541, y: 12.2844))
            path.addCurve(to: CGPoint(x: 36.1167, y: 10.9932), control1: CGPoint(x: 37.1976, y: 12.284), control2: CGPoint(x: 36.8537, y: 12.152))
            path.addCurve(to: CGPoint(x: 35.7967, y: 8.65453), control1: CGPoint(x: 36.1551, y: 11.3477), control2: CGPoint(x: 36.0326, y: 10.2107))
            path.addCurve(to: CGPoint(x: 33.8679, y: 5.14352), control1: CGPoint(x: 35.5735, y: 7.41055), control2: CGPoint(x: 34.8879, y: 6.16429))
            path.addCurve(to: CGPoint(x: 30.3577, y: 3.21776), control1: CGPoint(x: 32.8479, y: 4.12274), control2: CGPoint(x: 31.6009, y: 3.43563))
            path.addCurve(to: CGPoint(x: 28.0183, y: 2.89781), control1: CGPoint(x: 29.5807, y: 3.08826), control2: CGPoint(x: 28.8158, y: 2.98389))
            path.addCurve(to: CGPoint(x: 26.7351, y: 1.30304), control1: CGPoint(x: 27.6366, y: 2.8565), control2: CGPoint(x: 27.287, y: 2.66527))
            path.addCurve(to: CGPoint(x: 28.3298, y: 0.0198393), control1: CGPoint(x: 26.8057, y: 2.06711), control2: CGPoint(x: 26.6937, y: 1.68469))
            path.addCurve(to: CGPoint(x: 30.8399, y: 0.363399), control1: CGPoint(x: 27.9482, y: -0.0214768), control2: CGPoint(x: 28.3298, y: 0.0198393))
            path.addLine(to: CGPoint(x: 30.8543, y: 0.363399))
            path.addCurve(to: CGPoint(x: 38.6457, y: 8.15861), control1: CGPoint(x: 34.6289, y: 1.033), control2: CGPoint(x: 37.9784, y: 4.38251))
            path.addLine(to: CGPoint(x: 38.6457, y: 8.17309))
            path.addCurve(to: CGPoint(x: 38.9893, y: 10.6869), control1: CGPoint(x: 38.7844, y: 9.0057), control2: CGPoint(x: 38.8964, y: 9.82689))
            path.addCurve(to: CGPoint(x: 37.7065, y: 12.276), control1: CGPoint(x: 39.029, y: 11.0676), control2: CGPoint(x: 38.9164, y: 11.4485))
            path.addCurve(to: CGPoint(x: 37.5541, y: 12.2844), control1: CGPoint(x: 38.4355, y: 12.0441), control2: CGPoint(x: 38.087, y: 12.2345))
            path.closeSubpath()
            
            path.move(to: CGPoint(x: 28.1721, y: 39.0211))
            path.addCurve(to: CGPoint(x: 26.7299, y: 37.65), control1: CGPoint(x: 27.802, y: 39.0203), control2: CGPoint(x: 27.4463, y: 38.8777))
            path.addCurve(to: CGPoint(x: 28.0198, y: 36.1347), control1: CGPoint(x: 27.0494, y: 38.0196), control2: CGPoint(x: 26.7104, y: 37.2804))
            path.addCurve(to: CGPoint(x: 30.3584, y: 35.8148), control1: CGPoint(x: 26.8332, y: 36.9173), control2: CGPoint(x: 27.313, y: 36.3537))
            path.addCurve(to: CGPoint(x: 33.8694, y: 33.8882), control1: CGPoint(x: 29.5837, y: 35.9435), control2: CGPoint(x: 28.8189, y: 36.0479))
            path.addCurve(to: CGPoint(x: 35.7937, y: 30.378), control1: CGPoint(x: 34.8902, y: 32.8667), control2: CGPoint(x: 35.5735, y: 31.6212))
            path.addCurve(to: CGPoint(x: 36.1136, y: 28.0393), control1: CGPoint(x: 35.9224, y: 29.6025), control2: CGPoint(x: 36.0275, y: 28.8377))
            path.addCurve(to: CGPoint(x: 37.7084, y: 26.7561), control1: CGPoint(x: 36.1341, y: 27.8504), control2: CGPoint(x: 36.1916, y: 27.6673))
            path.addCurve(to: CGPoint(x: 38.9916, y: 28.3509), control1: CGPoint(x: 38.012, y: 27.1619), control2: CGPoint(x: 38.9951, y: 27.9708))
            path.addCurve(to: CGPoint(x: 38.648, y: 30.8609), control1: CGPoint(x: 38.8987, y: 29.2071), control2: CGPoint(x: 38.7867, y: 30.0268))
            path.addLine(to: CGPoint(x: 38.648, y: 30.8754))
            path.addCurve(to: CGPoint(x: 30.8566, y: 38.6661), control1: CGPoint(x: 37.9807, y: 34.65), control2: CGPoint(x: 34.6312, y: 37.9995))
            path.addLine(to: CGPoint(x: 30.8422, y: 38.6661))
            path.addCurve(to: CGPoint(x: 28.3321, y: 39.0096), control1: CGPoint(x: 30.0103, y: 38.8039), control2: CGPoint(x: 29.1891, y: 38.9167))
            path.addCurve(to: CGPoint(x: 28.1721, y: 39.0211), control1: CGPoint(x: 28.279, y: 39.0162), control2: CGPoint(x: 28.2256, y: 39.02))
            path.closeSubpath()
            
            path.move(to: CGPoint(x: 10.8281, y: 39.0104))
            path.addCurve(to: CGPoint(x: 10.6704, y: 39.0012), control1: CGPoint(x: 10.7754, y: 39.0104), control2: CGPoint(x: 10.7228, y: 39.0073))
            path.addCurve(to: CGPoint(x: 8.16039, y: 38.6577), control1: CGPoint(x: 9.81343, y: 38.9083), control2: CGPoint(x: 8.99453, y: 38.7963))
            path.addLine(to: CGPoint(x: 8.14591, y: 38.6577))
            path.addCurve(to: CGPoint(x: 0.354506, y: 30.8594), control1: CGPoint(x: 4.37133, y: 37.985), control2: CGPoint(x: 1.02182, y: 34.6355))
            path.addLine(to: CGPoint(x: 0.354506, y: 30.8449))
            path.addCurve(to: CGPoint(x: 0.00866129, y: 28.3364), control1: CGPoint(x: 0.213578, y: 30.0139), control2: CGPoint(x: 0.101597, y: 29.1934))
            path.addCurve(to: CGPoint(x: 1.29187, y: 26.7417), control1: CGPoint(x: -0.0326548, y: 27.9548), control2: CGPoint(x: 0.0793286, y: 27.5724))
            path.addCurve(to: CGPoint(x: 2.88664, y: 28.0249), control1: CGPoint(x: 0.910223, y: 26.783), control2: CGPoint(x: 1.67351, y: 26.7003))
            path.addCurve(to: CGPoint(x: 3.20658, y: 30.3643), control1: CGPoint(x: 2.65409, y: 27.6432), control2: CGPoint(x: 2.97272, y: 28.824))
            path.addCurve(to: CGPoint(x: 5.13234, y: 33.8745), control1: CGPoint(x: 3.42673, y: 31.6075), control2: CGPoint(x: 4.11233, y: 32.8537))
            path.addCurve(to: CGPoint(x: 8.64259, y: 35.8003), control1: CGPoint(x: 6.15235, y: 34.8953), control2: CGPoint(x: 7.39937, y: 35.5824))
            path.addCurve(to: CGPoint(x: 10.982, y: 36.1202), control1: CGPoint(x: 9.41914, y: 35.9295), control2: CGPoint(x: 10.1993, y: 36.0362))
            path.addCurve(to: CGPoint(x: 12.2791, y: 37.6362), control1: CGPoint(x: 11.3514, y: 36.1583), control2: CGPoint(x: 11.6921, y: 36.3368))
            path.addCurve(to: CGPoint(x: 10.8296, y: 39.0073), control1: CGPoint(x: 12.2987, y: 37.2654), control2: CGPoint(x: 12.2595, y: 38.0071))
            path.addLine(to: CGPoint(x: 10.8281, y: 39.0104))
            path.closeSubpath()
            
            path.move(to: CGPoint(x: 19.5047, y: 29.2247))
            path.addCurve(to: CGPoint(x: 12.5474, y: 26.8632), control1: CGPoint(x: 16.9888, y: 29.2255), control2: CGPoint(x: 14.543, y: 28.3954))
            path.addCurve(to: CGPoint(x: 11.9934, y: 25.9039), control1: CGPoint(x: 12.3966, y: 26.7475), control2: CGPoint(x: 12.2701, y: 26.6032))
            path.addCurve(to: CGPoint(x: 12.0303, y: 25.3403), control1: CGPoint(x: 12.08, y: 26.274), control2: CGPoint(x: 11.9686, y: 25.7154))
            path.addCurve(to: CGPoint(x: 12.28, y: 24.8338), control1: CGPoint(x: 12.0795, y: 25.1567), control2: CGPoint(x: 12.1644, y: 24.9846))
            path.addCurve(to: CGPoint(x: 13.2394, y: 24.2798), control1: CGPoint(x: 12.5137, y: 24.5292), control2: CGPoint(x: 12.8588, y: 24.33))
            path.addCurve(to: CGPoint(x: 14.3094, y: 24.5664), control1: CGPoint(x: 13.4278, y: 24.255), control2: CGPoint(x: 13.6193, y: 24.2675))
            path.addCurve(to: CGPoint(x: 19.5024, y: 26.3271), control1: CGPoint(x: 15.7998, y: 25.7083), control2: CGPoint(x: 17.6249, y: 26.3271))
            path.addCurve(to: CGPoint(x: 24.6954, y: 24.5664), control1: CGPoint(x: 21.3799, y: 26.3271), control2: CGPoint(x: 23.2051, y: 25.7083))
            path.addCurve(to: CGPoint(x: 26.7095, y: 24.844), control1: CGPoint(x: 25.0002, y: 24.3387), control2: CGPoint(x: 25.3825, y: 24.2401))
            path.addCurve(to: CGPoint(x: 26.4589, y: 26.8616), control1: CGPoint(x: 26.9413, y: 25.1458), control2: CGPoint(x: 27.045, y: 25.5266))
            path.addCurve(to: CGPoint(x: 19.5047, y: 29.2247), control1: CGPoint(x: 26.1575, y: 26.6258), control2: CGPoint(x: 24.4651, y: 28.395))
            path.closeSubpath()
            
            path.move(to: CGPoint(x: 12.555, y: 15.1601))
            path.addCurve(to: CGPoint(x: 11.5316, y: 14.7361), control1: CGPoint(x: 12.1712, y: 15.1601), control2: CGPoint(x: 11.803, y: 15.0076))
            path.addCurve(to: CGPoint(x: 11.1077, y: 13.7127), control1: CGPoint(x: 11.2602, y: 14.4647), control2: CGPoint(x: 11.1077, y: 14.0966))
            path.addLine(to: CGPoint(x: 11.1077, y: 11.5988))
            path.addCurve(to: CGPoint(x: 11.5316, y: 10.5753), control1: CGPoint(x: 11.1077, y: 11.2149), control2: CGPoint(x: 11.2602, y: 10.8468))
            path.addCurve(to: CGPoint(x: 12.555, y: 10.1514), control1: CGPoint(x: 11.803, y: 10.3039), control2: CGPoint(x: 12.1712, y: 10.1514))
            path.addCurve(to: CGPoint(x: 13.5785, y: 10.5753), control1: CGPoint(x: 12.9389, y: 10.1514), control2: CGPoint(x: 13.3071, y: 10.3039))
            path.addCurve(to: CGPoint(x: 14.0024, y: 11.5988), control1: CGPoint(x: 13.8499, y: 10.8468), control2: CGPoint(x: 14.0024, y: 11.2149))
            path.addLine(to: CGPoint(x: 14.0024, y: 13.7127))
            path.addCurve(to: CGPoint(x: 13.5785, y: 14.7361), control1: CGPoint(x: 14.0024, y: 14.0966), control2: CGPoint(x: 13.8499, y: 14.4647))
            path.addCurve(to: CGPoint(x: 12.555, y: 15.1601), control1: CGPoint(x: 13.3071, y: 15.0076), control2: CGPoint(x: 12.9389, y: 15.1601))
            path.closeSubpath()
            
            path.move(to: CGPoint(x: 26.4452, y: 15.1601))
            path.addCurve(to: CGPoint(x: 25.4218, y: 14.7361), control1: CGPoint(x: 26.0613, y: 15.1601), control2: CGPoint(x: 25.6932, y: 15.0076))
            path.addCurve(to: CGPoint(x: 24.9978, y: 13.7127), control1: CGPoint(x: 25.1503, y: 14.4647), control2: CGPoint(x: 24.9978, y: 14.0966))
            path.addLine(to: CGPoint(x: 24.9978, y: 11.5988))
            path.addCurve(to: CGPoint(x: 25.4218, y: 10.5753), control1: CGPoint(x: 24.9978, y: 11.2149), control2: CGPoint(x: 25.1503, y: 10.8468))
            path.addCurve(to: CGPoint(x: 26.4452, y: 10.1514), control1: CGPoint(x: 25.6932, y: 10.3039), control2: CGPoint(x: 26.0613, y: 10.1514))
            path.addCurve(to: CGPoint(x: 27.4686, y: 10.5753), control1: CGPoint(x: 26.8291, y: 10.1514), control2: CGPoint(x: 27.1972, y: 10.3039))
            path.addCurve(to: CGPoint(x: 27.8926, y: 11.5988), control1: CGPoint(x: 27.7401, y: 10.8468), control2: CGPoint(x: 27.8926, y: 11.2149))
            path.addLine(to: CGPoint(x: 27.8926, y: 13.7127))
            path.addCurve(to: CGPoint(x: 27.4686, y: 14.7361), control1: CGPoint(x: 27.8926, y: 14.0966), control2: CGPoint(x: 27.7401, y: 14.4647))
            path.addCurve(to: CGPoint(x: 26.4452, y: 15.1601), control1: CGPoint(x: 27.1972, y: 15.0076), control2: CGPoint(x: 26.8291, y: 15.1601))
            path.closeSubpath()
            
            path.move(to: CGPoint(x: 19.5001, y: 21.8332))
            path.addCurve(to: CGPoint(x: 18.6827, y: 21.581), control1: CGPoint(x: 19.2085, y: 21.8334), control2: CGPoint(x: 18.9235, y: 21.7455))
            path.addCurve(to: CGPoint(x: 18.1504, y: 20.9114), control1: CGPoint(x: 18.4418, y: 21.4165), control2: CGPoint(x: 18.2563, y: 21.1831))
            path.addCurve(to: CGPoint(x: 18.0892, y: 20.0581), control1: CGPoint(x: 18.0445, y: 20.6396), control2: CGPoint(x: 18.0232, y: 20.3422))
            path.addCurve(to: CGPoint(x: 18.5205, y: 19.3193), control1: CGPoint(x: 18.1553, y: 19.774), control2: CGPoint(x: 18.3056, y: 19.5165))
            path.addLine(to: CGPoint(x: 19.5154, y: 18.4052))
            path.addLine(to: CGPoint(x: 18.1785, y: 15.4145))
            path.addCurve(to: CGPoint(x: 18.1524, y: 14.3107), control1: CGPoint(x: 18.0243, y: 15.0645), control2: CGPoint(x: 18.0149, y: 14.6676))
            path.addCurve(to: CGPoint(x: 18.9122, y: 13.5097), control1: CGPoint(x: 18.2899, y: 13.9538), control2: CGPoint(x: 18.5631, y: 13.6658))
            path.addCurve(to: CGPoint(x: 20.0159, y: 13.4776), control1: CGPoint(x: 19.2614, y: 13.3536), control2: CGPoint(x: 19.6582, y: 13.342))
            path.addCurve(to: CGPoint(x: 20.821, y: 14.233), control1: CGPoint(x: 20.3735, y: 13.6131), control2: CGPoint(x: 20.663, y: 13.8847))
            path.addLine(to: CGPoint(x: 22.5838, y: 18.1759))
            path.addCurve(to: CGPoint(x: 22.6797, y: 19.0597), control1: CGPoint(x: 22.7077, y: 18.4531), control2: CGPoint(x: 22.7412, y: 18.7623))
            path.addCurve(to: CGPoint(x: 22.241, y: 19.8328), control1: CGPoint(x: 22.6182, y: 19.357), control2: CGPoint(x: 22.4647, y: 19.6275))
            path.addLine(to: CGPoint(x: 20.4782, y: 21.4508))
            path.addCurve(to: CGPoint(x: 19.5001, y: 21.8332), control1: CGPoint(x: 20.2116, y: 21.6962), control2: CGPoint(x: 19.8625, y: 21.8327))
            path.closeSubpath()
        }
        .fill(Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0))
    }
}

#Preview {
    PhoneLoginView()
}
