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

    // MARK: - AI Assistant (Groq / Llama 3.1)

    /// Groq API key for the in-app multi-agent assistant. Get a free key at
    /// https://console.groq.com/keys and paste it here.
    static let groqAPIKey = "YOUR_GROQ_API_KEY"

    /// Base URL for Groq's OpenAI-compatible chat completions API.
    static let groqBaseURL = "https://api.groq.com/openai/v1/chat/completions"

    /// Model used by every agent. `llama-3.1-8b-instant` is fast and free-tier
    /// friendly — the same model the reference backend used.
    static let groqModel = "llama-3.1-8b-instant"

    /// True once a real Groq key is filled in. Until then the assistant shows a
    /// short setup notice instead of calling the network.
    static var isGroqConfigured: Bool {
        !groqAPIKey.contains("YOUR_GROQ") && !groqAPIKey.isEmpty
    }
}
