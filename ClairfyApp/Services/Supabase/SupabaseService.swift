import Foundation
import Security

final class SupabaseService {
    static let shared = SupabaseService()
    
    private let accessTokenKey = "supabase_user_access_token"
    private let deviceIdKey = "supabase_device_id"
    private let service = Bundle.main.bundleIdentifier ?? "supabase.app"
    private var customEdgeURL: URL? = nil
    
    var appSecret: String? = nil
    var skipAuthorizationHeader: Bool = false
    
    var edgeFunctionURL: URL {
        if let url = customEdgeURL { return url }
        return URL(string: "https://uvyxqgnydymyvyaqycmp.supabase.co/functions/v1/chatgpt-proxy")!
    }

    var anonKey: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV2eXhxZ255ZHlteXZ5YXF5Y21wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjg0ODA3OTIsImV4cCI6MjA0NDA1Njc5Mn0.8oSm3_O8W5bSEJwsrNEpgIQ_uf99qeX4J1WDmV5S4xA"
    
    init() {}

    func configure(edgeFunctionURL: URL, appSecret: String? = nil) {
        self.customEdgeURL = edgeFunctionURL
        self.appSecret = appSecret
    }

    func saveAccessToken(_ token: String) {
        KeychainService.shared.save(token, service: service, account: accessTokenKey)
    }

    func getAccessToken() -> String? {
        KeychainService.shared.read(service: service, account: accessTokenKey)
    }

    func clearAccessToken() {
        KeychainService.shared.delete(service: service, account: accessTokenKey)
    }

    func getOrCreateDeviceId() -> String {
        if let existing = KeychainService.shared.read(service: service, account: deviceIdKey), !existing.isEmpty {
            return existing
        }
        let newId = UUID().uuidString
        KeychainService.shared.save(newId, service: service, account: deviceIdKey)
        return newId
    }

    func clearDeviceId() {
        KeychainService.shared.delete(service: service, account: deviceIdKey)
    }
}
