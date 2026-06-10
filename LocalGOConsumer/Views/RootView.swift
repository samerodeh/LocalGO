import SwiftUI

/// Top-level gate: decides between the launch splash, the auth flow, and the app.
struct RootView: View {
    @EnvironmentObject private var auth: AuthService

    var body: some View {
        ZStack {
            switch auth.state {
            case .loading:
                SplashView()
            case .signedOut:
                AuthFlowView()
                    .transition(.opacity)
            case .verifying:
                if let challenge = auth.pendingChallenge {
                    VerificationView(challenge: challenge)
                        .transition(.opacity)
                } else {
                    AuthFlowView().transition(.opacity)
                }
            case .signedIn:
                ContentView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: auth.state)
        .task {
            if auth.state == .loading { await auth.restore() }
        }
    }
}

struct SplashView: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [AppTheme.navy, AppTheme.navyMid], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(spacing: 18) {
                ZStack {
                    Circle().fill(AppTheme.primary).frame(width: 78, height: 78)
                    Image(systemName: "location.fill").font(.system(size: 34)).foregroundColor(.white)
                }
                Text("LocalGO").font(.system(size: 30, weight: .black)).foregroundColor(.white).kerning(-0.5)
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)).padding(.top, 4)
            }
        }
    }
}
