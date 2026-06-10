import Foundation
import Combine

class DriverViewModel: ObservableObject {
    @Published var isOnline = false
    @Published var availableOrders: [DeliveryOrder] = []
    @Published var activeOrder: DeliveryOrder? = nil
    @Published var completedToday: [DeliveryOrder] = []

    var earningsToday: Double { completedToday.reduce(0) { $0 + $1.payout } }
    var deliveriesToday: Int { completedToday.count }

    func goOnline() {
        isOnline = true
        availableOrders = SampleData.freshOrders()
    }

    func goOffline() {
        isOnline = false
        availableOrders = []
    }

    func accept(_ order: DeliveryOrder) {
        var o = order
        o.status = .accepted
        activeOrder = o
        availableOrders.removeAll { $0.id == order.id }
    }

    /// Advances the active order through its lifecycle.
    func advanceActiveOrder() {
        guard var order = activeOrder else { return }
        switch order.status {
        case .accepted:
            order.status = .pickedUp
            activeOrder = order
        case .pickedUp:
            order.status = .delivered
            completedToday.insert(order, at: 0)
            activeOrder = nil
            // Refill the queue if still online
            if isOnline && availableOrders.isEmpty {
                availableOrders = SampleData.freshOrders()
            }
        default:
            break
        }
    }

    func cancelActiveOrder() {
        guard var order = activeOrder else { return }
        order.status = .available
        availableOrders.insert(order, at: 0)
        activeOrder = nil
    }
}
