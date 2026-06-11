import Foundation
import CryptoKit

/// User credential store, backed by the on-disk SQLite database.
///
/// Passwords are **never** stored in plaintext: each user has a random per-user
/// salt and a salted, iterated SHA-256 hash, with constant-time verification.
/// (A production backend should use bcrypt / scrypt / Argon2 server-side — noted
/// intentionally.)
struct StoredCredential {
    var user: AppUser
    var salt: Data
    var passwordHash: Data
}

final class CredentialStore {
    private let db = Database.shared

    // MARK: - Queries

    func credential(forEmail email: String) -> StoredCredential? {
        guard let row = db.userRow(email: email) else { return nil }
        return StoredCredential(user: row.user, salt: row.salt, passwordHash: row.hash)
    }

    func user(forId id: String) -> AppUser? {
        db.userRow(id: id)?.user
    }

    func emailExists(_ email: String) -> Bool {
        db.userRow(email: email) != nil
    }

    // MARK: - Mutations

    func insert(user: AppUser, password: String) {
        let salt = Self.makeSalt()
        let hash = Self.hash(password: password, salt: salt)
        db.upsertUser(user: user, salt: salt, passwordHash: hash)
    }

    /// Insert (or fetch existing) for federated logins like Sign in with Apple.
    @discardableResult
    func upsertFederated(user: AppUser) -> AppUser {
        if let existing = db.userRow(id: user.id)?.user { return existing }
        db.upsertUser(user: user, salt: Data(), passwordHash: Data())
        return user
    }

    func verify(password: String, against credential: StoredCredential) -> Bool {
        let candidate = Self.hash(password: password, salt: credential.salt)
        return constantTimeEqual(candidate, credential.passwordHash)
    }

    func updateProfile(id: String, name: String, phone: String) {
        db.updateUserFields(id: id, name: name, phone: phone)
    }

    func setEmailVerified(id: String, _ verified: Bool) {
        db.setEmailVerified(id: id, verified)
    }

    func setTwoFactor(id: String, _ enabled: Bool) {
        db.setTwoFactor(id: id, enabled)
    }

    /// Replace the password (new salt + hash). Returns the affected user.
    @discardableResult
    func updatePassword(email: String, newPassword: String) -> AppUser? {
        guard let row = db.userRow(email: email) else { return nil }
        let salt = Self.makeSalt()
        let hash = Self.hash(password: newPassword, salt: salt)
        db.updatePassword(id: row.user.id, salt: salt, hash: hash)
        return row.user
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
}
