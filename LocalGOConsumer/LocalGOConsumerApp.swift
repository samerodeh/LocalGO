import SwiftUI
import StripePaymentSheet

@main
struct LocalGOConsumerApp: App {
    @StateObject private var cartVM = CartViewModel()

    init() {
        // Set your Stripe publishable key — get it from dashboard.stripe.com
        StripeAPI.defaultPublishableKey = Config.stripePublishableKey
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cartVM)
        }
    }
}
