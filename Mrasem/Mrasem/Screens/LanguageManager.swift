import SwiftUI
import Combine

enum AppLanguage {
    case english
    case arabic
}

final class LanguageManager: ObservableObject {
    @Published var current: AppLanguage = .english
    
    func toggle() {
        current = (current == .english) ? .arabic : .english
    }
}
