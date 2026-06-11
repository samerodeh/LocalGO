import Foundation

/// A single line in a persisted order.
struct OrderLine: Codable, Identifiable {
    let itemName: String
    let quantity: Int
    let unitPrice: Double

    var id: String { itemName }
    var lineTotal: Double { unitPrice * Double(quantity) }
}

/// A persisted order, as stored in the database and shown in order history.
struct OrderRecord: Identifiable {
    let id: String
    let restaurantId: String
    let restaurantName: String
    let address: String
    let placedAt: Date
    let total: Double
    let paymentBrand: String?
    let paymentLast4: String?
    let lines: [OrderLine]

    var itemCount: Int { lines.reduce(0) { $0 + $1.quantity } }

    var summary: String {
        lines.map { "\($0.quantity)× \($0.itemName)" }.joined(separator: ", ")
    }

    var placedAtFormatted: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: placedAt)
    }
}
