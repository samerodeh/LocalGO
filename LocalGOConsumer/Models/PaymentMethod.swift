import Foundation

/// A saved payment method. Only non-sensitive metadata is ever stored — brand,
/// last 4 digits, and expiry. The full card number (PAN) and CVC are validated
/// in the entry form and then discarded; they're never persisted. In production
/// the card would be tokenized by Stripe (SetupIntent) and you'd store the
/// resulting payment-method id instead.
struct PaymentMethod: Identifiable, Codable, Equatable {
    let id: String
    let brand: String          // "Visa", "Mastercard", "Amex", "Discover", "Card"
    let last4: String
    let expMonth: Int
    let expYear: Int
    var isDefault: Bool

    var displayName: String { "\(brand) •••• \(last4)" }
    var expiry: String { String(format: "%02d/%02d", expMonth, expYear % 100) }

    var iconName: String {
        switch brand.lowercased() {
        case "visa", "mastercard", "amex", "discover": return "creditcard.fill"
        default: return "creditcard"
        }
    }
}
