import SwiftUI

/// Hosts the signed-out experience: welcome → sign up / sign in.
struct AuthFlowView: View {
    var body: some View {
        NavigationStack {
            WelcomeView()
        }
        .tint(AppTheme.primary)
    }
}
