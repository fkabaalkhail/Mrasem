import CoreImage
import SwiftUI
import UIKit

enum BookingQRImage {
    /// Shared context avoids extra CI setup on each QR. (Simulator may still log `CIPortraitEffectSpillCorrection` from other system image paths — that filter is unrelated to `CIQRCodeGenerator`.)
    private static let renderContext = CIContext(options: [.cacheIntermediates: false])

    static func make(from string: String, scale: CGFloat = 12) -> UIImage? {
        guard !string.isEmpty,
              let data = string.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        guard let output = filter.outputImage else { return nil }
        let scaled = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        guard let cg = renderContext.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cg)
    }

    /// True when a QR bitmap can be built (non-empty, valid for Core Image).
    static func canMake(from string: String) -> Bool {
        make(from: string, scale: 4) != nil
    }
}

struct BookingQRCodeView: View {
    let payload: String
    var size: CGFloat = 118
    /// QR modules (Figma reservations: header brown `#31231b`; default black elsewhere).
    var moduleColor: Color = .black

    var body: some View {
        Group {
            if let ui = BookingQRImage.make(from: payload, scale: max(6, size / 22)) {
                Image(uiImage: ui.withRenderingMode(.alwaysTemplate))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .foregroundColor(moduleColor)
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: size, height: size)
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
