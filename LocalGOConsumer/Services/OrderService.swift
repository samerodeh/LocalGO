import Foundation
import SwiftUI

/// Order history, persisted to the SQLite database and scoped to the signed-in
/// user. Drives the Order History screen and the "Order Again" recommendations.
@MainActor
final class OrderService: ObservableObject {
    @Published private(set) var orders: [OrderRecord] = []

    private let db = Database.shared

    /// Load this user's order history from the database.
    func load(for userId: String?) {
        guard let userId, !userId.hasPrefix("guest:") else { orders = []; return }
        orders = db.orders(userId: userId)
    }

    /// Persist a new order and return a tracking-ready `Order`.
    @discardableResult
    func placeOrder(
        userId: String?,
        items: [CartItem],
        restaurant: Restaurant,
        address: String,
        total: Double,
        payment: PaymentMethod?
    ) -> Order {
        let lines = items.map { OrderLine(itemName: $0.item.name, quantity: $0.quantity, unitPrice: $0.item.price) }
        let record = OrderRecord(
            id: UUID().uuidString,
            restaurantId: restaurant.id.uuidString,
            restaurantName: restaurant.name,
            address: address,
            placedAt: Date(),
            total: total,
            paymentBrand: payment?.brand,
            paymentLast4: payment?.last4,
            lines: lines
        )

        if let userId, !userId.hasPrefix("guest:") {
            db.insertOrder(record, userId: userId)
        }
        orders.insert(record, at: 0)

        return Order(
            id: UUID(),
            items: items,
            restaurant: restaurant,
            deliveryAddress: address,
            placedAt: record.placedAt,
            estimatedDelivery: record.placedAt.addingTimeInterval(35 * 60),
            total: total,
            paymentIntentId: nil
        )
    }

    /// Distinct items the user has ordered, most-recent first — for "Order Again".
    func recentLines(limit: Int = 12) -> [OrderLine] {
        var seen = Set<String>()
        var result: [OrderLine] = []
        for order in orders {
            for line in order.lines where !seen.contains(line.itemName) {
                seen.insert(line.itemName)
                result.append(line)
                if result.count >= limit { return result }
            }
        }
        return result
    }
}
