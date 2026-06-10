import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var auth: AuthService

    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirm = ""
    @State private var isLoading = false
    @State private var error: String?

    private var canSubmit: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty && !confirm.isEmpty
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Create your account").font(.system(size: 28, weight: .black)).foregroundColor(AppTheme.textPrimary)
                    Text("Order in seconds and track every delivery.")
                        .font(.system(size: 15)).foregroundColor(AppTheme.textSecondary)
                }
                .padding(.top, 8)

                VStack(spacing: 14) {
                    AuthField(icon: "person.fill", placeholder: "Full name", text: $name,
                              textContentType: .name, autocapitalization: .words)
                    AuthField(icon: "envelope.fill", placeholder: "Email", text: $email,
                              keyboard: .emailAddress, textContentType: .username)
                    AuthField(icon: "phone.fill", placeholder: "Phone (optional)", text: $phone,
                              keyboard: .phonePad, textContentType: .telephoneNumber)

                    VStack(alignment: .leading, spacing: 8) {
                        AuthField(icon: "lock.fill", placeholder: "Password", text: $password,
                                  textContentType: .newPassword, isSecure: true)
                        PasswordStrengthMeter(password: password)
                    }

                    AuthField(icon: "lock.fill", placeholder: "Confirm password", text: $confirm,
                              textContentType: .newPassword, isSecure: true)
                }

                AuthPrimaryButton(title: "Create Account", isLoading: isLoading, disabled: !canSubmit) {
                    submit()
                }

                OrDivider()

                AppleSignInButton { error = $0 }
                    .environmentObject(auth)

                HStack(spacing: 4) {
                    Text("Already have an account?").font(.system(size: 14)).foregroundColor(AppTheme.textSecondary)
                    NavigationLink { LoginView() } label: {
                        Text("Sign in").font(.system(size: 14, weight: .bold)).foregroundColor(AppTheme.primary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Couldn't create account", isPresented: Binding(
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
                try await auth.signUp(name: name, email: email, phone: phone,
                                      password: password, confirm: confirm)
            } catch {
                self.error = (error as? AuthError)?.localizedDescription ?? error.localizedDescription
            }
            isLoading = false
        }
    }
}
