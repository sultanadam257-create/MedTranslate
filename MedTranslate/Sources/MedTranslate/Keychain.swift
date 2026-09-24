import Foundation
import Security

enum Keychain {
    private static let service = "com.medtranslate.app"
    private static let account = "openai-api-key"

    static func read() -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: account, kSecReturnData as String: true]
        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func save(_ key: String) throws {
        let data = Data(key.utf8)
        SecItemDelete([kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: account] as CFDictionary)
        let status = SecItemAdd([kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: account, kSecValueData as String: data] as CFDictionary, nil)
        guard status == errSecSuccess else { throw MedTranslateError.api("Impossible d'enregistrer la clé dans le Trousseau.") }
    }

    static func delete() { SecItemDelete([kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: account] as CFDictionary) }
}
