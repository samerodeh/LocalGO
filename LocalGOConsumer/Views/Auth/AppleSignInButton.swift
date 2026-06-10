import SwiftUI
import AuthenticationServices

/// Native "Sign in with Apple" button wired to the AuthService.
///
/// Note: fully enabling this requires the "Sign in with Apple" capability on a
/// paid Apple Developer account. Without it the request fails at runtime and we
/// surface a friendly message — the email/password flow always works.
struct AppleSignInButton: View {
    @EnvironmentObject private var auth: AuthService
    var onError: (String) -> Void = { _ in }

    var body: some View {
        SignInWithAppleButton(.continue) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            switch result {
            case .success(let authorization):
                guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                    onError(AuthError.appleSignInFailed.localizedDescription); return
                }
                let name = [credential.fullName?.givenName, credential.fullName?.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                auth.completeAppleSignIn(
                    userId: credential.user,
                    fullName: name.isEmpty ? nil : name,
                    email: credential.email
                )
            case .failure:
                onError(AuthError.appleSignInFailed.localizedDescription)
            }
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 52)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
