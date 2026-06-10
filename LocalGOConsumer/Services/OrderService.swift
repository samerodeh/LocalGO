import Foundation

class OrderService: ObservableObject {
    @Published var orderHistory: [Order] = []

    func placeOrder(
        items: [CartItem],
        restaurant: Restaurant,
        address: String,
        total: Double,
        paymentIntentId: String? = nil
    ) -> Order {
        let order = Order(
            id: UUID(),
            items: items,
            restaurant: restaurant,
            deliveryAddress: address,
            placedAt: Date(),
            estimatedDelivery: Date().addingTimeInterval(35 * 60),
            total: total,
            paymentIntentId: paymentIntentId
        )
        orderHistory.insert(order, at: 0)
        return order
    }
}
