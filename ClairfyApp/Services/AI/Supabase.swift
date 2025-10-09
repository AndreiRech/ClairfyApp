import Foundation
import Security

public final class SupabaseManager {
    public static let shared = SupabaseManager()

    // >>> SUBSTITUA pela URL real da sua Edge Function <<<
    // Ex.: https://<project>.functions.supabase.co/chatgpt-proxy
    public var edgeFunctionURL: URL {
        if let url = customEdgeURL { return url }
        return URL(string: "https://uvyxqgnydymyvyaqycmp.supabase.co/functions/v1/chatgpt-proxy")!
    }

    /// Opcional: defina um x-app-secret para bypass de DEV (se configurado no server)
    public var appSecret: String? = nil

    // MARK: - Public config
    public func configure(edgeFunctionURL: URL, appSecret: String? = nil) {
        self.customEdgeURL = edgeFunctionURL
        self.appSecret = appSecret
    }

    // MARK: - Access Token (para quando você habilitar Auth futuramente)
    public func saveAccessToken(_ token: String) {
        KeychainHelper.shared.save(token, service: service, account: accessTokenKey)
    }

    public func getAccessToken() -> String? {
        KeychainHelper.shared.read(service: service, account: accessTokenKey)
    }

    public func clearAccessToken() {
        KeychainHelper.shared.delete(service: service, account: accessTokenKey)
    }

    // MARK: - Device ID (anon mode atual)
    public func getOrCreateDeviceId() -> String {
        if let existing = KeychainHelper.shared.read(service: service, account: deviceIdKey), !existing.isEmpty {
            return existing
        }
        let newId = UUID().uuidString
        KeychainHelper.shared.save(newId, service: service, account: deviceIdKey)
        return newId
    }

    public func clearDeviceId() {
        KeychainHelper.shared.delete(service: service, account: deviceIdKey)
    }

    // MARK: - Private
    private init() {}

    private let accessTokenKey = "supabase_user_access_token"
    private let deviceIdKey = "supabase_device_id"
    private let service = Bundle.main.bundleIdentifier ?? "supabase.app"
    private var customEdgeURL: URL? = nil
}

// MARK: - Keychain helper

final class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}

    func save(_ value: String, service: String, account: String) {
        guard let data = value.data(using: .utf8) else { return }
        delete(service: service, account: account) // overwrite
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    func read(service: String, account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let data = item as? Data,
              let value = String(data: data, encoding: .utf8) else { return nil }
        return value
    }

    func delete(service: String, account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}
