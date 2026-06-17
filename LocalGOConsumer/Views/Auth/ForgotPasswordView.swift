import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject private var auth: AuthService

    @State private var email = ""
    @State private var isLoading = false
    @State private var error: String?
    @State private var goToReset = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reset password").font(.system(size: 28, weight: .black)).foregroundColor(AppTheme.textPrimary)
                    Text("Enter your email and we'll send a 6-digit code to reset your password.")
                        .font(.system(size: 15)).foregroundColor(AppTheme.textSecondary)
                }
                .padding(.top, 8)

                AuthField(icon: "envelope.fill", placeholder: "Email", text: $email,
                          keyboard: .emailAddress, textContentType: .username)

                AuthPrimaryButton(title: "Send Reset Code", isLoading: isLoading, disabled: email.isEmpty) {
                    submit()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Forgot Password")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $goToReset) {
            ResetPasswordView(email: email)
        }
        .alert("Couldn't send code", isPresented: Binding(
            get: { error != nil }, set: { if !$0 { error = nil } }
        )) {
            Button("OK") { error = nil }
        } message: { Text(error ?? "") }
    }

    private func submit() {
        error = nil; isLoading = true
        Task {
            do {
                try await auth.requestPasswordReset(email: email)
                goToReset = true
            } catch let e as AuthError {
                // Format errors block; throttling still lets them proceed with a prior code.
                if case .resendTooSoon = e { goToReset = true } else { error = e.localizedDescription }
            } catch {
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }
}
