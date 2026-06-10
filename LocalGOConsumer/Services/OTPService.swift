import Foundation
import CryptoKit

/// Issues and verifies one-time codes for email verification, password reset,
/// and two-factor sign-in.
///
/// Security properties:
///   • Codes are stored only as a salted SHA-256 **hash**, never in plaintext.
///   • Each code **expires** (10 min) and is **single-use** (deleted on success).
///   • **Attempt-limited** (5 wrong tries invalidates the code).
///   • **Rate-limited**: a 30s resend cooldown and a cap of 5 sends/hour per
///     (email, purpose) to throttle abuse and email bombing.
final class OTPService {

    enum Purpose: String { case signup, reset, login }

    struct Config {
        static let codeLength = 6
        static let ttl: TimeInterval = 600          // 10 minutes
        static let maxAttempts = 5
        static let resendCooldown: TimeInterval = 30
        static let maxSendsPerHour = 5
    }

    private struct Record: Codable {
        var codeHash: Data
        var salt: Data
        var expiresAt: Date
        var attempts: Int
        var lastSentAt: Date
        var windowStart: Date
        var sendsInWindow: Int
    }

    private let defaultsKey = "com.localgo.otp.v1"
    private var records: [String: Record]

    init() {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let decoded = try? JSONDecoder().decode([String: Record].self, from: data) {
            records = decoded
        } else {
            records = [:]
        }
    }

    // MARK: - Issue

    /// Generates a fresh code (subject to rate limits) and returns the plaintext
    /// so the caller can email it. Throws `.resendTooSoon` if throttled.
    func issue(email: String, purpose: Purpose) throws -> String {
        let key = key(email, purpose)
        let now = Date()
        var record = records[key]

        // Resend cooldown
        if let r = record, now.timeIntervalSince(r.lastSentAt) < Config.resendCooldown {
            let wait = Int(Config.resendCooldown - now.timeIntervalSince(r.lastSentAt)) + 1
            throw AuthError.resendTooSoon(retryAfter: wait)
        }

        // Hourly window cap
        var windowStart = record?.windowStart ?? now
        var sends = record?.sendsInWindow ?? 0
        if now.timeIntervalSince(windowStart) > 3600 { windowStart = now; sends = 0 }
        if sends >= Config.maxSendsPerHour {
            let wait = Int(3600 - now.timeIntervalSince(windowStart)) + 1
            throw AuthError.resendTooSoon(retryAfter: max(wait, 60))
        }

        let code = Self.randomCode()
        let salt = Self.makeSalt()
        record = Record(
            codeHash: Self.hash(code, salt: salt),
            salt: salt,
            expiresAt: now.addingTimeInterval(Config.ttl),
            attempts: 0,
            lastSentAt: now,
            windowStart: windowStart,
            sendsInWindow: sends + 1
        )
        records[key] = record
        persist()
        return code
    }

    // MARK: - Verify

    func verify(email: String, purpose: Purpose, code: String) throws {
        let key = key(email, purpose)
        guard var record = records[key] else { throw AuthError.invalidCode }

        if Date() > record.expiresAt {
            records[key] = nil; persist()
            throw AuthError.codeExpired
        }
        if record.attempts >= Config.maxAttempts {
            records[key] = nil; persist()
            throw AuthError.tooManyCodeAttempts
        }

        let candidate = Self.hash(code, salt: record.salt)
        guard constantTimeEqual(candidate, record.codeHash) else {
            record.attempts += 1
            records[key] = record
            persist()
            throw AuthError.invalidCode
        }

        // Success — single use.
        records[key] = nil
        persist()
    }

    // MARK: - Helpers

    private func key(_ email: String, _ purpose: Purpose) -> String {
        "\(purpose.rawValue):\(email.lowercased())"
    }

    private static func randomCode() -> String {
        String(format: "%06d", Int.random(in: 0...999_999))
    }

    private static func makeSalt() -> Data {
        var bytes = [UInt8](repeating: 0, count: 16)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes)
    }

    private static func hash(_ code: String, salt: Data) -> Data {
        Data(SHA256.hash(data: Data(code.utf8) + salt))
    }

    private func constantTimeEqual(_ a: Data, _ b: Data) -> Bool {
        guard a.count == b.count else { return false }
        var diff: UInt8 = 0
        for i in 0..<a.count { diff |= a[i] ^ b[i] }
        return diff == 0
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }
}
