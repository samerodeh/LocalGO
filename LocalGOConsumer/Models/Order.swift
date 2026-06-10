import Foundation

struct Order: Identifiable {
    let id: UUID
    let items: [CartItem]
    let restaurant: Restaurant
    let deliveryAddress: String
    let placedAt: Date
    let estimatedDelivery: Date
    let total: Double
    let paymentIntentId: String?

    enum Status: String, CaseIterable {
        case placed    = "Order Placed"
        case preparing = "Preparing"
        case onTheWay  = "On the Way"
        case delivered = "Delivered"

        var icon: String {
            switch self {
            case .placed:    return "checkmark.circle.fill"
            case .preparing: return "flame.fill"
            case .onTheWay:  return "bicycle"
            case .delivered: return "house.fill"
            }
        }

        var subtitle: String {
            switch self {
            case .placed:    return "Your order has been received"
            case .preparing: return "The restaurant is preparing your order"
            case .onTheWay:  return "Your driver is on the way"
            case .delivered: return "Your order has been delivered!"
            }
        }

        var step: Int {
            switch self {
            case .placed:    return 0
            case .preparing: return 1
            case .onTheWay:  return 2
            case .delivered: return 3
            }
        }
    }
}
