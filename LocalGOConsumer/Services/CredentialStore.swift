import Foundation
import CryptoKit

/// Local stand-in for a backend "users" table.
///
/// In production, password verification happens on a server and the app only
/// ever holds a session token. To keep this demo self-contained we persist
/// user records locally — but we still do it the right way: passwords are
/// **never** stored in plaintext. Each credential keeps a random per-user salt
/// and a salted, iterated SHA-256 hash. (A real backend should use bcrypt,
/// scrypt, or Argon2 — noted here intentionally.)
struct StoredCredential: Codable {
    var user: AppUser
    var salt: Data
    var passwordHash: Data
}

final class CredentialStore {
    private let defaultsKey = "com.localgo.credentialStore.v2"
    private var byEmail: [String: StoredCredential]

    init() {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let decoded = try? JSONDecoder().decode([String: StoredCredential].self, from: data) {
            byEmail = decoded
        } else {
            byEmail = [:]
        }
    }

    // MARK: - Queries

    func credential(forEmail email: String) -> StoredCredential? {
        byEmail[email.normalizedEmail]
    }

    func user(forId id: String) -> AppUser? {
        byEmail.values.first(where: { $0.user.id == id })?.user
    }

    func emailExists(_ email: String) -> Bool {
        byEmail[email.normalizedEmail] != nil
    }

    // MARK: - Mutations

    func insert(user: AppUser, password: String) {
        let salt = Self.makeSalt()
        let hash = Self.hash(password: password, salt: salt)
        byEmail[user.email.normalizedEmail] = StoredCredential(user: user, salt: salt, passwordHash: hash)
        persist()
    }

    /// Insert (or fetch existing) for federated logins like Sign in with Apple,
    /// which have no password.
    func upsertFederated(user: AppUser) -> AppUser {
        if let existing = byEmail.values.first(where: { $0.user.id == user.id }) {
            return existing.user
        }
        byEmail[user.email.normalizedEmail.isEmpty ? user.id : user.email.normalizedEmail] =
            StoredCredential(user: user, salt: Data(), passwordHash: Data())
        persist()
        return user
    }

    func verify(password: String, against credential: StoredCredential) -> Bool {
        let candidate = Self.hash(password: password, salt: credential.salt)
        // Constant-time comparison.
        return constantTimeEqual(candidate, credential.passwordHash)
    }

    func updateProfile(id: String, name: String, phone: String) {
        guard let key = byEmail.first(where: { $0.value.user.id == id })?.key else { return }
        byEmail[key]?.user.name = name
        byEmail[key]?.user.phone = phone
        persist()
    }

    func setEmailVerified(id: String, _ verified: Bool) {
        guard let key = byEmail.first(where: { $0.value.user.id == id })?.key else { return }
        byEmail[key]?.user.emailVerified = verified
        persist()
    }

    func setTwoFactor(id: String, _ enabled: Bool) {
        guard let key = byEmail.first(where: { $0.value.user.id == id })?.key else { return }
        byEmail[key]?.user.twoFactorEnabled = enabled
        persist()
    }

    /// Replace the password (new salt + hash). Returns the affected user.
    @discardableResult
    func updatePassword(email: String, newPassword: String) -> AppUser? {
        let key = email.normalizedEmail
        guard var credential = byEmail[key] else { return nil }
        let salt = Self.makeSalt()
        credential.salt = salt
        credential.passwordHash = Self.hash(password: newPassword, salt: salt)
        byEmail[key] = credential
        persist()
        return credential.user
    }

    // MARK: - Hashing

    private static func makeSalt() -> Data {
        var bytes = [UInt8](repeating: 0, count: 16)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes)
    }

    /// Salted, iterated SHA-256. Iteration count slows brute-force attempts.
    static func hash(password: String, salt: Data, iterations: Int = 50_000) -> Data {
        var data = Data(password.utf8) + salt
        for _ in 0..<iterations {
            data = Data(SHA256.hash(data: data))
        }
        return data
    }

    private func constantTimeEqual(_ a: Data, _ b: Data) -> Bool {
        guard a.count == b.count else { return false }
        var diff: UInt8 = 0
        for i in 0..<a.count { diff |= a[i] ^ b[i] }
        return diff == 0
    }

    // MARK: - Persistence

    private func persist() {
        if let data = try? JSONEncoder().encode(byEmail) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }
}

private extension String {
    var normalizedEmail: String {
        trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
