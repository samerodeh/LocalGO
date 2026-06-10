import Foundation

// MARK: - User

enum AuthProvider: String, Codable {
    case email
    case apple
    case guest
}

struct AppUser: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var email: String
    var phone: String
    let provider: AuthProvider
    let createdAt: Date
    var emailVerified: Bool = false
    var twoFactorEnabled: Bool = false

    var isGuest: Bool { provider == .guest }

    var initials: String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        let result = String(letters).uppercased()
        return result.isEmpty ? "?" : result
    }

    // Tolerant decoding so older stored records (without the new flags) still load.
    init(id: String, name: String, email: String, phone: String,
         provider: AuthProvider, createdAt: Date,
         emailVerified: Bool = false, twoFactorEnabled: Bool = false) {
        self.id = id; self.name = name; self.email = email; self.phone = phone
        self.provider = provider; self.createdAt = createdAt
        self.emailVerified = emailVerified; self.twoFactorEnabled = twoFactorEnabled
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        email = try c.decode(String.self, forKey: .email)
        phone = try c.decode(String.self, forKey: .phone)
        provider = try c.decode(AuthProvider.self, forKey: .provider)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        emailVerified = try c.decodeIfPresent(Bool.self, forKey: .emailVerified) ?? false
        twoFactorEnabled = try c.decodeIfPresent(Bool.self, forKey: .twoFactorEnabled) ?? false
    }
}

// MARK: - Auth state

enum AuthState: Equatable {
    case loading       // checking for a stored session on launch
    case signedOut
    case verifying     // awaiting an emailed code (sign-up verify or 2FA)
    case signedIn
}

/// What the pending emailed-code challenge is for.
enum AuthChallengeKind: Equatable {
    case signupVerification
    case twoFactor
}

struct PendingChallenge: Equatable {
    let email: String
    let kind: AuthChallengeKind
}

// MARK: - Errors

enum AuthError: LocalizedError, Equatable {
    case nameRequired
    case invalidEmail
    case weakPassword
    case commonPassword
    case passwordsDoNotMatch
    case emailAlreadyRegistered
    case invalidCredentials          // generic — anti-enumeration
    case accountLocked(retryAfter: Int)
    case invalidCode
    case codeExpired
    case tooManyCodeAttempts
    case resendTooSoon(retryAfter: Int)
    case emailSendFailed
    case appleSignInFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .nameRequired:           return "Please enter your name."
        case .invalidEmail:           return "Enter a valid email address."
        case .weakPassword:           return "Use at least 8 characters with a letter and a number."
        case .commonPassword:         return "That password is too common — pick something harder to guess."
        case .passwordsDoNotMatch:    return "The passwords don't match."
        case .emailAlreadyRegistered: return "An account with this email already exists. Try signing in."
        case .invalidCredentials:     return "Incorrect email or password."
        case .accountLocked(let s):   return "Too many attempts. Try again in \(s)s."
        case .invalidCode:            return "That code isn't right. Please check and try again."
        case .codeExpired:            return "That code has expired. Tap Resend for a new one."
        case .tooManyCodeAttempts:    return "Too many incorrect codes. Tap Resend to get a fresh one."
        case .resendTooSoon(let s):   return "Please wait \(s)s before requesting another code."
        case .emailSendFailed:        return "We couldn't send the email. Check your connection and try again."
        case .appleSignInFailed:      return "Sign in with Apple isn't available in this build. Use email instead."
        case .unknown:                return "Something went wrong. Please try again."
        }
    }
}

// MARK: - Validation

enum Validators {
    static func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    static func isValidPassword(_ password: String) -> Bool {
        guard password.count >= 8 else { return false }
        let hasLetter = password.rangeOfCharacter(from: .letters) != nil
        let hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
        return hasLetter && hasNumber
    }

    /// 0 (empty) … 4 (strong) — drives the strength meter on sign-up.
    static func passwordStrength(_ password: String) -> Int {
        guard !password.isEmpty else { return 0 }
        var score = 0
        if password.count >= 8 { score += 1 }
        if password.count >= 12 { score += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil &&
           password.rangeOfCharacter(from: .letters) != nil { score += 1 }
        let symbols = CharacterSet(charactersIn: "!@#$%^&*()_-+=[]{}|;:,.<>?/")
        if password.rangeOfCharacter(from: symbols) != nil { score += 1 }
        return min(score, 4)
    }

    static func strengthLabel(_ score: Int) -> String {
        switch score {
        case 0:    return ""
        case 1:    return "Weak"
        case 2:    return "Fair"
        case 3:    return "Good"
        default:   return "Strong"
        }
    }
}
