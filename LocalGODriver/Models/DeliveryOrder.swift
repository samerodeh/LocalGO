import Foundation

struct DeliveryOrder: Identifiable {
    let id: UUID
    let orderNumber: String
    let restaurantName: String
    let pickupAddress: String
    let customerName: String
    let dropoffAddress: String
    let itemCount: Int
    let orderTotal: Double
    let payout: Double
    let distanceKm: Double
    var status: DeliveryStatus

    var summaryItems: [String]
}

enum DeliveryStatus: String {
    case available  = "Available"
    case accepted   = "Heading to Restaurant"
    case pickedUp   = "Order Picked Up"
    case delivered  = "Delivered"

    /// The label for the button that advances to the next state.
    var actionTitle: String {
        switch self {
        case .available: return "Accept Delivery"
        case .accepted:  return "Confirm Pickup"
        case .pickedUp:  return "Mark as Delivered"
        case .delivered: return "Completed"
        }
    }

    var icon: String {
        switch self {
        case .available: return "tray.full.fill"
        case .accepted:  return "bag.fill"
        case .pickedUp:  return "bicycle"
        case .delivered: return "checkmark.seal.fill"
        }
    }
}
