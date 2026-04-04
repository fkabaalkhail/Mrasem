import Foundation
import Security

/// Low-level Keychain helper for storing, reading, and deleting raw Data.
/// Used by APIClient and AuthenticationManager for secure token storage.
struct KeychainHelper {
    static let shared = KeychainHelper()

    private init() {}

    // MARK: - Save

    /// Saves data to the Keychain for the given key.
    /// Overwrites any existing value for the same key.
    /// - Returns: `true` if the save succeeded.
    @discardableResult
    func save(key: String, data: Data) -> Bool {
        // Remove existing item first to avoid duplicates
        delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    // MARK: - Read

    /// Reads data from the Keychain for the given key.
    /// - Returns: The stored `Data`, or `nil` if not found.
    func read(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        return data
    }

    // MARK: - Delete

    /// Deletes the Keychain item for the given key.
    /// - Returns: `true` if the item was deleted or didn't exist.
    @discardableResult
    func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
