import Foundation

// MARK: - Transport

struct EmailMessage {
    let to: String
    let subject: String
    let body: String
}

/// Swap this for a real transport (SendGrid, Resend, Postmark, SES, or your own
/// backend endpoint) by implementing `send` and injecting it into EmailService.
protocol EmailSender {
    func send(_ message: EmailMessage) async throws
}

/// Default sender for local development: logs the email to the console.
/// Replace with a network-backed sender in production.
struct ConsoleEmailSender: EmailSender {
    func send(_ message: EmailMessage) async throws {
        print("""

        ┌─────────── 📧  LocalGO email (mock transport) ───────────
        │ To:      \(message.to)
        │ Subject: \(message.subject)
        │
        \(message.body.split(separator: "\n").map { "│ \($0)" }.joined(separator: "\n"))
        └──────────────────────────────────────────────────────────

        """)
    }
}

// MARK: - Templates + facade

/// Builds and sends transactional emails. Failures are surfaced as
/// `AuthError.emailSendFailed` so the UI can react.
final class EmailService {
    private let sender: EmailSender
    init(sender: EmailSender = ConsoleEmailSender()) { self.sender = sender }

    func sendVerificationCode(to email: String, code: String) async throws {
        try await deliver(EmailMessage(
            to: email,
            subject: "Your LocalGO verification code",
            body: """
            Welcome to LocalGO!

            Your verification code is: \(code)

            Enter it in the app to confirm your email. The code expires in 10 minutes.
            If you didn't create an account, you can ignore this email.
            """))
    }

    func sendPasswordResetCode(to email: String, code: String) async throws {
        try await deliver(EmailMessage(
            to: email,
            subject: "Reset your LocalGO password",
            body: """
            We received a request to reset your password.

            Your reset code is: \(code)

            Enter it in the app to choose a new password. The code expires in 10 minutes.
            If you didn't request this, you can safely ignore this email — your password
            won't change.
            """))
    }

    func sendTwoFactorCode(to email: String, code: String) async throws {
        try await deliver(EmailMessage(
            to: email,
            subject: "Your LocalGO sign-in code",
            body: """
            Your two-factor sign-in code is: \(code)

            Enter it to finish signing in. The code expires in 10 minutes.
            If this wasn't you, please change your password.
            """))
    }

    func sendWelcome(to email: String, name: String) async {
        try? await deliver(EmailMessage(
            to: email,
            subject: "Welcome to LocalGO 🎉",
            body: """
            Hi \(name.isEmpty ? "there" : name),

            Your email is verified and your account is ready. Order Lebanese favorites
            from Al Taib, delivered across Montreal.
            """))
    }

    /// Security-alert email for sensitive account changes (best-effort).
    func sendSecurityAlert(to email: String, event: String) async {
        try? await deliver(EmailMessage(
            to: email,
            subject: "Security alert on your LocalGO account",
            body: """
            We're letting you know about a change to your account:

            • \(event)

            If this was you, no action is needed. If not, reset your password right away.
            """))
    }

    private func deliver(_ message: EmailMessage) async throws {
        do { try await sender.send(message) }
        catch { throw AuthError.emailSendFailed }
    }
}
