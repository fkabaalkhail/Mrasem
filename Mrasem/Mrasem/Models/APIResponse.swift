import Foundation

struct PaginatedResponse<T: Decodable>: Decodable {
    let data: [T]
    let total: Int
    let page: Int
    let limit: Int
    let totalPages: Int
}

enum APIError: LocalizedError {
    case networkError(underlying: Error)
    case serverError(message: String, statusCode: Int)
    case decodingError(underlying: Error)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .networkError(let err): return "Connection error: \(err.localizedDescription)"
        case .serverError(let msg, _): return msg
        case .decodingError(let err): return "Data error: \(err.localizedDescription)"
        case .unauthorized: return "Session expired. Please log in again."
        }
    }

    /// Returns a localized error message based on the given language.
    func localizedMessage(for language: AppLanguage) -> String {
        switch language {
        case .english:
            return errorDescription ?? "An unknown error occurred."
        case .arabic:
            switch self {
            case .networkError(let err):
                let desc = err.localizedDescription.lowercased()
                if desc.contains("internet") || desc.contains("offline") || desc.contains("not connected") {
                    return "لا يوجد اتصال بالإنترنت"
                }
                return "خطأ في الاتصال"
            case .serverError(let msg, _):
                // Server messages may already be in the right language
                return msg
            case .decodingError:
                return "خطأ في البيانات"
            case .unauthorized:
                return "انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى."
            }
        }
    }
}

/// Maps an error string to a localized message based on the current language.
/// Used by views to display store error strings in the correct language.
func localizedErrorMessage(_ error: String, for language: AppLanguage) -> String {
    guard language == .arabic else { return error }

    let lowered = error.lowercased()

    if lowered.contains("no internet") || lowered.contains("not connected") || lowered.contains("offline") {
        return "لا يوجد اتصال بالإنترنت"
    }
    if lowered.contains("connection error") || lowered.contains("network") || lowered.contains("timed out") || lowered.contains("could not connect") {
        return "خطأ في الاتصال"
    }
    if lowered.contains("data error") || lowered.contains("decod") {
        return "خطأ في البيانات"
    }
    if lowered.contains("session expired") || lowered.contains("unauthorized") || lowered.contains("log in") {
        return "انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى."
    }

    // Return as-is (may be a server message already in the right language)
    return error
}

/// Extra hint when the list fails to load (Express on Mac vs Supabase on device).
func connectionTroubleshootingHint(for language: AppLanguage) -> String {
    switch language {
    case .english:
        return "Phone: paste your Supabase anon key into MRASEM_SUPABASE_ANON_KEY in Info.plist (Dashboard → Project Settings → API). Or run the Mac API and set MRASEM_API_BASE_URL to your Mac’s IP (port 3001). Vercel hosts only the admin website."
    case .arabic:
        return "على الجهاز: ألصق مفتاح Supabase anon في MRASEM_SUPABASE_ANON_KEY داخل Info.plist. أو شغّل API على الماك واضبط MRASEM_API_BASE_URL على IP الماك (منفذ 3001). Vercel يستضيف لوحة الإدارة فقط."
    }
}

func isLikelyConnectionFailureMessage(_ error: String) -> Bool {
    let lowered = error.lowercased()
    return lowered.contains("connection error")
        || lowered.contains("could not connect")
        || lowered.contains("network")
        || lowered.contains("timed out")
        || lowered.contains("host")
        || lowered.contains("refused")
}
