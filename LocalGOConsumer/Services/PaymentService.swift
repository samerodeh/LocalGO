import Foundation
import SwiftUI

/// Manages the user's saved payment methods, persisted to the database and
/// scoped to the signed-in user. Only non-sensitive metadata is stored.
@MainActor
final class PaymentService: ObservableObject {
    @Published private(set) var methods: [PaymentMethod] = []
    @Published var selectedMethodId: String?

    private let db = Database.shared
    private var userId: String?

    var selectedMethod: PaymentMethod? {
        if let id = selectedMethodId, let m = methods.first(where: { $0.id == id }) { return m }
        return methods.first(where: { $0.isDefault }) ?? methods.first
    }

    func load(for userId: String?) {
        self.userId = userId
        guard let userId, !userId.hasPrefix("guest:") else { methods = []; selectedMethodId = nil; return }
        methods = db.payments(userId: userId)
        if selectedMethodId == nil { selectedMethodId = selectedMethod?.id }
    }

    /// Add a tokenized card. `brand`/`last4`/expiry come from the entry form
    /// after validation — the full PAN is never passed here or stored.
    func addCard(brand: String, last4: String, expMonth: Int, expYear: Int) {
        guard let userId, !userId.hasPrefix("guest:") else { return }
        let isFirst = methods.isEmpty
        let method = PaymentMethod(
            id: UUID().uuidString, brand: brand, last4: last4,
            expMonth: expMonth, expYear: expYear, isDefault: isFirst
        )
        db.insertPayment(method, userId: userId)
        if isFirst { db.setDefaultPayment(id: method.id, userId: userId) }
        load(for: userId)
        selectedMethodId = method.id
    }

    func setDefault(_ method: PaymentMethod) {
        guard let userId else { return }
        db.setDefaultPayment(id: method.id, userId: userId)
        load(for: userId)
    }

    func delete(_ method: PaymentMethod) {
        db.deletePayment(id: method.id)
        if selectedMethodId == method.id { selectedMethodId = nil }
        load(for: userId)
    }
}

// MARK: - Card validation helpers

enum CardValidator {
    /// Luhn checksum — catches typos before "tokenizing".
    static func luhnValid(_ number: String) -> Bool {
        let digits = number.filter(\.isNumber).reversed().compactMap { $0.wholeNumberValue }
        guard digits.count >= 12 else { return false }
        var sum = 0
        for (i, d) in digits.enumerated() {
            if i % 2 == 1 {
                let doubled = d * 2
                sum += doubled > 9 ? doubled - 9 : doubled
            } else {
                sum += d
            }
        }
        return sum % 10 == 0
    }

    static func brand(for number: String) -> String {
        let n = number.filter(\.isNumber)
        if n.hasPrefix("4") { return "Visa" }
        if let two = Int(n.prefix(2)), (51...55).contains(two) { return "Mastercard" }
        if let four = Int(n.prefix(4)), (2221...2720).contains(four) { return "Mastercard" }
        if n.hasPrefix("34") || n.hasPrefix("37") { return "Amex" }
        if n.hasPrefix("6011") || n.hasPrefix("65") { return "Discover" }
        return "Card"
    }

    static func formatNumber(_ number: String) -> String {
        let digits = String(number.filter(\.isNumber).prefix(16))
        return stride(from: 0, to: digits.count, by: 4).map {
            let start = digits.index(digits.startIndex, offsetBy: $0)
            let end = digits.index(start, offsetBy: 4, limitedBy: digits.endIndex) ?? digits.endIndex
            return String(digits[start..<end])
        }.joined(separator: " ")
    }
}
