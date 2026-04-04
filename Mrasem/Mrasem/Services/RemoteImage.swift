import SwiftUI

/// A view that loads images either from the remote server or the local asset catalog.
/// Supports absolute `http`/`https` URLs (e.g. Supabase storage), `/uploads/` paths on the API host,
/// or a local asset catalog name.
struct RemoteImage: View {
    let imageName: String
    let baseURL: String

    /// Initializes a RemoteImage view.
    /// - Parameters:
    ///   - imageName: Absolute URL, "/uploads/..." path, or local asset name.
    ///   - baseURL: The server base URL for "/uploads/" images. Defaults to APIClient's baseURL
    ///             with the "/api" suffix stripped (uploads are served at the root).
    init(imageName: String, baseURL: String = {
        let url = APIClient.shared.baseURL
        if url.hasSuffix("/api") {
            return String(url.dropLast(4))
        }
        return url
    }()) {
        self.imageName = imageName
        self.baseURL = baseURL
    }

    private var isAbsoluteURL: Bool {
        let lower = imageName.lowercased()
        return lower.hasPrefix("http://") || lower.hasPrefix("https://")
    }

    var body: some View {
        if isAbsoluteURL {
            asyncRemoteImage(urlString: imageName)
        } else if imageName.hasPrefix("/uploads/") {
            asyncRemoteImage(urlString: baseURL + imageName)
        } else {
            Image(imageName)
                .resizable()
        }
    }

    @ViewBuilder
    private func asyncRemoteImage(urlString: String) -> some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .success(let image):
                image.resizable()
            case .failure:
                Image("placeholder")
                    .resizable()
            default:
                Color(red: 0xE8 / 255.0, green: 0xE8 / 255.0, blue: 0xE8 / 255.0)
            }
        }
    }
}
