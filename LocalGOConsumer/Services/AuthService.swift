import Foundation
import SwiftUI

/// Central authentication state machine.
///
/// Security features layered in:
///   • Email verification via a one-time code before the first session.
///   • Brute-force lockout with exponential backoff (LoginThrottle).
///   • Anti-enumeration: sign-in failures return a single generic error.
///   • Common/breached-password rejection at sign-up and reset.
///   • Password reset by emailed code; optional two-factor at sign-in.
///   • Expiring, Keychain-stored sessions (token + expiry).
@MainActor
final class AuthService: ObservableObject {
    @Published private(set) var state: AuthState = .loading
    @Published private(set) var currentUser: AppUser?
    @Published private(set) var pendingChallenge: PendingChallenge?

    /// DEBUG-only: the most recent code "sent", so the demo is testable without
    /// a real mail server. Never compiled into release builds.
    #if DEBUG
    @Published var debugLastCode: String?
    #endif

    private let store = CredentialStore()
    private let otp = OTPService()
    private let throttle = LoginThrottle()
    private let email = EmailService()
    private let keychain = KeychainHelper.standard

    private let sessionService = "com.localgo.session"
    private let sessionAccount = "session"
    private let sessionValidity: TimeInterval = 60 * 60 * 24 * 30   // 30 days

    private struct SessionToken: Codable {
        let userId: String
        let token: String
        let issuedAt: Date
        let expiresAt: Date
    }

    // MARK: - Session restore (called once on launch)

    func restore() async {
        try? await Task.sleep(nanoseconds: 350_000_000)   // brief splash

        if let data = keychain.read(service: sessionService, account: sessionAccount),
           let session = try? JSONDecoder().decode(SessionToken.self, from: data),
           session.expiresAt > Date() {
            if session.userId.hasPrefix("guest:") {
                currentUser = Self.makeGuest(id: session.userId)
                state = .signedIn
                return
            }
            if let user = store.user(forId: session.userId) {
                currentUser = user
                state = .signedIn
                return
            }
        }
        keychain.delete(service: sessionService, account: sessionAccount)   // expired/invalid
        state = .signedOut
    }

    // MARK: - Sign up  → email verification

    func signUp(name: String, email rawEmail: String, phone: String,
                password: String, confirm: String) async throws {
        let name  = name.trimmingCharacters(in: .whitespaces)
        let email = rawEmail.trimmingCharacters(in: .whitespaces)

        guard !name.isEmpty else { throw AuthError.nameRequired }
        guard Validators.isValidEmail(email) else { throw AuthError.invalidEmail }
        guard Validators.isValidPassword(password) else { throw AuthError.weakPassword }
        guard !CommonPasswords.isCompromised(password, email: email) else { throw AuthError.commonPassword }
        guard password == confirm else { throw AuthError.passwordsDoNotMatch }
        guard !store.emailExists(email) else { throw AuthError.emailAlreadyRegistered }

        let user = AppUser(
            id: UUID().uuidString, name: name, email: email,
            phone: phone.trimmingCharacters(in: .whitespaces),
            provider: .email, createdAt: Date(), emailVerified: false
        )

        await Task.detached(priority: .userInitiated) { [store] in
            store.insert(user: user, password: password)
        }.value

        try await issueAndSend(.signup, to: email)
        pendingChallenge = PendingChallenge(email: email, kind: .signupVerification)
        withAnimation { state = .verifying }
    }

    // MARK: - Sign in (throttled, generic errors, optional 2FA)

    func signIn(email rawEmail: String, password: String) async throws {
        let email = rawEmail.trimmingCharacters(in: .whitespaces)
        try throttle.checkAllowed(email: email)
        guard Validators.isValidEmail(email) else {
            throttle.registerFailure(email: email)
            throw AuthError.invalidCredentials
        }
        guard let credential = store.credential(forEmail: email) else {
            throttle.registerFailure(email: email)            // same path → no enumeration
            throw AuthError.invalidCredentials
        }

        let ok = await Task.detached(priority: .userInitiated) { [store] in
            store.verify(password: password, against: credential)
        }.value

        guard ok else {
            throttle.registerFailure(email: email)
            throw AuthError.invalidCredentials
        }
        throttle.reset(email: email)

        // Unverified account → must verify before the first session.
        if !credential.user.emailVerified {
            try await issueAndSend(.signup, to: email)
            pendingChallenge = PendingChallenge(email: email, kind: .signupVerification)
            withAnimation { state = .verifying }
            return
        }
        // Two-factor enabled → emailed code.
        if credential.user.twoFactorEnabled {
            try await issueAndSend(.login, to: email)
            pendingChallenge = PendingChallenge(email: email, kind: .twoFactor)
            withAnimation { state = .verifying }
            return
        }
        startSession(user: credential.user)
    }

    // MARK: - Challenge (verify code) handling

    func submitChallengeCode(_ code: String) async throws {
        guard let challenge = pendingChallenge else { throw AuthError.unknown }
        let address = challenge.email

        switch challenge.kind {
        case .signupVerification:
            try otp.verify(email: address, purpose: .signup, code: code)
            guard let user = store.credential(forEmail: address)?.user else { throw AuthError.unknown }
            store.setEmailVerified(id: user.id, true)
            let verified = store.credential(forEmail: address)?.user ?? user
            if !address.isEmpty { await email.sendWelcome(to: address, name: verified.name) }
            startSession(user: verified)

        case .twoFactor:
            try otp.verify(email: address, purpose: .login, code: code)
            guard let user = store.credential(forEmail: address)?.user else { throw AuthError.unknown }
            startSession(user: user)
        }
    }

    func resendChallengeCode() async throws {
        guard let challenge = pendingChallenge else { return }
        let purpose: OTPService.Purpose = challenge.kind == .signupVerification ? .signup : .login
        try await issueAndSend(purpose, to: challenge.email)
    }

    func cancelChallenge() {
        pendingChallenge = nil
        keychain.delete(service: sessionService, account: sessionAccount)
        withAnimation { state = .signedOut }
    }

    // MARK: - Password reset (anti-enumeration)

    /// Always succeeds from the user's perspective; only sends a code if the
    /// account actually exists, so attackers can't probe for valid emails.
    func requestPasswordReset(email rawEmail: String) async throws {
        let address = rawEmail.trimmingCharacters(in: .whitespaces)
        guard Validators.isValidEmail(address) else { throw AuthError.invalidEmail }
        // Cooldown applies regardless of existence to keep timing uniform.
        let code = try otp.issue(email: address, purpose: .reset)
        #if DEBUG
        debugLastCode = code
        #endif
        if store.emailExists(address) {
            try? await email.sendPasswordResetCode(to: address, code: code)
        }
    }

    func confirmPasswordReset(email rawEmail: String, code: String,
                              newPassword: String, confirm: String) async throws {
        let address = rawEmail.trimmingCharacters(in: .whitespaces)
        guard Validators.isValidPassword(newPassword) else { throw AuthError.weakPassword }
        guard !CommonPasswords.isCompromised(newPassword, email: address) else { throw AuthError.commonPassword }
        guard newPassword == confirm else { throw AuthError.passwordsDoNotMatch }

        try otp.verify(email: address, purpose: .reset, code: code)

        guard let user = await Task.detached(priority: .userInitiated, operation: { [store] in
            store.updatePassword(email: address, newPassword: newPassword)
        }).value else { throw AuthError.unknown }

        throttle.reset(email: address)
        await email.sendSecurityAlert(to: address, event: "Your password was changed")
        startSession(user: user)   // they proved control of the email + set a new password
    }

    // MARK: - Sign in with Google

    func completeGoogleSignIn(userId: String, fullName: String?, email googleEmail: String?) {
        let existing = store.user(forId: userId)
        let user = AppUser(
            id: userId,
            name: fullName?.isEmpty == false ? fullName! : (existing?.name ?? "Google User"),
            email: googleEmail ?? existing?.email ?? "",
            phone: existing?.phone ?? "",
            provider: .apple,   // we reuse .apple for all federated logins
            createdAt: existing?.createdAt ?? Date(),
            emailVerified: true   // Google verifies the email
        )
        let resolved = store.upsertFederated(user: user)
        startSession(user: resolved)
    }

    // MARK: - Sign in with Apple

    func completeAppleSignIn(userId: String, fullName: String?, email appleEmail: String?) {
        let existing = store.user(forId: userId)
        let user = AppUser(
            id: userId,
            name: fullName?.isEmpty == false ? fullName! : (existing?.name ?? "Apple User"),
            email: appleEmail ?? existing?.email ?? "",
            phone: existing?.phone ?? "",
            provider: .apple,
            createdAt: existing?.createdAt ?? Date(),
            emailVerified: true   // Apple verifies the email
        )
        let resolved = store.upsertFederated(user: user)
        startSession(user: resolved)
    }

    // MARK: - Guest

    func continueAsGuest() {
        startSession(user: Self.makeGuest(id: "guest:\(UUID().uuidString)"))
    }

    // MARK: - Profile / security settings

    func updateProfile(name: String, phone: String) {
        guard var user = currentUser else { return }
        user.name = name; user.phone = phone
        if !user.isGuest { store.updateProfile(id: user.id, name: name, phone: phone) }
        currentUser = user
    }

    func setTwoFactor(_ enabled: Bool) {
        guard var user = currentUser, !user.isGuest else { return }
        user.twoFactorEnabled = enabled
        store.setTwoFactor(id: user.id, enabled)
        currentUser = user
        Task {
            await email.sendSecurityAlert(
                to: user.email,
                event: enabled ? "Two-factor authentication was turned on"
                               : "Two-factor authentication was turned off")
        }
    }

    func signOut() {
        keychain.delete(service: sessionService, account: sessionAccount)
        currentUser = nil
        pendingChallenge = nil
        withAnimation { state = .signedOut }
    }

    // MARK: - Helpers

    private func issueAndSend(_ purpose: OTPService.Purpose, to address: String) async throws {
        let code = try otp.issue(email: address, purpose: purpose)
        #if DEBUG
        debugLastCode = code
        #endif
        switch purpose {
        case .signup: try await email.sendVerificationCode(to: address, code: code)
        case .login:  try await email.sendTwoFactorCode(to: address, code: code)
        case .reset:  try await email.sendPasswordResetCode(to: address, code: code)
        }
    }

    private func startSession(user: AppUser) {
        let token = SessionToken(
            userId: user.id,
            token: UUID().uuidString,
            issuedAt: Date(),
            expiresAt: Date().addingTimeInterval(sessionValidity)
        )
        if let data = try? JSONEncoder().encode(token) {
            keychain.save(data, service: sessionService, account: sessionAccount)
        }
        currentUser = user
        pendingChallenge = nil
        #if DEBUG
        debugLastCode = nil
        #endif
        withAnimation { state = .signedIn }
    }

    private static func makeGuest(id: String) -> AppUser {
        AppUser(id: id, name: "Guest", email: "", phone: "", provider: .guest, createdAt: Date())
    }
}
