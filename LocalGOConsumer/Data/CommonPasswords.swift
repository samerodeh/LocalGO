import Foundation

/// A small blocklist of the most-breached passwords. In production you'd check
/// against a much larger list or a k-anonymity breach API (e.g. HaveIBeenPwned's
/// range endpoint). Rejecting these stops the easiest credential-stuffing wins.
enum CommonPasswords {
    private static let blocklist: Set<String> = [
        "password", "password1", "password123", "123456", "12345678", "123456789",
        "1234567890", "qwerty", "qwerty123", "abc123", "111111", "000000",
        "iloveyou", "admin", "welcome", "welcome1", "letmein", "monkey",
        "dragon", "sunshine", "princess", "football", "baseball", "superman",
        "trustno1", "passw0rd", "1q2w3e4r", "qazwsx", "zaq12wsx", "changeme",
        "michael", "jordan23", "starwars", "whatever", "asdfghjkl", "qwertyuiop"
    ]

    /// True if the password is too weak/common (also catches it matching the email).
    static func isCompromised(_ password: String, email: String = "") -> Bool {
        let lower = password.lowercased()
        if blocklist.contains(lower) { return true }
        let localPart = email.split(separator: "@").first.map(String.init)?.lowercased() ?? ""
        if !localPart.isEmpty && lower == localPart { return true }
        return false
    }
}
