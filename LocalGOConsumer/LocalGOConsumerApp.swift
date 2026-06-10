import SwiftUI
import StripePaymentSheet

@main
struct LocalGOConsumerApp: App {
    @StateObject private var cartVM = CartViewModel()
    @StateObject private var recEngine = RecommendationEngine()
    @StateObject private var auth = AuthService()

    init() {
        // Set your Stripe publishable key — get it from dashboard.stripe.com
        StripeAPI.defaultPublishableKey = Config.stripePublishableKey
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(cartVM)
                .environmentObject(recEngine)
                .environmentObject(auth)
        }
    }
}
