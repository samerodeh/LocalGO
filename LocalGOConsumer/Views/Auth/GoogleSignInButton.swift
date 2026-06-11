import SwiftUI
import GoogleSignIn

/// Native "Sign in with Google" button wired to the AuthService.
struct GoogleSignInButton: View {
    @EnvironmentObject private var auth: AuthService
    var onError: (String) -> Void = { _ in }

    var body: some View {
        Button { handleGoogleSignIn() } label: {
            HStack(spacing: 12) {
                Image(systemName: "g.circle.fill").font(.system(size: 20))
                Text("Sign in with Google").font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(red: 0.2, green: 0.6, blue: 1.0))   // Google blue
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private func handleGoogleSignIn() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            onError("Could not find root view controller")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            guard error == nil, let result else {
                onError(error?.localizedDescription ?? "Google Sign-In failed")
                return
            }

            let user = result.user
            let userId = user.userID ?? UUID().uuidString
            let fullName = user.profile?.name
            let email = user.profile?.email

            Task { @MainActor in
                auth.completeGoogleSignIn(userId: userId, fullName: fullName, email: email)
            }
        }
    }
}
