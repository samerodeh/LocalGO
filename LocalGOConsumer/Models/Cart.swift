import Foundation

struct CartItem: Identifiable {
    let id: UUID
    let item: MenuItem
    var quantity: Int
    let restaurantId: UUID
    let restaurantName: String

    var lineTotal: Double { item.price * Double(quantity) }
}
