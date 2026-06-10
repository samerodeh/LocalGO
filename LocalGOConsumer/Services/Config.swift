import Foundation

// MARK: - App Configuration
// Replace these values with your actual Stripe keys and backend URL before shipping.
enum Config {
    /// Your Stripe publishable key (safe to include in the app)
    static let stripePublishableKey = "pk_test_YOUR_STRIPE_PUBLISHABLE_KEY"

    /// Your backend URL — must expose POST /create-payment-intent
    /// which returns { clientSecret, ephemeralKey, customer }
    static let backendURL = "https://your-backend-url.com"
}
