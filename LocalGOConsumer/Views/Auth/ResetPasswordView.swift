import SwiftUI

struct ResetPasswordView: View {
    let email: String
    @EnvironmentObject private var auth: AuthService

    @State private var code = ""
    @State private var password = ""
    @State private var confirm = ""
    @State private var isLoading = false
    @State private var error: String?

    private var canSubmit: Bool {
        code.count == 6 && !password.isEmpty && !confirm.isEmpty
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose a new password").font(.system(size: 26, weight: .black)).foregroundColor(AppTheme.textPrimary)
                    Text("Enter the code sent to \(email) and your new password.")
                        .font(.system(size: 15)).foregroundColor(AppTheme.textSecondary)
                }
                .padding(.top, 8)

                VStack(alignment: .center, spacing: 8) {
                    OTPCodeField(code: $code)
                    #if DEBUG
                    if let demo = auth.debugLastCode {
                        Text("Demo build — your code is \(demo)")
                            .font(.system(size: 12, weight: .semibold)).foregroundColor(AppTheme.textSecondary)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(AppTheme.divider.opacity(0.5), in: Capsule())
                    }
                    #endif
                }
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 8) {
                    AuthField(icon: "lock.fill", placeholder: "New password", text: $password,
                              textContentType: .newPassword, isSecure: true)
                    PasswordStrengthMeter(password: password)
                }
                AuthField(icon: "lock.fill", placeholder: "Confirm new password", text: $confirm,
                          textContentType: .newPassword, isSecure: true)

                AuthPrimaryButton(title: "Reset Password", isLoading: isLoading, disabled: !canSubmit) {
                    submit()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("New Password")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Couldn't reset password", isPresented: Binding(
            get: { error != nil }, set: { if !$0 { error = nil } }
        )) {
            Button("OK") { error = nil }
        } message: { Text(error ?? "") }
    }

    private func submit() {
        error = nil; isLoading = true
        Task {
            do {
                try await auth.confirmPasswordReset(email: email, code: code,
                                                    newPassword: password, confirm: confirm)
                // Success transitions the app to signed-in via the gate.
            } catch {
                self.error = (error as? AuthError)?.localizedDescription ?? error.localizedDescription
            }
            isLoading = false
        }
    }
}
