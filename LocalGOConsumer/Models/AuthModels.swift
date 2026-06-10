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

    var isGuest: Bool { provider == .guest }

    var initials: String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        let result = String(letters).uppercased()
        return result.isEmpty ? "?" : result
    }
}

// MARK: - Auth state

enum AuthState: Equatable {
    case loading      // checking for a stored session on launch
    case signedOut
    case signedIn
}

// MARK: - Errors

enum AuthError: LocalizedError, Equatable {
    case nameRequired
    case invalidEmail
    case weakPassword
    case passwordsDoNotMatch
    case emailAlreadyRegistered
    case userNotFound
    case wrongPassword
    case appleSignInFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .nameRequired:           return "Please enter your name."
        case .invalidEmail:           return "Enter a valid email address."
        case .weakPassword:           return "Password must be at least 8 characters and include a letter and a number."
        case .passwordsDoNotMatch:    return "The passwords don't match."
        case .emailAlreadyRegistered: return "An account with this email already exists. Try signing in."
        case .userNotFound:           return "No account found for this email. Create one to get started."
        case .wrongPassword:          return "Incorrect password. Please try again."
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
