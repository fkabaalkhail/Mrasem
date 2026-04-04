import Foundation
import PassKit
import UIKit

/// Configure where the app loads a **signed** `.pkpass` for membership (Apple Wallet).
/// Passes must be created and signed with your Pass Type ID / certificates.
enum MrasemWalletConfiguration {
    /// HTTPS URL that returns `application/vnd.apple.pkpass` for the current user (recommended for production).
    static var membershipPassDownloadURL: URL? {
        if let s = Bundle.main.object(forInfoDictionaryKey: "MembershipPassDownloadURL") as? String,
           let u = URL(string: s), !s.isEmpty {
            return u
        }
        return nil
    }

    /// Optional: add `MrasemMembership.pkpass` to the app target to test without a server.
    static func bundledMembershipPassData() -> Data? {
        guard let url = Bundle.main.url(forResource: "MrasemMembership", withExtension: "pkpass") else { return nil }
        return try? Data(contentsOf: url)
    }
}

// MARK: - Present add-pass UI

private final class AddPassesDelegate: NSObject, PKAddPassesViewControllerDelegate {
    func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
        controller.dismiss(animated: true)
    }
}

enum WalletPassAddService {
    private static let addDelegate = AddPassesDelegate()

    /// Loads pass data (bundle or URL), then presents Apple’s add-pass sheet.
    @MainActor
    static func addMembershipPassToWallet() async throws {
        let data = try await fetchMembershipPassData()
        let pass: PKPass
        do {
            pass = try PKPass(data: data)
        } catch {
            throw WalletPassAddError.invalidPassData
        }
        try presentAddPassUI(pass: pass)
    }

    @MainActor
    static func fetchMembershipPassData() async throws -> Data {
        if let bundled = MrasemWalletConfiguration.bundledMembershipPassData() {
            return bundled
        }
        guard let url = MrasemWalletConfiguration.membershipPassDownloadURL else {
            throw WalletPassAddError.notConfigured
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200 ... 299).contains(http.statusCode) else {
            throw WalletPassAddError.downloadFailed
        }
        return data
    }

    @MainActor
    static func presentAddPassUI(pass: PKPass) throws {
        guard let addVC = PKAddPassesViewController(passes: [pass]) else {
            throw WalletPassAddError.couldNotCreateAddPassUI
        }
        addVC.delegate = addDelegate
        guard let presenter = topPresenterViewController() else {
            throw WalletPassAddError.noPresenter
        }
        presenter.present(addVC, animated: true)
    }

    @MainActor
    private static func topPresenterViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
        let root = scene.windows.first { $0.isKeyWindow }?.rootViewController
        return topMost(from: root)
    }

    private static func topMost(from base: UIViewController?) -> UIViewController? {
        if let nav = base as? UINavigationController { return topMost(from: nav.visibleViewController) }
        if let tab = base as? UITabBarController { return topMost(from: tab.selectedViewController) }
        if let presented = base?.presentedViewController { return topMost(from: presented) }
        return base
    }
}

enum WalletPassAddError: LocalizedError {
    case notConfigured
    case downloadFailed
    case couldNotCreateAddPassUI
    case noPresenter
    case invalidPassData

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Wallet pass isn’t set up yet. Add MrasemMembership.pkpass to the app or set MembershipPassDownloadURL in Info.plist."
        case .downloadFailed:
            return "Couldn’t download your pass. Check your connection and try again."
        case .couldNotCreateAddPassUI:
            return "Couldn’t open Apple Wallet."
        case .noPresenter:
            return "Couldn’t present Apple Wallet."
        case .invalidPassData:
            return "This pass file isn’t valid. It must be a signed Apple Wallet pass from Mrasem."
        }
    }
}
