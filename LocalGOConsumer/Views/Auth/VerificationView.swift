import SwiftUI

/// Email-code screen shown for sign-up verification and two-factor sign-in.
struct VerificationView: View {
    let challenge: PendingChallenge
    @EnvironmentObject private var auth: AuthService

    @State private var code = ""
    @State private var isLoading = false
    @State private var error: String?
    @State private var resendIn = 30
    @State private var timer: Timer?

    private var title: String {
        challenge.kind == .twoFactor ? "Two-factor sign-in" : "Verify your email"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Button { auth.cancelChallenge() } label: {
                    Image(systemName: "chevron.left").font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                }
                Spacer()
            }
            .padding(.horizontal, 20).padding(.top, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    VStack(spacing: 14) {
                        ZStack {
                            Circle().fill(AppTheme.primary.opacity(0.12)).frame(width: 84, height: 84)
                            Image(systemName: "envelope.badge.fill").font(.system(size: 34)).foregroundColor(AppTheme.primary)
                        }
                        Text(title).font(.system(size: 24, weight: .black)).foregroundColor(AppTheme.textPrimary)
                        Text("Enter the 6-digit code we sent to\n\(challenge.email)")
                            .font(.system(size: 15)).foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center).lineSpacing(2)
                    }
                    .padding(.top, 20)

                    OTPCodeField(code: $code) { verify() }
                        .padding(.vertical, 4)

                    if let error {
                        Text(error).font(.system(size: 13, weight: .medium)).foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    #if DEBUG
                    if let demo = auth.debugLastCode {
                        Text("Demo build — your code is \(demo)")
                            .font(.system(size: 12, weight: .semibold)).foregroundColor(AppTheme.textSecondary)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(AppTheme.divider.opacity(0.5), in: Capsule())
                    }
                    #endif

                    AuthPrimaryButton(title: "Verify", isLoading: isLoading,
                                      disabled: code.count < 6) { verify() }

                    // Resend
                    HStack(spacing: 4) {
                        Text("Didn't get it?").font(.system(size: 14)).foregroundColor(AppTheme.textSecondary)
                        if resendIn > 0 {
                            Text("Resend in \(resendIn)s").font(.system(size: 14, weight: .semibold)).foregroundColor(AppTheme.textSecondary)
                        } else {
                            Button { resend() } label: {
                                Text("Resend code").font(.system(size: 14, weight: .bold)).foregroundColor(AppTheme.primary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .onAppear { startCountdown() }
        .onDisappear { timer?.invalidate() }
    }

    private func verify() {
        guard code.count == 6, !isLoading else { return }
        error = nil; isLoading = true
        Task {
            do { try await auth.submitChallengeCode(code) }
            catch {
                self.error = (error as? AuthError)?.localizedDescription ?? error.localizedDescription
                code = ""
            }
            isLoading = false
        }
    }

    private func resend() {
        error = nil
        Task {
            do { try await auth.resendChallengeCode(); startCountdown() }
            catch { self.error = (error as? AuthError)?.localizedDescription ?? error.localizedDescription }
        }
    }

    private func startCountdown() {
        resendIn = 30
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            Task { @MainActor in
                if resendIn > 0 { resendIn -= 1 } else { t.invalidate() }
            }
        }
    }
}
