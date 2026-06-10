import Foundation
import SwiftUI

/// Central authentication state machine for the app.
///
/// Responsibilities:
///   • Hold the current auth state + signed-in user (drives the app's gate).
///   • Sign up / sign in with email + password (hashing handled by CredentialStore).
///   • Sign in with Apple and guest browsing.
///   • Persist a session in the Keychain so the user stays logged in across launches.
@MainActor
final class AuthService: ObservableObject {
    @Published private(set) var state: AuthState = .loading
    @Published private(set) var currentUser: AppUser?

    private let store = CredentialStore()
    private let keychain = KeychainHelper.standard
    private let sessionService = "com.localgo.session"
    private let sessionAccount = "currentUserId"

    // MARK: - Session restore (called once on launch)

    func restore() async {
        // Tiny delay so the splash isn't a jarring flash.
        try? await Task.sleep(nanoseconds: 350_000_000)

        if let id = keychain.readString(service: sessionService, account: sessionAccount) {
            if id.hasPrefix("guest:") {
                currentUser = Self.makeGuest(id: id)
                state = .signedIn
                return
            }
            if let user = store.user(forId: id) {
                currentUser = user
                state = .signedIn
                return
            }
        }
        state = .signedOut
    }

    // MARK: - Email + password

    func signUp(name: String, email: String, phone: String, password: String, confirm: String) async throws {
        let name  = name.trimmingCharacters(in: .whitespaces)
        let email = email.trimmingCharacters(in: .whitespaces)

        guard !name.isEmpty else { throw AuthError.nameRequired }
        guard Validators.isValidEmail(email) else { throw AuthError.invalidEmail }
        guard Validators.isValidPassword(password) else { throw AuthError.weakPassword }
        guard password == confirm else { throw AuthError.passwordsDoNotMatch }
        guard !store.emailExists(email) else { throw AuthError.emailAlreadyRegistered }

        let user = AppUser(
            id: UUID().uuidString,
            name: name,
            email: email,
            phone: phone.trimmingCharacters(in: .whitespaces),
            provider: .email,
            createdAt: Date()
        )

        // Hash off the main thread (iterated SHA-256 is intentionally slow).
        try await Task.detached(priority: .userInitiated) { [store] in
            store.insert(user: user, password: password)
        }.value

        startSession(user: user)
    }

    func signIn(email: String, password: String) async throws {
        let email = email.trimmingCharacters(in: .whitespaces)
        guard Validators.isValidEmail(email) else { throw AuthError.invalidEmail }
        guard let credential = store.credential(forEmail: email) else { throw AuthError.userNotFound }

        let ok = await Task.detached(priority: .userInitiated) { [store] in
            store.verify(password: password, against: credential)
        }.value

        guard ok else { throw AuthError.wrongPassword }
        startSession(user: credential.user)
    }

    // MARK: - Sign in with Apple

    func completeAppleSignIn(userId: String, fullName: String?, email: String?) {
        // Apple only returns name/email on the *first* authorization, so fall back
        // to whatever we stored before.
        let existing = store.user(forId: userId)
        let user = AppUser(
            id: userId,
            name: fullName?.isEmpty == false ? fullName! : (existing?.name ?? "Apple User"),
            email: email ?? existing?.email ?? "",
            phone: existing?.phone ?? "",
            provider: .apple,
            createdAt: existing?.createdAt ?? Date()
        )
        let resolved = store.upsertFederated(user: user)
        startSession(user: resolved)
    }

    // MARK: - Guest

    func continueAsGuest() {
        let guest = Self.makeGuest(id: "guest:\(UUID().uuidString)")
        startSession(user: guest, persistInStore: false)
    }

    // MARK: - Profile / sign out

    func updateProfile(name: String, phone: String) {
        guard var user = currentUser else { return }
        user.name = name
        user.phone = phone
        if !user.isGuest { store.updateProfile(id: user.id, name: name, phone: phone) }
        currentUser = user
    }

    func signOut() {
        keychain.delete(service: sessionService, account: sessionAccount)
        currentUser = nil
        withAnimation { state = .signedOut }
    }

    // MARK: - Helpers

    private func startSession(user: AppUser, persistInStore: Bool = true) {
        keychain.saveString(user.id, service: sessionService, account: sessionAccount)
        currentUser = user
        withAnimation { state = .signedIn }
    }

    private static func makeGuest(id: String) -> AppUser {
        AppUser(id: id, name: "Guest", email: "", phone: "", provider: .guest, createdAt: Date())
    }
}
