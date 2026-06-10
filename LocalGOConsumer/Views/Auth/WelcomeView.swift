import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var auth: AuthService
    @State private var appleError: String?

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Hero
            VStack(spacing: 20) {
                ZStack {
                    Circle().fill(AppTheme.primary.opacity(0.12)).frame(width: 130, height: 130)
                    ZStack {
                        Circle().fill(AppTheme.primary).frame(width: 86, height: 86)
                        Image(systemName: "bag.fill").font(.system(size: 38)).foregroundColor(.white)
                    }
                }
                VStack(spacing: 10) {
                    AuthLogo()
                    Text("Lebanese favorites from Al Taib,\ndelivered fast across Montreal.")
                        .font(.system(size: 16)).foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center).lineSpacing(3)
                }
            }

            Spacer()

            // Actions
            VStack(spacing: 14) {
                NavigationLink {
                    SignUpView()
                } label: {
                    Text("Create Account").font(.system(size: 17, weight: .bold)).primaryButtonStyle()
                }

                AppleSignInButton { appleError = $0 }
                    .environmentObject(auth)

                NavigationLink {
                    LoginView()
                } label: {
                    Text("I already have an account")
                        .font(.system(size: 16, weight: .semibold)).foregroundColor(AppTheme.navy)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(AppTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(AppTheme.divider, lineWidth: 1))
                }

                Button { auth.continueAsGuest() } label: {
                    Text("Continue as guest")
                        .font(.system(size: 15, weight: .medium)).foregroundColor(AppTheme.textSecondary)
                        .padding(.vertical, 6)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            Text("By continuing you agree to our Terms & Privacy Policy.")
                .font(.system(size: 11)).foregroundColor(AppTheme.textSecondary.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .alert("Sign in with Apple", isPresented: Binding(
            get: { appleError != nil }, set: { if !$0 { appleError = nil } }
        )) {
            Button("OK") { appleError = nil }
        } message: { Text(appleError ?? "") }
    }
}
