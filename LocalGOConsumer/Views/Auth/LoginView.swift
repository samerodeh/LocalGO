import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var auth: AuthService
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var error: String?

    private var canSubmit: Bool { !email.isEmpty && !password.isEmpty }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome back").font(.system(size: 28, weight: .black)).foregroundColor(AppTheme.textPrimary)
                    Text("Sign in to keep ordering your favorites.")
                        .font(.system(size: 15)).foregroundColor(AppTheme.textSecondary)
                }
                .padding(.top, 8)

                VStack(spacing: 14) {
                    AuthField(icon: "envelope.fill", placeholder: "Email", text: $email,
                              keyboard: .emailAddress, textContentType: .username)
                    AuthField(icon: "lock.fill", placeholder: "Password", text: $password,
                              textContentType: .password, isSecure: true)
                }

                NavigationLink {
                    ForgotPasswordView()
                } label: {
                    Text("Forgot password?")
                        .font(.system(size: 14, weight: .semibold)).foregroundColor(AppTheme.primary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

                AuthPrimaryButton(title: "Sign In", isLoading: isLoading, disabled: !canSubmit) {
                    submit()
                }

                OrDivider()

                AppleSignInButton { error = $0 }
                    .environmentObject(auth)

                HStack(spacing: 4) {
                    Text("New to LocalGO?").font(.system(size: 14)).foregroundColor(AppTheme.textSecondary)
                    NavigationLink { SignUpView() } label: {
                        Text("Create an account").font(.system(size: 14, weight: .bold)).foregroundColor(AppTheme.primary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Couldn't sign in", isPresented: Binding(
            get: { error != nil }, set: { if !$0 { error = nil } }
        )) {
            Button("OK") { error = nil }
        } message: { Text(error ?? "") }
    }

    private func submit() {
        error = nil
        isLoading = true
        Task {
            do {
                try await auth.signIn(email: email, password: password)
            } catch {
                self.error = (error as? AuthError)?.localizedDescription ?? error.localizedDescription
            }
            isLoading = false
        }
    }
}
