import SwiftUI

// MARK: - Branded logo lockup
struct AuthLogo: View {
    var compact = false
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle().fill(AppTheme.primary).frame(width: compact ? 32 : 40, height: compact ? 32 : 40)
                Image(systemName: "location.fill")
                    .font(.system(size: compact ? 14 : 18)).foregroundColor(.white)
            }
            Text("LocalGO")
                .font(.system(size: compact ? 26 : 34, weight: .black)).kerning(-0.5)
                .foregroundColor(AppTheme.navy)
        }
    }
}

// MARK: - Styled text field
struct AuthField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var autocapitalization: TextInputAutocapitalization = .never
    var isSecure: Bool = false

    @State private var reveal = false
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16)).foregroundColor(focused ? AppTheme.primary : AppTheme.textSecondary)
                .frame(width: 22)

            Group {
                if isSecure && !reveal {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(.system(size: 15))
            .keyboardType(keyboard)
            .textContentType(textContentType)
            .textInputAutocapitalization(autocapitalization)
            .autocorrectionDisabled()
            .focused($focused)

            if isSecure {
                Button { reveal.toggle() } label: {
                    Image(systemName: reveal ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 14)).foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 15)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(focused ? AppTheme.primary : AppTheme.divider, lineWidth: focused ? 1.6 : 1)
        )
        .animation(.easeInOut(duration: 0.15), value: focused)
    }
}

// MARK: - Primary CTA with loading state
struct AuthPrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title).font(.system(size: 17, weight: .bold))
                }
            }
            .primaryButtonStyle(disabled: disabled || isLoading)
        }
        .disabled(disabled || isLoading)
    }
}

// MARK: - "or" divider
struct OrDivider: View {
    var body: some View {
        HStack(spacing: 12) {
            Rectangle().fill(AppTheme.divider).frame(height: 1)
            Text("or").font(.system(size: 13, weight: .medium)).foregroundColor(AppTheme.textSecondary)
            Rectangle().fill(AppTheme.divider).frame(height: 1)
        }
    }
}

// MARK: - Password strength meter
struct PasswordStrengthMeter: View {
    let password: String

    private var score: Int { Validators.passwordStrength(password) }
    private var color: Color {
        switch score {
        case 0, 1: return .red
        case 2:    return .orange
        case 3:    return .yellow
        default:   return AppTheme.green
        }
    }

    var body: some View {
        if !password.isEmpty {
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    ForEach(0..<4) { i in
                        Capsule()
                            .fill(i < score ? color : AppTheme.divider)
                            .frame(height: 4)
                    }
                }
                Text(Validators.strengthLabel(score))
                    .font(.system(size: 11, weight: .semibold)).foregroundColor(color)
                    .frame(width: 44, alignment: .trailing)
            }
            .animation(.easeInOut(duration: 0.2), value: score)
        }
    }
}
