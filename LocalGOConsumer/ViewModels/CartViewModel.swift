import Foundation
import Combine

class CartViewModel: ObservableObject {
    @Published var items: [CartItem] = []
    @Published var promoCode: String = ""
    @Published var promoDiscount: Double = 0
    @Published var currentRestaurantId: UUID? = nil

    var totalItems: Int { items.reduce(0) { $0 + $1.quantity } }

    var subtotal: Double { items.reduce(0) { $0 + $1.lineTotal } }

    // Québec flat delivery fee (replace with real logic / backend)
    var deliveryFee: Double { items.isEmpty ? 0 : 2.99 }

    // QST + GST = 14.975%
    var tax: Double { subtotal * 0.14975 }

    var total: Double { max(0, subtotal + deliveryFee + tax - promoDiscount) }

    func addItem(_ item: MenuItem, restaurant: Restaurant) {
        if let idx = items.firstIndex(where: { $0.item.id == item.id }) {
            items[idx].quantity += 1
        } else {
            items.append(
                CartItem(
                    id: UUID(),
                    item: item,
                    quantity: 1,
                    restaurantId: restaurant.id,
                    restaurantName: restaurant.name
                )
            )
        }
        currentRestaurantId = restaurant.id
    }

    func decreaseItem(_ item: MenuItem) {
        guard let idx = items.firstIndex(where: { $0.item.id == item.id }) else { return }
        if items[idx].quantity > 1 {
            items[idx].quantity -= 1
        } else {
            items.remove(at: idx)
        }
    }

    func quantityOf(_ item: MenuItem) -> Int {
        items.first(where: { $0.item.id == item.id })?.quantity ?? 0
    }

    func clearCart() {
        items = []
        promoCode = ""
        promoDiscount = 0
        currentRestaurantId = nil
    }
}
