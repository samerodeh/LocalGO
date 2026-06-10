import Foundation

enum SampleData {
    static func freshOrders() -> [DeliveryOrder] {
        [
            DeliveryOrder(
                id: UUID(),
                orderNumber: "LG-4821",
                restaurantName: "Al Taib",
                pickupAddress: "5765 Bd Décarie, Montreal",
                customerName: "Sarah M.",
                dropoffAddress: "1420 Rue Sherbrooke O, Montreal",
                itemCount: 3,
                orderTotal: 34.50,
                payout: 8.75,
                distanceKm: 2.4,
                status: .available,
                summaryItems: ["2× Chicken Shawarma Trio", "1× Hummus"]
            ),
            DeliveryOrder(
                id: UUID(),
                orderNumber: "LG-4822",
                restaurantName: "Al Taib",
                pickupAddress: "5765 Bd Décarie, Montreal",
                customerName: "James K.",
                dropoffAddress: "550 Av. du Président-Kennedy, Montreal",
                itemCount: 5,
                orderTotal: 52.00,
                payout: 11.20,
                distanceKm: 3.8,
                status: .available,
                summaryItems: ["1× All Dressed Pizza", "2× Zaatar Manakish", "2× Ayran Yoghurt"]
            ),
            DeliveryOrder(
                id: UUID(),
                orderNumber: "LG-4823",
                restaurantName: "Al Taib",
                pickupAddress: "5765 Bd Décarie, Montreal",
                customerName: "Amira H.",
                dropoffAddress: "3700 Rue McTavish, Montreal",
                itemCount: 2,
                orderTotal: 23.99,
                payout: 7.50,
                distanceKm: 1.6,
                status: .available,
                summaryItems: ["1× Beef Shawarma Trio", "1× Fries"]
            ),
        ]
    }
}
