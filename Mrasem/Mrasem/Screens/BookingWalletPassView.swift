import SwiftUI

/// In-app ticket styled like an Apple Wallet generic pass (Figma 1202:12779).
struct BookingWalletPassView: View {
    let guestName: String
    let placeName: String
    let heroImageName: String
    let dateString: String
    let ticketCode: String

    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)

    private var qrPayload: String {
        BookingTicketCode.qrPayload(ticketCode: ticketCode, place: placeName)
    }

    var body: some View {
        VStack(spacing: 0) {
            headerArea
            stripImage
            fieldsArea
            qrArea
        }
        .frame(width: 320)
        .background(brandBrown)
        .clipShape(RoundedRectangle(cornerRadius: 11))
        .overlay(
            RoundedRectangle(cornerRadius: 11)
                .stroke(Color.black.opacity(0.16), lineWidth: 1)
        )
    }

    private var headerArea: some View {
        ZStack {
            brandBrown
            VStack(spacing: 2) {
                Image("mrasem-logo")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(height: 36)
                Text("Marasem Exclusively Saudi — Est 2018")
                    .font(.custom("ExpoArabic-Light", size: 9))
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(.vertical, 10)
        }
        .frame(height: 68)
    }

    private var stripImage: some View {
        Image(heroImageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 320, height: 123)
            .clipped()
    }

    private var fieldsArea: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("NAME")
                    .font(.custom("ExpoArabic-Medium", size: 11))
                    .tracking(0.5)
                    .foregroundColor(.white.opacity(0.9))
                Text(guestName)
                    .font(.custom("ExpoArabic-Light", size: 28))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("PLACE")
                        .font(.custom("ExpoArabic-Medium", size: 11))
                        .foregroundColor(.white.opacity(0.9))
                    Text(placeName)
                        .font(.custom("ExpoArabic-Medium", size: 17))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("DATE")
                        .font(.custom("ExpoArabic-Medium", size: 11))
                        .foregroundColor(.white.opacity(0.9))
                    Text(dateString)
                        .font(.custom("ExpoArabic-Medium", size: 17))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(brandBrown)
    }

    private var qrArea: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white)
                    .frame(width: 150, height: 176)
                VStack(spacing: 8) {
                    Spacer(minLength: 8)
                    BookingQRCodeView(payload: qrPayload, size: 118)
                    Text(ticketCode)
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                        .foregroundColor(.black)
                        .padding(.bottom, 10)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
        .padding(.bottom, 16)
        .background(brandBrown)
    }
}

#Preview {
    BookingWalletPassView(
        guestName: "Abdullah",
        placeName: "Myazu Restaurant",
        heroImageName: "restaurant-myazu",
        dateString: "Feb 10",
        ticketCode: "11223344556677"
    )
    .padding()
    .background(Color.gray.opacity(0.3))
}
