import Foundation

/// Brute-force / credential-stuffing defense.
///
/// Tracks failed sign-in attempts per email and locks the account with
/// exponential backoff once a threshold is crossed. State is persisted so an
/// attacker can't reset the counter by relaunching the app.
final class LoginThrottle {

    struct Config {
        static let freeAttempts = 5            // allowed before lockout kicks in
        static let baseLockout: TimeInterval = 30
        static let maxLockout: TimeInterval = 900   // 15 minutes
    }

    private struct Record: Codable {
        var failures: Int
        var lockedUntil: Date?
    }

    private let defaultsKey = "com.localgo.throttle.v1"
    private var records: [String: Record]

    init() {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let decoded = try? JSONDecoder().decode([String: Record].self, from: data) {
            records = decoded
        } else {
            records = [:]
        }
    }

    /// Throws `.accountLocked` if the email is currently locked out.
    func checkAllowed(email: String) throws {
        let key = email.lowercased()
        guard let record = records[key], let until = record.lockedUntil else { return }
        let remaining = until.timeIntervalSinceNow
        if remaining > 0 {
            throw AuthError.accountLocked(retryAfter: Int(remaining) + 1)
        }
    }

    /// Record a failed attempt; applies exponential backoff past the threshold.
    func registerFailure(email: String) {
        let key = email.lowercased()
        var record = records[key] ?? Record(failures: 0, lockedUntil: nil)
        record.failures += 1

        if record.failures >= Config.freeAttempts {
            let over = record.failures - Config.freeAttempts
            let lockout = min(Config.baseLockout * pow(2, Double(over)), Config.maxLockout)
            record.lockedUntil = Date().addingTimeInterval(lockout)
        }
        records[key] = record
        persist()
    }

    /// Clear on successful sign-in.
    func reset(email: String) {
        records[email.lowercased()] = nil
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }
}
