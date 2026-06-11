import Foundation

// MARK: - App Configuration
// Replace these values with your actual Stripe keys and backend URL before shipping.
enum Config {
    /// Your Stripe publishable key (safe to include in the app)
    static let stripePublishableKey = "pk_test_YOUR_STRIPE_PUBLISHABLE_KEY"

    /// Your backend URL — must expose POST /create-payment-intent
    /// which returns { clientSecret, ephemeralKey, customer }
    static let backendURL = "https://your-backend-url.com"

    /// True once real Stripe keys/backend are filled in. Until then the app
    /// authorizes orders locally so the full flow (history, reorder) works in
    /// the simulator without a backend.
    static var isStripeConfigured: Bool {
        !stripePublishableKey.contains("YOUR_STRIPE") && !backendURL.contains("your-backend")
    }
}
